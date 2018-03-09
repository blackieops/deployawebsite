all: build

dist/assets:
	mkdir -p dist/assets

assets/sass/components/_syntax.scss: dist/assets
	bundle exec ruby bin/generate_code_css.rb

build: assets/sass/components/_syntax.scss
	bundle exec sass \
		-I vendor/bundle/ruby/*/gems/bourbon-*/app/assets/stylesheets/ \
		--style compressed \
		--scss \
		assets/sass/site.scss dist/assets/site.css
	cp -r assets/images/ dist/assets/
	zod site dist

clean:
	rm assets/sass/components/_syntax.scss
	rm -fr dist/* vendor/bundle .sass-cache


.PHONY: all build clean
