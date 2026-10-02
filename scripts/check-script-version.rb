#!/usr/bin/env ruby
# frozen_string_literal: true

# Si el código de plugins/agentic-sdd/scripts/docs-check.rb cambió respecto de
# origin/main (sin contar comentarios),
# su VERSION tiene que ser distinta: los proyectos llevan una copia del script
# y /agentic-sdd:docs-check usa VERSION para avisarles que la actualicen.

require 'open3'

PATH = 'plugins/agentic-sdd/scripts/docs-check.rb'

def version(text)
  text[/^VERSION = '([^']+)'/, 1]
end

# Solo cuenta el código: cambiar comentarios o líneas en blanco no obliga a
# los proyectos a actualizar su copia.
def code(text)
  text.lines.map(&:strip).reject { |l| l.empty? || l.start_with?('#') }.join("\n")
end

current = File.read(PATH)
base, status = Open3.capture2('git', 'show', "origin/main:#{PATH}", err: File::NULL)
unless status.success?
  puts "script-version-check: sin #{PATH} en origin/main, nada que comparar"
  exit 0
end

if code(current) == code(base)
  puts "script-version-check: código de docs-check.rb sin cambios (#{version(current)})"
elsif version(current) == version(base)
  abort "✗ docs-check.rb cambió pero su VERSION sigue en #{version(current)}: subila"
else
  puts "script-version-check: docs-check.rb #{version(base)} → #{version(current)}"
end
