SRC_DIR := src
TEST_DIR := test
OUT_DIR := out

SRC_MODULES := $(patsubst ${SRC_DIR}/%.gleam,%,$(wildcard ${SRC_DIR}/*.gleam))
SRC_OUT := $(patsubst %,${OUT_DIR}/%.out,${SRC_MODULES})
TEST_MODULES := $(patsubst ${TEST_DIR}/%.gleam,%,$(wildcard ${TEST_DIR}/*.gleam))
TEST_OUT := $(patsubst %,${OUT_DIR}/%.out,${TEST_MODULES})

.DEFAULT_GOAL := all
.PHONY: all clean

all: ${SRC_OUT} ${TEST_OUT}

clean:
	rm -rf ${OUT_DIR}

show:
	@echo "SRC_MODULES:" ${SRC_MODULES}
	@echo "SRC_OUT:" ${SRC_OUT}
	@echo "TEST_MODULES:" ${TEST_MODULES}
	@echo "TEST_OUT:" ${TEST_OUT}
	@for d in ${SRC_MODULES}; do \
		echo $$d; \
		gleam run --module $$d; \
	done
	gleam test

${OUT_DIR}/%_test.out: ${TEST_DIR}/%_test.gleam
	@mkdir -p ${OUT_DIR}
	gleam test -- $$(basename $< .gleam) >& $@

${OUT_DIR}/%.out: ${SRC_DIR}/%.gleam
	@mkdir -p ${OUT_DIR}
	gleam run --no-print-progress --module $* >& $@
