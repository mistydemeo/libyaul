# -*- mode: makefile -*-

BOOTSTRAP_FILES:= \
	common/bootstrap/ip.S \
	common/bootstrap/sys_aree.bin \
	common/bootstrap/sys_arej.bin \
	common/bootstrap/sys_aret.bin \
	common/bootstrap/sys_areu.bin \
	common/bootstrap/sys_init.bin \
	common/bootstrap/sys_sec.bin

USER_FILES:= \
	common/pre.common.mk \
	common/post.common.mk

LDSCRIPTS:= \
	common/ldscripts/yaul.x \
	common/ldscripts/ip.x

SPECS:= \
	common/specs/yaul.specs \
	common/specs/ip.specs

SUPPORT_SRCS:= \
	common/crt0.S \
	common/crt0-init.c \
	common/c++-support.cxx

LIB_SRCS:= \
	common/exception.S \
	common/exception_handler.c \
	common/stack.c

ifneq ($(strip $(OPTION_DEV_CARTRIDGE)),0)
LIB_SRCS+= \
	common/gdb/gdb.c \
	common/gdb/ihr.S \
	common/gdb/sh2-704x.c
endif

LIB_SRCS+= \
	cons/cons.c \
	cons/drivers/vdp1.c \
	cons/drivers/vdp2.c \
	cons/font/font.c \
	cons/vt_parse/vt_parse.c \
	cons/vt_parse/vt_parse_table.c \
	\
	kernel/sys/init.c \
	kernel/sys/irq-mux.c \
	\
	kernel/lib/memb.c \
	\
	kernel/mm/slob.c \
	\
	lib/ctype/ctype.c \
	lib/ctype/isalpha.c \
	lib/ctype/isascii.c \
	lib/ctype/isblank.c \
	lib/ctype/iscntrl.c \
	lib/ctype/isdigit.c \
	lib/ctype/islower.c \
	lib/ctype/isprint.c \
	lib/ctype/isgraph.c \
	lib/ctype/ispunct.c \
	lib/ctype/isspace.c \
	lib/ctype/isupper.c \
	lib/ctype/isxdigit.c \
	lib/string/memcpy.c \
	lib/string/memset.c \
	lib/string/strchr.c \
	lib/string/strcmp.c \
	lib/string/strlen.c \
	lib/string/strchr.c \
	lib/string/strncmp.c \
	lib/stdio/snprintf.c \
	lib/stdlib/abort.c \
	lib/stdlib/assert.c \
	lib/stdlib/free.c \
	lib/stdlib/malloc.c \
	lib/stdlib/realloc.c \
	\
	kernel/vfs/fs/iso9660/iso9660.c \
	\
	kernel/vfs/fs/romdisk/romdisk.c

ifeq ($(strip $(OPTION_DEV_CARTRIDGE)),2)
LIB_SRCS+= \
	scu/bus/a/cs0/arp/arp_busy_status.c \
	scu/bus/a/cs0/arp/arp_function_callback.c \
	scu/bus/a/cs0/arp/arp_function_nonblock.c \
	scu/bus/a/cs0/arp/arp_read_byte.c \
	scu/bus/a/cs0/arp/arp_read_long.c \
	scu/bus/a/cs0/arp/arp_return.c \
	scu/bus/a/cs0/arp/arp_send_long.c \
	scu/bus/a/cs0/arp/arp_sync.c \
	scu/bus/a/cs0/arp/arp_sync_nonblock.c \
	scu/bus/a/cs0/arp/arp_version.c \
	scu/bus/a/cs0/arp/arp_xchg_byte.c
endif

LIB_SRCS+= \
	scu/bus/a/cs0/dram-cartridge/dram-cartridge_area.c \
	scu/bus/a/cs0/dram-cartridge/dram-cartridge_id.c \
	scu/bus/a/cs0/dram-cartridge/dram-cartridge_init.c \
	scu/bus/a/cs0/dram-cartridge/dram-cartridge_size.c

ifeq ($(strip $(OPTION_DEV_CARTRIDGE)),1)
LIB_SRCS+= \
	scu/bus/a/cs0/usb-cartridge/usb-cartridge_init.c \
	scu/bus/a/cs0/usb-cartridge/usb-cartridge_read_byte.c \
	scu/bus/a/cs0/usb-cartridge/usb-cartridge_read_long.c \
	scu/bus/a/cs0/usb-cartridge/usb-cartridge_return.c \
	scu/bus/a/cs0/usb-cartridge/usb-cartridge_send_byte.c \
	scu/bus/a/cs0/usb-cartridge/usb-cartridge_send_long.c \
	scu/bus/a/cs0/usb-cartridge/usb-cartridge_xchg_byte.c
endif

LIB_SRCS+= \
	math/color.c \
	math/fix16.c \
	math/fix16_exp.c \
	math/fix16_matrix3.c \
	math/fix16_matrix4.c \
	math/fix16_sqrt.c \
	math/fix16_str.c \
	math/fix16_trig.c \
	math/fix16_vector2.c \
	math/fix16_vector3.c \
	math/fix16_vector4.c \
	math/fract32.c \
	math/int16_vector2.c \
	math/uint32.c \
	scu/bus/a/cs2/cd-block/cd-block_cmd_abort_file.c \
	scu/bus/a/cs2/cd-block/cd-block_cmd_init_cd_system.c \
	scu/bus/a/cs2/cd-block/cd-block_execute.c \
	scu/bus/a/cs2/cd-block/cd-block_init.c \
	\
	scu/bus/b/scsp/scsp_init.c \
	\
	scu/bus/b/vdp1/vdp1_cmdt.c \
	scu/bus/b/vdp1/vdp1_init.c \
	\
	scu/bus/b/vdp2/vdp2-internal.c \
	scu/bus/b/vdp2/vdp2_init.c \
	scu/bus/b/vdp2/vdp2_scrn_back_screen_addr_set.c \
	scu/bus/b/vdp2/vdp2_scrn_back_screen_color_set.c \
	scu/bus/b/vdp2/vdp2_scrn_bitmap_format_set.c \
	scu/bus/b/vdp2/vdp2_scrn_cell_format_get.c \
	scu/bus/b/vdp2/vdp2_scrn_cell_format_set.c \
	scu/bus/b/vdp2/vdp2_scrn_color_offset_clear.c \
	scu/bus/b/vdp2/vdp2_scrn_color_offset_rgb_set.c \
	scu/bus/b/vdp2/vdp2_scrn_color_offset_set.c \
	scu/bus/b/vdp2/vdp2_scrn_color_offset_unset.c \
	scu/bus/b/vdp2/vdp2_scrn_display_clear.c \
	scu/bus/b/vdp2/vdp2_scrn_display_set.c \
	scu/bus/b/vdp2/vdp2_scrn_display_unset.c \
	scu/bus/b/vdp2/vdp2_scrn_ls_set.c \
	scu/bus/b/vdp2/vdp2_scrn_mosaic_clear.c \
	scu/bus/b/vdp2/vdp2_scrn_mosaic_horizontal_set.c \
	scu/bus/b/vdp2/vdp2_scrn_mosaic_set.c \
	scu/bus/b/vdp2/vdp2_scrn_mosaic_unset.c \
	scu/bus/b/vdp2/vdp2_scrn_mosaic_vertical_set.c \
	scu/bus/b/vdp2/vdp2_scrn_priority_set.c \
	scu/bus/b/vdp2/vdp2_scrn_reduction_set.c \
	scu/bus/b/vdp2/vdp2_scrn_reduction_x_set.c \
	scu/bus/b/vdp2/vdp2_scrn_reduction_y_set.c \
	scu/bus/b/vdp2/vdp2_scrn_scroll_set.c \
	scu/bus/b/vdp2/vdp2_scrn_scroll_update.c \
	scu/bus/b/vdp2/vdp2_scrn_vcs_set.c \
	scu/bus/b/vdp2/vdp2_sprite_type_priority_get.c \
	scu/bus/b/vdp2/vdp2_sprite_type_priority_set.c \
	scu/bus/b/vdp2/vdp2_sprite_type_set.c \
	scu/bus/b/vdp2/vdp2_tvmd_display_clear.c \
	scu/bus/b/vdp2/vdp2_tvmd_display_res_set.c \
	scu/bus/b/vdp2/vdp2_tvmd_display_set.c \
	scu/bus/b/vdp2/vdp2_tvmd_hblank_in_irq_get.c \
	scu/bus/b/vdp2/vdp2_tvmd_vblank_in_irq_get.c \
	scu/bus/b/vdp2/vdp2_tvmd_vblank_out_irq_get.c \
	scu/bus/b/vdp2/vdp2_vram_control_get.c \
	scu/bus/b/vdp2/vdp2_vram_control_set.c \
	\
	scu/bus/cpu/cpu_clock_freq_chg.S \
	scu/bus/cpu/cpu_clock_freq_get.S \
	scu/bus/cpu/cpu_dmac_channel_set.c \
	scu/bus/cpu/cpu_dmac_channel_start.c \
	scu/bus/cpu/cpu_dmac_channel_stop.c \
	scu/bus/cpu/cpu_intc_disable.S \
	scu/bus/cpu/cpu_intc_enable.S \
	scu/bus/cpu/cpu_intc_interrupt_get.S \
	scu/bus/cpu/cpu_intc_interrupt_set.S \
	scu/bus/cpu/cpu_intc_mask_get.S \
	scu/bus/cpu/cpu_intc_mask_set.S \
	scu/bus/cpu/cpu_intc_vector_base_get.S \
	scu/bus/cpu/cpu_intc_vector_base_set.S \
	scu/bus/cpu/cpu_intc_vector_table.S \
	scu/bus/cpu/cpu_ubc_init.c \
	\
	scu/bus/cpu/smpc/smpc_init.c \
	scu/bus/cpu/smpc/smpc_peripheral_analog_port.c \
	scu/bus/cpu/smpc/smpc_peripheral_digital_get.c \
	scu/bus/cpu/smpc/smpc_peripheral_digital_port.c \
	scu/bus/cpu/smpc/smpc_peripheral_init.c \
	scu/bus/cpu/smpc/smpc_peripheral_keyboard_port.c \
	scu/bus/cpu/smpc/smpc_peripheral_mouse_port.c \
	scu/bus/cpu/smpc/smpc_peripheral_racing_port.c \
	scu/bus/cpu/smpc/smpc_peripheral_raw_port.c \
	scu/bus/cpu/smpc/smpc_rtc_settime_call.c \
	scu/bus/cpu/smpc/smpc_smc_call.c \
	scu/bus/cpu/smpc/smpc_smc_cdoff_call.c \
	scu/bus/cpu/smpc/smpc_smc_cdon_call.c \
	scu/bus/cpu/smpc/smpc_smc_ckchg320_call.c \
	scu/bus/cpu/smpc/smpc_smc_ckchg352_call.c \
	scu/bus/cpu/smpc/smpc_smc_intback_call.c \
	scu/bus/cpu/smpc/smpc_smc_mshon_call.c \
	scu/bus/cpu/smpc/smpc_smc_nmireq_call.c \
	scu/bus/cpu/smpc/smpc_smc_resdisa_call.c \
	scu/bus/cpu/smpc/smpc_smc_resenab_call.c \
	scu/bus/cpu/smpc/smpc_smc_setsmem_call.c \
	scu/bus/cpu/smpc/smpc_smc_sndoff_call.c \
	scu/bus/cpu/smpc/smpc_smc_sndon_call.c \
	scu/bus/cpu/smpc/smpc_smc_sshoff_call.c \
	scu/bus/cpu/smpc/smpc_smc_sshon_call.c \
	scu/bus/cpu/smpc/smpc_smc_sysres_call.c \
	\
	scu/scu_dma_cpu_init.c \
	scu/scu_dma_cpu_level_set.c \
	scu/scu_dma_cpu_level_start.c \
	scu/scu_dma_cpu_level_stop.c \
	scu/scu_dsp_init.c \
	scu/scu_ic_interrupt_get.S \
	scu/scu_ic_interrupt_set.S \
	scu/scu_ic_mask_chg.S \
	scu/scu_ic_mask_get.S \
	scu/scu_ic_mask_set.S \
	scu/scu_ic_status_get.c \
	scu/scu_timer_0_set.c \
	scu/scu_timer_1_mode_clear.c \
	scu/scu_timer_1_mode_set.c \
	scu/scu_timer_1_set.c \
	scu/scu_timer_all_disable.c \
	scu/scu_timer_all_enable.c

INCLUDE_DIRS:= \
	common \
	common/gdb \
	cons \
	lib/lib \
	kernel \
	kernel/vfs \
	math \
	scu \
	scu/bus/a/cs0/arp \
	scu/bus/a/cs0/dram-cartridge \
	scu/bus/a/cs0/usb-cartridge \
	scu/bus/a/cs2/cd-block \
	scu/bus/b/scsp \
	scu/bus/b/vdp1 \
	scu/bus/b/vdp2 \
	scu/bus/cpu \
	scu/bus/cpu/smpc

HEADER_FILES:= \
	./yaul.h \
	./common/bootstrap/ip.h

INSTALL_HEADER_FILES:= \
	./:yaul.h:./yaul/

INSTALL_HEADER_FILES+= \
	./lib/lib/:_ansi.h:./ \
	./lib/lib/:alloca.h:./ \
	./lib/lib/:assert.h:./ \
	./lib/lib/:ctype.h:./ \
	./lib/lib/:errno.h:./ \
	./lib/lib/:inttypes.h:./ \
	./lib/lib/:stdio.h:./ \
	./lib/lib/:stdlib.h:./ \
	./lib/lib/:string.h:./ \
	./lib/lib/sys/:cdefs.h:./sys/ \
	./lib/lib/sys/:queue.h:./sys/ \
	./lib/lib/sys/:types.h:./sys/

INSTALL_HEADER_FILES+= \
	./math/:color.h:yaul/math/ \
	./math/:fix16.h:yaul/math/ \
	./math/:fract32.h:yaul/math/ \
	./math/:int16.h:yaul/math/ \
	./math/:int64.h:yaul/math/ \
	./math/:math.h:yaul/math/ \
	./math/:uint32.h:yaul/math/

INSTALL_HEADER_FILES+= \
	./common/:stack.h:yaul/common/ \
	./common/bootstrap/:ip.h:yaul/common/ \
	./common/gdb/:gdb.h:yaul/common/gdb/

INSTALL_HEADER_FILES+= \
	./cons/:cons.h:yaul/cons/

INSTALL_HEADER_FILES+= \
	./kernel/lib/:memb.h:yaul/lib/

INSTALL_HEADER_FILES+= \
	./kernel/sys/:irq-mux.h:yaul/sys/

INSTALL_HEADER_FILES+= \
	./kernel/vfs/fs/iso9660/:iso9660.h:yaul/fs/iso9660/ \
	./kernel/vfs/fs/romdisk/:romdisk.h:yaul/fs/romdisk/

INSTALL_HEADER_FILES+= \
	./scu/:scu.h:yaul/scu/ \
	./scu/scu/:dma.h:yaul/scu/scu/ \
	./scu/scu/:dsp.h:yaul/scu/scu/ \
	./scu/scu/:ic.h:yaul/scu/scu/ \
	./scu/scu/:map.h:yaul/scu/scu/ \
	./scu/scu/:timer.h:yaul/scu/scu/

INSTALL_HEADER_FILES+= \
	./scu/bus/a/cs2/cd-block/:cd-block.h:yaul/scu/bus/a/cs2/cd-block/ \
	./scu/bus/a/cs2/cd-block/cd-block/:cmd.h:yaul/scu/bus/a/cs2/cd-block/cd-block/ \
	\
	./scu/bus/a/cs0/dram-cartridge/:dram-cartridge.h:yaul/scu/bus/a/cs0/dram-cartridge/ \
	./scu/bus/a/cs0/dram-cartridge/:dram-cartridge/map.h:yaul/scu/bus/a/cs0/dram-cartridge/

ifeq ($(strip $(OPTION_DEV_CARTRIDGE)),2)
INSTALL_HEADER_FILES+= \
	./scu/bus/a/cs0/arp/:arp.h:yaul/scu/bus/a/cs0/arp/ \
	./scu/bus/a/cs0/arp/arp/:map.h:yaul/scu/bus/a/cs0/arp/arp/
endif

ifeq ($(strip $(OPTION_DEV_CARTRIDGE)),1)
INSTALL_HEADER_FILES+= \
	./scu/bus/a/cs0/usb-cartridge/:usb-cartridge.h:yaul/scu/bus/a/cs0/usb-cartridge/ \
	./scu/bus/a/cs0/usb-cartridge/usb-cartridge/:map.h:yaul/scu/bus/a/cs0/usb-cartridge/usb-cartridge/
endif

INSTALL_HEADER_FILES+= \
	./scu/bus/b/scsp/:scsp.h:yaul/scu/bus/b/scsp/ \
	\
	./scu/bus/b/vdp1/:vdp1.h:yaul/scu/bus/b/vdp1/ \
	./scu/bus/b/vdp1/vdp1/:cmdt.h:yaul/scu/bus/b/vdp1/vdp1/ \
	./scu/bus/b/vdp1/vdp1/:map.h:yaul/scu/bus/b/vdp1/vdp1/ \
	./scu/bus/b/vdp1/vdp1/:vram.h:yaul/scu/bus/b/vdp1/vdp1/ \
	\
	./scu/bus/b/vdp2/:vdp2.h:yaul/scu/bus/b/vdp2/ \
	./scu/bus/b/vdp2/vdp2/:cram.h:yaul/scu/bus/b/vdp2/vdp2/ \
	./scu/bus/b/vdp2/vdp2/:map.h:yaul/scu/bus/b/vdp2/vdp2/ \
	./scu/bus/b/vdp2/vdp2/:scrn.h:yaul/scu/bus/b/vdp2/vdp2/ \
	./scu/bus/b/vdp2/vdp2/:sprite.h:yaul/scu/bus/b/vdp2/vdp2/ \
	./scu/bus/b/vdp2/vdp2/:tvmd.h:yaul/scu/bus/b/vdp2/vdp2/ \
	./scu/bus/b/vdp2/vdp2/:vram.h:yaul/scu/bus/b/vdp2/vdp2/ \
	\
	./scu/bus/cpu/:cpu.h:yaul/scu/bus/cpu/ \
	./scu/bus/cpu/cpu/:dmac.h:yaul/scu/bus/cpu/cpu/ \
	./scu/bus/cpu/cpu/:intc.h:yaul/scu/bus/cpu/cpu/ \
	./scu/bus/cpu/cpu/:map.h:yaul/scu/bus/cpu/cpu/ \
	./scu/bus/cpu/cpu/:registers.h:yaul/scu/bus/cpu/cpu/ \
	./scu/bus/cpu/cpu/:ubc.h:yaul/scu/bus/cpu/cpu/ \
	\
	./scu/bus/cpu/smpc/:smpc.h:yaul/scu/bus/cpu/smpc/ \
	./scu/bus/cpu/smpc/smpc/:peripheral.h:yaul/scu/bus/cpu/smpc/smpc/ \
	./scu/bus/cpu/smpc/smpc/:map.h:yaul/scu/bus/cpu/smpc/smpc/ \
	./scu/bus/cpu/smpc/smpc/:rtc.h:yaul/scu/bus/cpu/smpc/smpc/ \
	./scu/bus/cpu/smpc/smpc/:smc.h:yaul/scu/bus/cpu/smpc/smpc/
