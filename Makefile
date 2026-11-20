# agentic-sdd — chequeos del plugin. `make check` antes de cada PR.

# Los scripts leen archivos UTF-8; no dependas del locale de la terminal.
export RUBYOPT := $(RUBYOPT) -Eutf-8

.PHONY: agensi-zip check agents agents-check hooks-test docs-check-test script-version-check validate

check: agents-check hooks-test docs-check-test script-version-check validate

agents:          ## regenera los especialistas desde agents-src/
	@ruby scripts/build-agents.rb

agents-check:    ## falla si algún especialista quedó desactualizado
	@ruby scripts/build-agents.rb --check

hooks-test:      ## prueba el hook guard-git contra repos temporales
	@ruby tests/guard-git-test.rb

docs-check-test: ## docs-check sobre un proyecto armado con las plantillas del bootstrap
	@ruby tests/docs-check-test.rb

script-version-check: ## si docs-check.rb cambió respecto de origin/main, su VERSION tiene que subir
	@ruby scripts/check-script-version.rb

validate:        ## validación oficial del marketplace y del plugin
	@claude plugin validate .
	@claude plugin validate ./plugins/agentic-sdd

agensi-zip:      ## arma dist/feature-sdd.zip (carpeta feature-sdd/ con SKILL.md) para subir a Agensi
	@rm -rf dist/agensi && mkdir -p dist/agensi
	@cp -R agensi/feature-sdd dist/agensi/feature-sdd
	@cd dist/agensi && rm -f ../feature-sdd.zip && zip -qr ../feature-sdd.zip feature-sdd
	@unzip -l dist/feature-sdd.zip
