#!/usr/bin/env ruby
# frozen_string_literal: true

# build-agents — genera los agentes especialistas del plugin.
#
# Las secciones que comparten frontend/backend/ai/devops-agent viven una sola
# vez en plugins/agentic-sdd/reference/specialist-common.md. Cada fuente en
# agents-src/ marca dónde va cada una con {{COMMON:<título de la sección>}}.
# Este script reemplaza los marcadores y escribe el resultado en
# plugins/agentic-sdd/agents/.
#
# Uso:
#   ruby scripts/build-agents.rb          # regenera los agentes
#   ruby scripts/build-agents.rb --check  # falla si alguno está desactualizado

Encoding.default_external = Encoding::UTF_8 # no depende del locale de la terminal

ROOT = File.expand_path('..', __dir__)
COMMON = File.join(ROOT, 'plugins/agentic-sdd/reference/specialist-common.md')
SRC_DIR = File.join(ROOT, 'agents-src')
OUT_DIR = File.join(ROOT, 'plugins/agentic-sdd/agents')
HEADER = "<!-- Generado por scripts/build-agents.rb desde agents-src/ y " \
         "reference/specialist-common.md. No editar a mano. -->\n"

# "## Título" => "## Título\n\ncuerpo..." (hasta el próximo "## ")
def common_sections
  text = File.read(COMMON)
  text.split(/^(?=## )/).select { |s| s.start_with?('## ') }.to_h do |section|
    [section.lines.first.sub('## ', '').strip, section.rstrip]
  end
end

def render(source, sections)
  body = source.gsub(/^\{\{COMMON:(.+?)\}\}$/) do
    sections.fetch(Regexp.last_match(1)) do |title|
      abort "✗ sección común inexistente: #{title}"
    end
  end
  leftover = body[/\{\{[^}]*\}\}/]
  abort "✗ marcador sin resolver: #{leftover}" if leftover

  # El comentario va después del frontmatter, que tiene que ser lo primero.
  body.sub(/\A(---\n.*?\n---\n)/m) { "#{Regexp.last_match(1)}#{HEADER}" }
end

check = ARGV.include?('--check')
sections = common_sections
stale = []

Dir.glob(File.join(SRC_DIR, '*.md')).sort.each do |src|
  out = File.join(OUT_DIR, File.basename(src))
  rendered = render(File.read(src), sections)
  if check
    stale << File.basename(out) unless File.exist?(out) && File.read(out) == rendered
  else
    File.write(out, rendered)
    puts "✓ #{File.basename(out)}"
  end
end

if check
  if stale.empty?
    puts 'build-agents: agentes al día'
  else
    stale.each { |f| puts "✗ #{f} desactualizado: correr ruby scripts/build-agents.rb" }
    exit 1
  end
end
