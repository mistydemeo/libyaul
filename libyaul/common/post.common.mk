ifeq ($(strip $(SH_PROGRAM)),)
  $(error Empty SH_PROGRAM (SH program name))
endif

ifeq ($(strip $(SH_OBJECTS)),)
  # If both OBJECTS and OBJECTS_NO_LINK is empty
  ifeq ($(strip $(SH_OBJECTS_NO_LINK)),)
    $(error Empty SH_OBJECTS (SH object list))
  endif
endif

ifneq ($(strip $(M68K_PROGRAM)),)
  ifneq ($(strip $(M68K_PROGRAM)),undefined-program)
    ifeq ($(strip $(M68K_OBJECTS)),)
      $(error Empty M68K_OBJECTS (M68K object list))
    endif
  endif
endif

ifeq ($(strip $(SH_CUSTOM_SPECS)),)
  SH_SPECS= yaul.specs
else
  SH_SPECS= $(SH_CUSTOM_SPECS)
endif

ROMDISK_DEPS:= $(shell find ./romdisk -type f 2> /dev/null) $(ROMDISK_DEPS)

ifneq ($(strip $(M68K_PROGRAM)),)
  ifneq ($(strip $(M68K_PROGRAM)),undefined-program)
    # Check if there is a romdisk.o. If not, append to list of SH
    # objects
    ifeq ($(strip $(filter %.romdisk.o,$(SH_OBJECTS))),)
      SH_OBJECTS+= root.romdisk.o
    endif
    ROMDISK_DEPS+= ./romdisk/$(M68K_PROGRAM).m68k
  endif
endif

SH_DEPS:= $(SH_OBJECTS:.o=.d)
SH_DEPS_NO_LINK:= $(SH_OBJECTS_NO_LINK:.o=.d)

all: $(SH_PROGRAM).iso

example: all

$(SH_PROGRAM).bin: $(SH_PROGRAM).elf
	$(SH_OBJCOPY) -O binary $< $@
	@du -hs $@ | awk '{ print $$1 " ""'"($@)"'" }'

$(SH_PROGRAM).elf: $(SH_OBJECTS) $(SH_OBJECTS_NO_LINK)
	$(SH_LD) -specs=$(SH_SPECS) $(SH_OBJECTS) $(SH_LDFLAGS) $(foreach lib,$(SH_LIBRARIES),-l$(lib)) -o $@
	$(SH_NM) $(SH_PROGRAM).elf > $(SH_PROGRAM).sym
	$(SH_OBJDUMP) -S $(SH_PROGRAM).elf > $(SH_PROGRAM).asm

./romdisk/$(M68K_PROGRAM).m68k: $(M68K_PROGRAM).m68k.elf
	$(M68K_OBJCOPY) -O binary $< $@
	chmod -x $@
	@du -hs $@ | awk '{ print $$1 " ""'"($@)"'" }'

$(M68K_PROGRAM).m68k.elf: $(M68K_OBJECTS)
	$(M68K_LD) $(M68K_OBJECTS) $(M68K_LDFLAGS) -o $@
	$(M68K_NM) $(M68K_PROGRAM).m68k.elf > $(M68K_PROGRAM).m68k.sym

./romdisk:
	mkdir -p $@

%.romdisk: ./romdisk $(ROMDISK_DEPS)
	$(INSTALL_ROOT)/bin/genromfs -a 16 -v -V "ROOT" -d ./romdisk/ -f $@

%.romdisk.o: %.romdisk
	$(INSTALL_ROOT)/bin/fsck.genromfs ./romdisk/
	$(INSTALL_ROOT)/bin/bin2o $< `echo "$<" | sed -E 's/[\. ]/_/g'` $@

%.o: %.c
	$(SH_CC) $(SH_CFLAGS) -specs=$(SH_SPECS) -Wp,-MMD,$*.d -c -o $@ $<

%.o: %.cc
	$(SH_CXX) $(SH_CXXFLAGS) -specs=$(SH_SPECS) -Wp,-MMD,$*.d -c -o $@ $<

%.o: %.C
	$(SH_CXX) $(SH_CXXFLAGS) -specs=$(SH_SPECS) -Wp,-MMD,$*.d -c -o $@ $<

%.o: %.cpp
	$(SH_CXX) $(SH_CXXFLAGS) -specs=$(SH_SPECS) -Wp,-MMD,$*.d -c -o $@ $<

%.o: %.cxx
	$(SH_CXX) $(SH_CXXFLAGS) -specs=$(SH_SPECS) -Wp,-MMD,$*.d -c -o $@ $<

%.o: %.S
	$(SH_AS) $(SH_AFLAGS) -o $@ $<

%.m68k.o: %.m68k.S
	$(M68K_AS) $(M68K_AFLAGS) -o $@ $<

$(SH_PROGRAM).iso: $(SH_PROGRAM).bin IP.BIN $(shell find $(IMAGE_DIRECTORY)/ -type f)
	mkdir -p $(IMAGE_DIRECTORY)
	cp $(SH_PROGRAM).bin $(IMAGE_DIRECTORY)/$(IMAGE_1ST_READ_BIN)
	for txt in "ABS.TXT" "BIB.TXT" "CPY.TXT"; do \
	    if ! [ -s $(IMAGE_DIRECTORY)/$$txt ]; then \
	        printf -- "empty\n" > $(IMAGE_DIRECTORY)/$$txt; \
	    fi \
	done
	$(INSTALL_ROOT)/bin/make-iso $(IMAGE_DIRECTORY) $(SH_PROGRAM)

IP.BIN: $(INSTALL_ROOT)/sh-elf/share/yaul/bootstrap/ip.S
	$(eval $@_TMP_FILE:= $(shell mktemp))
	cat $< | awk ' \
	/\.ascii \"\$$VERSION\"/ { sub(/\$$VERSION/, "$(IP_VERSION)"); } \
	/\.ascii \"\$$RELEASE_DATE\"/ { sub(/\$$RELEASE_DATE/, "$(IP_RELEASE_DATE)"); } \
	/\.ascii \"\$$AREAS\"/ { printf ".ascii \"%-10.10s\"\n", "$(IP_AREAS)"; next; } \
	/\.ascii \"\$$PERIPHERALS\"/ { printf ".ascii \"%-16.16s\"\n", "$(IP_PERIPHERALS)"; next; } \
	/\.ascii \"\$$TITLE\"/ { \
            L = 7; \
            # Truncate to 112 characters \
            s = "$(IP_TITLE)"; \
            # Strip out control characters \
            gsub(/[\t\r\v\n\f]/, "", s); \
            s = substr(s, 0, 112); \
            t = s; \
            q = length(s); \
            l = q; \
            while (l > 0) { \
                printf ".ascii \"%-16.16s\"\n", t; \
                a = ((l - 16) >= 0) ? 16 : l; \
                l -= a; \
                t = substr(t, a + 1, q - a); \
                L--; \
            } \
            while (L > 0) { \
                printf ".ascii \"                \"\n"; \
                L--; \
            } \
            next; \
        } \
	/\.long \$$MASTER_STACK_ADDR/ { sub(/\$$MASTER_STACK_ADDR/, "$(IP_MASTER_STACK_ADDR)"); } \
	/\.long \$$SLAVE_STACK_ADDR/ { sub(/\$$SLAVE_STACK_ADDR/, "$(IP_SLAVE_STACK_ADDR)"); } \
	/\.long \$$1ST_READ_ADDR/ { sub(/\$$1ST_READ_ADDR/, "$(IP_1ST_READ_ADDR)"); } \
	{ print; } \
	' | $(SH_AS) $(SH_AFLAGS) \
		-I$(INSTALL_ROOT)/sh-elf/share/yaul/bootstrap -o $($@_TMP_FILE) -
	$(SH_CC) -Wl,-Map,$@.map -nostdlib -m2 -mb -nostartfiles \
	-specs=ip.specs $($@_TMP_FILE) -o $@
	$(RM) $($@_TMP_FILE)

clean:
	-rm -f \
		$(SH_PROGRAM).bin \
		$(SH_PROGRAM).iso \
		$(SH_OBJECTS) \
		$(SH_DEPS) \
		$(SH_PROGRAM).asm \
		$(SH_PROGRAM).bin \
		$(SH_PROGRAM).elf \
		$(SH_PROGRAM).map \
		$(SH_PROGRAM).sym \
		$(SH_OBJECTS_NO_LINK) \
		$(SH_DEPS_NO_LINK) \
		IP.BIN \
		IP.BIN.map
ifneq ($(strip $(M68K_PROGRAM)),)
	-rm -f \
	        romdisk/$(M68K_PROGRAM).m68k \
	        $(M68K_PROGRAM).m68k.elf \
	        $(M68K_PROGRAM).m68k.sym \
	        $(M68K_OBJECTS)
endif

list-targets:
	@$(MAKE) -pRrq -f $(firstword $(MAKEFILE_LIST)) : 2>/dev/null | \
	awk -v RS= -F: '/^# File/,/^# Finished Make data base/ {if ($$1 !~ "^[#.]") {print $$1}}' | \
	sort | \
	grep -E -v -e '^[^[:alnum:]]' -e '^$@$$'

-include $(SH_DEPS)
-include $(SH_DEPS_NO_LINK)
