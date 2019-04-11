MARKDOWNS = $(shell find site/ -type f -name "*.md")
HTMLS = $(MARKDOWNS:site/%/index.md=dist/%/index.html)

all: $(HTMLS) site/_/css/code.css

site/_/css/code.css:
	bundle exec ruby bin/generate_code_css.rb

dist/%/index.html: site/%/index.md site/_/css/site.css site/main.layout
	zod site dist

clean:
	rm site/_/code.css
	rm -fr dist/*

.PHONY: clean
