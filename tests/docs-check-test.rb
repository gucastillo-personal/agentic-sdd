#!/usr/bin/env ruby
# frozen_string_literal: true

# Pruebas de docs-check sobre un proyecto armado con las plantillas de
# bootstrap-proyecto: el proyecto recién creado tiene que pasar, y cada error
# sembrado tiene que detectarse. Uso: ruby tests/docs-check-test.rb

require 'fileutils'
require 'open3'
require 'tmpdir'

PLUGIN = File.expand_path('../plugins/agentic-sdd', __dir__)
TEMPLATES = File.join(PLUGIN, 'skills/bootstrap-proyecto/templates')
CHECK = File.join(PLUGIN, 'scripts/docs-check.rb')
VALUES = { '{{PROYECTO}}' => 'Demo', '{{REPO_RAIZ}}' => '`demo`', '{{DUENO}}' => 'el dueño' }.freeze

def write(path, text)
  FileUtils.mkdir_p(File.dirname(path))
  File.write(path, text)
end

def edit(path)
  File.write(path, yield(File.read(path)))
end

# Proyecto como lo deja el bootstrap: plantillas, un repo, un contrato, un
# proveedor, sus notas, una spec y un ADR creado desde la plantilla.
def build_project(dir)
  Dir.glob('**/*', File::FNM_DOTMATCH, base: TEMPLATES).each do |rel|
    src = File.join(TEMPLATES, rel)
    next if File.directory?(src) || rel == 'Makefile.docs-check'

    write(File.join(dir, rel), VALUES.reduce(File.read(src)) { |t, (k, v)| t.gsub(k, v) })
  end
  FileUtils.mkdir_p(File.join(dir, 'web'))
  FileUtils.mkdir_p(File.join(dir, 'scripts'))
  FileUtils.cp(CHECK, File.join(dir, 'scripts/docs-check.rb')) # bootstrap, paso 4.4

  edit(File.join(dir, 'manifest.yaml')) do |t|
    t.sub("repositories: {}\n", <<~YAML)
      repositories:
        web:
          path: web
          status: in-development
          type: web-frontend
          responsibility: Muestra la agenda.
          gate: pnpm gate
          deploy: vercel (manual)
          domains: [agenda]
          providers: [vercel]
    YAML
     .sub("contracts: {}\n", <<~YAML)
       contracts:
         agenda-json:
           kind: file/json
           producer: web
           consumers: {}
           schema: docs/HOME.md
     YAML
     .sub("providers: {}\n", "providers:\n  vercel:\n    services: [hosting]\n    cost: free\n")
  end

  { 'repo' => 'web', 'domain' => 'agenda', 'contract' => 'agenda-json', 'provider' => 'vercel' }.each do |kind, name|
    note = File.read(File.join(dir, "docs/#{kind}s/_template.md")).gsub('<nombre>', name)
    note = note.gsub('[[domain-web]]', '[[domain-agenda]]').gsub('[[domain-agenda-json]]', '[[domain-agenda]]')
    write(File.join(dir, "docs/#{kind}s/#{kind}-#{name}.md"), note)
  end

  # ADR desde la plantilla, sin borrar sus comentarios de ejemplo.
  adr = File.read(File.join(dir, 'docs/decisions/_template.md'))
            .sub('id: ADR-NNNN', 'id: ADR-0001')
            .sub('title: <decisión en una línea>', 'title: Web estática')
            .sub(/^status: Proposed/, 'status: Accepted')
            .sub('["[[repo-xxx]]"]', '["[[repo-web]]"]')
            .sub('["[[domain-xxx]]"]', '["[[domain-agenda]]"]')
            .sub(/^origin: ""/, 'origin: "[[specs/0001-agenda/spec|0001]]"')
  write(File.join(dir, 'docs/decisions/ADR-0001-web-estatica.md'), adr)
  edit(File.join(dir, 'docs/decisions/README.md')) do |t|
    "#{t.rstrip}\n| [ADR-0001](./ADR-0001-web-estatica.md) | Web estática | L2 | Accepted | spec 0001 |\n"
  end

  write(File.join(dir, 'specs/0001-agenda/spec.md'), <<~MD)
    ---
    id: "0001"
    title: Ver la agenda
    type: spec
    status: draft
    created: 2026-10-02
    closed:
    repos: ["[[repo-web]]"]
    domains: ["[[domain-agenda]]"]
    contracts: ["[[contract-agenda-json]]"]
    providers: ["[[provider-vercel]]"]
    decisions: []
    ---

    # 0001 — Ver la agenda

    ## Decisiones relacionadas

    Ninguna previa.
  MD
end

def run_check(dir)
  out, status = Open3.capture2e('ruby', CHECK, dir)
  [out, status.success?]
end

# [descripción, mutación, texto que tiene que aparecer en un error]
MUTATIONS = [
  ['link roto', ->(d) { edit("#{d}/docs/glossary.md") { |t| "#{t}\n[x](./no-existe.md)\n" } }, 'link roto: ./no-existe.md'],
  ['wikilink con typo', ->(d) { edit("#{d}/docs/repos/repo-web.md") { |t| t.sub('[[domain-agenda]]', '[[domain-agendaa]]') } }, '[[domain-agendaa]]'],
  ['nota faltante', ->(d) { File.delete("#{d}/docs/providers/provider-vercel.md") }, 'falta la nota docs/providers/provider-vercel.md'],
  ['nota huérfana', ->(d) { write("#{d}/docs/domains/domain-fantasma.md", "# x\n") }, 'nota huérfana'],
  ['campo faltante en ADR', ->(d) { edit("#{d}/docs/decisions/ADR-0001-web-estatica.md") { |t| t.sub(/^cost_impact:.*\n/, '') } }, 'falta el campo `cost_impact`'],
  ['índice desalineado', ->(d) { edit("#{d}/docs/decisions/ADR-0001-web-estatica.md") { |t| t.sub(/^status: Accepted/, 'status: Deprecated') } }, 'el estado del índice no coincide'],
  ['ADR fuera del índice', ->(d) { edit("#{d}/docs/decisions/README.md") { |t| t.sub(/^\| \[ADR-0001\].*\n/, '') } }, 'no está en el índice'],
  ['decisions desalineado', ->(d) { edit("#{d}/specs/0001-agenda/spec.md") { |t| t.sub('decisions: []', 'decisions: ["[[ADR-0001-web-estatica]]"]') } }, 'no coincide con `decisions`'],
  ['ID de cuenta en un ARN', ->(d) { edit("#{d}/docs/glossary.md") { |t| "#{t}\narn:aws:sns:us-east-1:123456789012:x\n" } }, 'ID de cuenta AWS en un ARN'],
  ['webhook de Discord', ->(d) { edit("#{d}/docs/glossary.md") { |t| "#{t}\nhttps://discord.com/api/webhooks/123/abc\n" } }, 'URL de webhook de Discord']
].freeze

# Problemas de redacción que aparecen al reemplazar los marcadores (el dueño
# se escribe con artículo, "el dueño", así que una frase mal armada se ve).
def template_problems(dir)
  problems = []
  Dir.glob('**/*', File::FNM_DOTMATCH, base: dir).each do |rel|
    path = File.join(dir, rel)
    next if File.directory?(path) || rel.start_with?('scripts/')

    text = File.read(path)
    problems << "#{rel}: marcador sin reemplazar #{text[/\{\{[^}]*\}\}/]}" if text.match?(/\{\{[^}]*\}\}/)
    problems << "#{rel}: \"de el\" en vez de \"del\"" if text.match?(/\bde\s+el dueño/)
    problems << "#{rel}: el dueño en minúscula al empezar una oración" if text.match?(/(\A|[.!?]\s+|^[>\-*]?\s*)el dueño/)
  end
  Dir.glob(File.join(TEMPLATES, 'docs/*/_template.md')).each do |tpl|
    title = File.read(tpl)[/^# .*$/]
    next if tpl.include?('/decisions/')

    problems << "#{tpl.sub("#{TEMPLATES}/", '')}: el título no usa <nombre> (#{title})" unless title.include?('<nombre>')
  end
  problems
end

failures = 0
Dir.mktmpdir do |tmp|
  base = File.join(tmp, 'base')
  build_project(base)
  problems = template_problems(base)
  puts "#{problems.empty? ? '✓' : '✗'} plantillas sin problemas de redacción"
  problems.each { |pr| puts "    #{pr}" }
  failures += 1 unless problems.empty?
  out, ok = run_check(base)
  clean = ok && out.include?('0 errores')
  puts "#{clean ? '✓' : '✗'} proyecto recién creado pasa (#{out.lines.last.strip})"
  puts out unless clean
  failures += 1 unless clean

  MUTATIONS.each_with_index do |(name, mutate, expected), i|
    dir = File.join(tmp, "m#{i}")
    FileUtils.cp_r(base, dir)
    mutate.call(dir)
    out, ok = run_check(dir)
    caught = !ok && out.lines.any? { |l| l.start_with?('✗') && l.include?(expected) }
    puts "#{caught ? '✓' : '✗'} detecta: #{name}"
    failures += 1 unless caught
  end
end

puts "docs-check: #{MUTATIONS.size + 2 - failures}/#{MUTATIONS.size + 2} casos"
exit(failures.zero? ? 0 : 1)
