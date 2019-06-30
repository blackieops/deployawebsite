# Deploy a Website

This is the source code for [deployawebsite.com](https://www.deployawebsite.com). This site exists to instruct and educate those who don't have a background in systems administration on easy and powerful ways to host a web site on the Internet using modern security and scalability practices.

## Building

The site is built with GNU Make and a couple Ruby scripts. As long as you have a
reasonably up-to-date Ruby (2.3+), the `bundler` gem, and GNU coreutils
installed, you can just run:

```
$ bundle install
$ make
```

The generated site will be dumped into `./dist`.

## Development

Just run `make` whenever you make a change.

For something automatic, you could look into a solution like [inotifywait](https://linux.die.net/man/1/inotifywait) or [entr](http://entrproject.org/).

With the latter:

```
$ ag -l | entr make
```

## Licenses

The source code, templates, and other non-prose files are licensed according to [LICENSE](./LICENSE).

The site content (markdown files) are licensed under [CC BY-NC-SA 4.0](https://creativecommons.org/licenses/by-nc-sa/4.0/).
