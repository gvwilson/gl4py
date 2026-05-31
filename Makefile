LESSON_DIRS = $(patsubst %/Makefile,%,$(wildcard */Makefile))
OUT_DIRS := $(patsubst %,%/out,${LESSON_DIRS})
.DEFAULT_GOAL := commands

## commands: show available commands
commands:
	@grep -h -E '^##' ${MAKEFILE_LIST} \
	| sed -e 's/## //g' \
	| column -t -s ':'

## bib: Check bibliography entries
bib:
	@mccole bib

## clean: clean up generated and cache files
clean:
	@find . -type f -name '*~' -exec rm {} \;
	@rm -rf ${OUT_DIRS}

## check: check code and project
check:
	@mccole check --src . --dst docs --files
	@typos *.md */*.md

## count: count lines of code per lesson
count:
	@for dir in */; do \
		dir=$${dir%/}; \
		srcs=; tests=; \
		[ -d $$dir/src ] && srcs=$$dir/src/*.gleam; \
		[ -d $$dir/test ] && tests=$$dir/test/*.gleam; \
		if [ -n "$$srcs" ] || [ -n "$$tests" ]; then \
			echo $$dir $$(wc -l $$srcs $$tests | tail -1 | tr -s ' ' | cut -d ' ' -f 2); \
		fi \
	done

## serve: serve generated HTML on port 8000
serve:
	@python -m http.server -d docs 8000

## regen: rebuild all lesson examples
regen:
	@for d in ${LESSON_DIRS}; do \
		$(MAKE) -C $$d all || true; \
	done

## site: build HTML
site:
	@mccole build --src . --dst docs
	@touch docs/.nojekyll
