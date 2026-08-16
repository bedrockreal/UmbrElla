BUILD_DIR	:= build
SRC_DIRS	:= src
INC_DIRS	:= include

SRCS	:= $(shell find $(SRC_DIRS) -name '*.s')
BINS	:= $(SRCS:%.s=$(BUILD_DIR)/%.bin)
TXTS	:= $(SRCS:%.s=$(BUILD_DIR)/%.txt)

all:	$(TXTS)

$(BUILD_DIR)/%.txt:	$(BUILD_DIR)/%.bin
	@$(DEVKITPPC)/bin/powerpc-eabi-objdump -D -z $<	\
	|	grep '^\s*[0-9a-f]*:'						\
	|	awk '{print $$2 $$3 $$4 $$5}'				\
	|	paste -d' ' - -								\
	>	$@

$(BUILD_DIR)/%.bin:	%.s
	@mkdir -p $(dir $@)
	# TODO: patch assembly with custom program
	@$(DEVKITPPC)/bin/powerpc-eabi-as -mregnames -mgekko -mbig -I$(INC_DIRS) -I$(dir $<) $< -o $@

.PHONY: clean
clean:
	rm -r $(BUILD_DIR)
