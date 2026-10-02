# agentic-sdd — chequeos del plugin. `make check` antes de cada PR.

.PHONY: check agents agents-check hooks-test version-check validate

check: agents-check hooks-test version-check validate

agents:          ## regenera los especialistas desde agents-src/
	@ruby scripts/build-agents.rb

agents-check:    ## falla si algún especialista quedó desactualizado
	@ruby scripts/build-agents.rb --check

hooks-test:      ## prueba el hook guard-git contra repos temporales
	@ruby tests/guard-git-test.rb

version-check:   ## docs-check.rb y plugin.json declaran la misma versión
	@ruby -rjson -e 'p = JSON.parse(File.read("plugins/agentic-sdd/.claude-plugin/plugin.json"))["version"]; d = File.read("plugins/agentic-sdd/scripts/docs-check.rb")[/VERSION = .([^\x27]+)/, 1]; abort("✗ plugin.json #{p} ≠ docs-check.rb #{d}") unless p == d; puts "versión #{p} consistente"'

validate:        ## validación oficial del marketplace y del plugin
	@claude plugin validate .
	@claude plugin validate ./plugins/agentic-sdd
