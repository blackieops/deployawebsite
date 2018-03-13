SASS = $(shell find assets/sass -type f -name "*.scss")
CSS = $(SASS:assets/sass/%.scss:dist/assets/site.css)
IMAGES = $(shell find assets/images -type f)
DESTIMAGES = $(IMAGES:assets/images/%:dist/assets/images/%)

all: $(CSS) build

dist/assets:
	@mkdir -p dist/assets

assets/sass/components/_syntax.scss: dist/assets
	bundle exec ruby bin/generate_code_css.rb

dist/assets/site.css: $(SASS) assets/sass/components/_syntax.scss
	bundle exec sass \
		-I vendor/bundle/ruby/*/gems/bourbon-*/app/assets/stylesheets/ \
		--style compressed \
		--scss \
		assets/sass/site.scss dist/assets/site.css

build: dist/assets/site.css
	zod site dist

dist/assets/images/%: $(IMAGES)
	cp -r assets/images/ dist/assets/

clean:
	rm assets/sass/components/_syntax.scss
	rm -fr dist/* vendor/bundle .sass-cache

.PHONY: all build clean
