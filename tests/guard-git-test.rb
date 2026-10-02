#!/usr/bin/env ruby
# frozen_string_literal: true

# Pruebas del hook guard-git: arma repos git temporales y le pasa a guard-git
# el mismo JSON que le pasa Claude Code. Uso: ruby tests/guard-git-test.rb

require 'json'
require 'open3'
require 'tmpdir'

GUARD = File.expand_path('../plugins/agentic-sdd/scripts/guard-git.rb', __dir__)

def git(dir, *args)
  _, status = Open3.capture2e('git', '-C', dir, *args)
  raise "git #{args.join(' ')} falló en #{dir}" unless status.success?
end

def make_repo(path, branch, allow_main: false)
  Dir.mkdir(path)
  git(path, 'init', '-q', '-b', 'main')
  git(path, 'commit', '-q', '--allow-empty', '-m', 'init')
  git(path, 'switch', '-q', '-c', branch) unless branch == 'main'
  git(path, 'config', 'agentic-sdd.allowDirectMain', 'true') if allow_main
  path
end

def decision(command, cwd)
  input = { tool_name: 'Bash', tool_input: { command: command }, cwd: cwd }.to_json
  out, status = Open3.capture2('ruby', GUARD, stdin_data: input)
  raise "guard-git salió con #{status.exitstatus}" unless status.success?

  out.strip.empty? ? :allow : JSON.parse(out).dig('hookSpecificOutput', 'permissionDecision').to_sym
end

Dir.mktmpdir do |tmp|
  on_main = make_repo(File.join(tmp, 'en-main'), 'main')
  feature = make_repo(File.join(tmp, 'en-rama'), 'feature/x')
  vault = make_repo(File.join(tmp, 'vault'), 'main', allow_main: true)

  cases = [
    # [comando, cwd, esperado]
    ['gh pr merge 12 --squash', feature, :deny],
    ['cd sub && gh pr merge 12', feature, :deny],
    ['gh api -X PUT repos/o/r/pulls/12/merge', feature, :deny],
    ['gh pr view 12', feature, :allow],
    ['gh pr create --fill', feature, :allow],
    ['git push', on_main, :deny],
    ['git push origin main', feature, :deny],
    ['git push -u origin HEAD:main', feature, :deny],
    ['git push origin feature/x:refs/heads/master', feature, :deny],
    ['git push origin --delete main', feature, :deny],
    ['git push --all origin', feature, :deny],
    ['git push --mirror origin', feature, :deny],
    ["cd #{on_main} && git push", feature, :deny],
    ["git -C #{on_main} push", feature, :deny],
    ['FOO=1 git push origin main', feature, :deny],
    ['git status && git push origin main', feature, :deny],
    ['git push', feature, :allow],
    ['git push -u origin feature/x', feature, :allow],
    ['git push -u origin HEAD', feature, :allow],
    ['git push --force-with-lease origin feature/x', feature, :allow],
    ['git push origin --delete feature/viejo', feature, :allow],
    ['git push', vault, :allow],
    ['git push origin main', vault, :allow],
    ['gh pr merge 3', vault, :deny],
    ['echo "git push origin main"', feature, :allow],
    ['git log --oneline -3', on_main, :allow],
    ['ls -la', on_main, :allow]
  ]

  failures = cases.reject do |command, cwd, expected|
    got = decision(command, cwd)
    ok = got == expected
    puts "#{ok ? '✓' : '✗'} #{expected.to_s.ljust(5)} #{command}#{ok ? '' : "  (dio #{got})"}"
    ok
  end

  _, status = Open3.capture2('ruby', GUARD, stdin_data: 'no es json')
  puts "#{status.success? ? '✓' : '✗'} entrada inválida → deja pasar"

  puts "guard-git: #{cases.size - failures.size}/#{cases.size} casos"
  exit(failures.empty? && status.success? ? 0 : 1)
end
