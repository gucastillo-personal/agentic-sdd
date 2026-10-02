#!/usr/bin/env ruby
# frozen_string_literal: true

# guard-git — hook PreToolUse (Bash) de agentic-sdd.
#
# Bloquea, en cualquier modo de permisos, las acciones que en un proyecto
# agentic-sdd hace siempre una persona:
#
#   1. Mergear un pull request (`gh pr merge`, o la API de merge de GitHub).
#   2. Pushear a una rama protegida (`main`/`master`): directo, por refspec
#      (`HEAD:main`), con `--all`/`--mirror`, o borrándola.
#   3. Hacer force push cuando no se puede saber a qué rama va.
#
# Un repo puede permitir el push directo a su rama principal (por ejemplo,
# un vault personal sin PRs) con una opción local que pone una persona y
# no se commitea:
#
#   git config agentic-sdd.allowDirectMain true
#
# El merge de PRs no tiene excepción.
#
# Es una red de seguridad, no un parser de shell: no ve pushes hechos dentro
# de scripts, aliases de git ni targets de make. Si no puede leer la entrada,
# deja pasar (exit 0) para no trabar la sesión.

require 'json'
require 'open3'
require 'shellwords'

PROTECTED = %w[main master].freeze

def deny(reason)
  puts JSON.generate(
    hookSpecificOutput: {
      hookEventName: 'PreToolUse',
      permissionDecision: 'deny',
      permissionDecisionReason: "agentic-sdd: #{reason}"
    }
  )
  exit 0
end

def git_out(dir, *args)
  out, status = Open3.capture2('git', '-C', dir, *args, err: File::NULL)
  status.success? ? out.strip : nil
rescue StandardError
  nil
end

def allow_direct_main?(dir)
  git_out(dir, 'config', '--get', 'agentic-sdd.allowDirectMain') == 'true'
end

def branch_name(ref)
  ref.to_s.sub(%r{\Arefs/heads/}, '')
end

# Separa el comando en tramos por &&, ||, ;, | y saltos de línea, respetando
# comillas. Alcanza para comandos de una línea como los que corre un agente.
def segments(command)
  parts = []
  current = +''
  quote = nil
  chars = command.chars
  i = 0
  while i < chars.size
    c = chars[i]
    if quote
      current << c
      quote = nil if c == quote
    elsif c == "'" || c == '"'
      quote = c
      current << c
    elsif c == "\n" || c == ';'
      parts << current
      current = +''
    elsif (c == '&' || c == '|') && chars[i + 1] == c
      parts << current
      current = +''
      i += 1
    elsif c == '|'
      parts << current
      current = +''
    else
      current << c
    end
    i += 1
  end
  parts << current
  parts.map(&:strip).reject(&:empty?)
end

def tokens(segment)
  Shellwords.split(segment)
rescue ArgumentError
  segment.split
end

def check_merge(words)
  if words.each_cons(3).any? { |a, b, c| a == 'gh' && b == 'pr' && c == 'merge' }
    deny('el merge de un PR lo hace siempre una persona. Dejá el PR listo y avisá al dueño del proyecto.')
  end
  return unless words.first(2) == %w[gh api] && words.any? { |w| w.match?(%r{pulls/\d+/merge}) }

  deny('el merge de un PR lo hace siempre una persona, también por la API de GitHub.')
end

# words: tokens desde "git" en adelante.
def check_push(words, dir)
  args = words.drop(1)
  # Opciones globales de git antes del subcomando: -C <dir>, -c k=v, etc.
  while args.any? && args.first.start_with?('-')
    opt = args.shift
    if opt == '-C'
      dir = File.expand_path(args.shift.to_s, dir)
    elsif %w[-c --git-dir --work-tree --namespace].include?(opt)
      args.shift
    end
  end
  return unless args.first == 'push'

  push_args = args.drop(1)
  flags = push_args.select { |a| a.start_with?('-') }
  positional = push_args.reject { |a| a.start_with?('-') }
  force = flags.any? { |f| f == '-f' || f.start_with?('--force') } ||
          positional.drop(1).any? { |r| r.start_with?('+') }
  delete = flags.include?('-d') || flags.include?('--delete')
  return if allow_direct_main?(dir)

  if flags.include?('--all') || flags.include?('--mirror')
    deny('`git push --all`/`--mirror` también empuja la rama principal. Pusheá solo tu rama de trabajo.')
  end

  refspecs = positional.drop(1) # el primero es el remoto
  targets =
    if refspecs.empty?
      current = git_out(dir, 'rev-parse', '--abbrev-ref', 'HEAD')
      current.nil? || current == 'HEAD' ? [nil] : [current]
    else
      refspecs.map do |r|
        r = r.delete_prefix('+')
        r = 'HEAD' if r.empty?
        dst = r.include?(':') ? r.split(':', 2).last : r
        if dst == 'HEAD' || dst.empty?
          git_out(dir, 'rev-parse', '--abbrev-ref', 'HEAD')
        else
          branch_name(dst)
        end
      end
    end

  if targets.any? { |t| PROTECTED.include?(t) }
    verb = delete ? 'borrar' : 'pushear a'
    deny("no se puede #{verb} `main`/`master` desde un agente. Trabajá en una rama y abrí un PR; " \
         'el merge lo hace una persona.')
  end
  return unless force && targets.include?(nil)

  deny('force push sin una rama de destino explícita. Indicá el remoto y la rama (por ejemplo `git push -f origin mi-rama`).')
end

begin
  input = JSON.parse($stdin.read)
rescue JSON::ParserError
  exit 0
end
exit 0 unless input.is_a?(Hash) && input['tool_name'] == 'Bash'

command = input.dig('tool_input', 'command').to_s
dir = input['cwd'].to_s
dir = Dir.pwd if dir.empty?

segments(command).each do |segment|
  words = tokens(segment)
  # Prefijos que no cambian el comando real.
  words = words.drop_while { |w| w.include?('=') && !w.start_with?('-') } # VAR=valor
  words = words.drop(1) while %w[command sudo nohup time].include?(words.first)
  next if words.empty?

  if words.first == 'cd'
    target = words[1]
    dir = target.nil? ? Dir.home : File.expand_path(target, dir)
    next
  end

  check_merge(words)
  check_push(words, dir) if words.first == 'git'
end

exit 0
