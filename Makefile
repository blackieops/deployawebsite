SASS = $(shell find assets/sass -type f -name "*.scss")
CSS = $(SASS:assets/sass/%.scss=dist/assets/site.css)

IMAGES = $(shell find assets/images -type f)
DESTIMAGES = $(IMAGES:assets/images/%=dist/assets/images/%)

MARKDOWNS = $(shell find site/ -type f -name "*.md")
HTMLS = $(MARKDOWNS:site/%/index.md=dist/%/index.html)

all: $(CSS) $(DESTIMAGES) $(HTMLS)

assets/sass/components/_syntax.scss:
	bundle exec ruby bin/generate_code_css.rb

dist/assets/site.css: $(SASS) assets/sass/components/_syntax.scss
	@mkdir -p dist/assets
	bundle exec sass \
		-I vendor/bundle/ruby/*/gems/bourbon-*/app/assets/stylesheets/ \
		--style compressed \
		--scss \
		assets/sass/site.scss dist/assets/site.css

dist/%/index.html: site/%/index.md
	zod site dist

dist/assets/images/%: $(IMAGES)
	@mkdir -p dist/assets/images
	cp -v $< $@

clean:
	rm assets/sass/components/_syntax.scss
	rm -fr dist/* .sass-cache

.PHONY: all clean
