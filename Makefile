BIN = ./node_modules/.bin
SRC = $(wildcard src/*.coffee)
LIB = $(SRC:src/%.coffee=lib/%.js)

build: $(LIB)

build-spec:
	$(MAKE) -Cspec build

lib/%.js: src/%.coffee
	@mkdir -p $(@D)
	@$(BIN)/coffee -bcp $< > $@

clean:
	@rm -f $(LIB)

install link:
	@npm $@

test:
	#@$(BIN)/mocha -b -R spec --compilers coffee:coffee-script spec.coffee

release-patch: build test
	@$(call release,patch)

release-minor: build test
	@$(call release,minor)

release-major: build test
	@$(call release,major)

publish:
	git push --tags origin HEAD:master
	npm publish

define release
	VERSION=`node -pe "require('./package.json').version"` && \
	NEXT_VERSION=`node -pe "require('semver').inc(\"$$VERSION\", '$(1)')"` && \
  node -e "\
  	var j = require('./package.json');\
  	j.version = \"$$NEXT_VERSION\";\
  	var s = JSON.stringify(j, null, 2);\
  	require('fs').writeFileSync('./package.json', s);" && \
  git commit -m "release $$NEXT_VERSION" -- package.json && \
  git tag "$$NEXT_VERSION" -m "release $$NEXT_VERSION"
endef
