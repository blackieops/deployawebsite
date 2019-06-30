MARKDOWNS = $(shell find site/ -type f -name "*.md")
HTMLS = $(MARKDOWNS:site/%.md=dist/%.html)

STATICSRC = $(shell find site/_ -type f)
STATICDIST = $(STATICSRC:site/_/%=dist/_/%)

all: $(HTMLS) dist/_/css/code.css $(STATICDIST)

dist/%.html: site/%.md _layout.html.erb
	@mkdir -p $(dir $@)
	bundle exec ruby bin/render $< > $@

dist/_/css/code.css:
	@mkdir -p $(dir $@)
	bundle exec ruby bin/generate_code_css > $@

dist/_/%: site/_/%
	@mkdir -p $(dir $@)
	cp $< $@

clean:
	rm -fr dist/*

.PHONY: clean
