PKG := lustre
OUT_DIR := out

$(OUT_DIR)/counter_demo.built:
	@mkdir -p $(OUT_DIR)
	gleam build > $@ 2>&1

all: $(OUT_DIR)/counter_demo.built

.PHONY: all clean
clean:
	rm -rf $(OUT_DIR) build
