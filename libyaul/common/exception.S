/*
 * Copyright (c) 2012-2016 Israel Jacquez
 * See LICENSE for details.
 *
 * Israel Jacquez <mrkotfw@gmail.com>
 */

.macro MACRO_EXCEPTION_TRAMPOLINE handler
        /* At this point, PC and SR have been pushed onto the stack by
         * the CPU */
        sts.l pr, @-r15
        stc.l gbr, @-r15
        stc.l vbr, @-r15
        sts.l mach, @-r15
        sts.l macl, @-r15
        mov.l r14, @-r15
        mov.l r13, @-r15
        mov.l \handler, r14
        mov.l r12, @-r15
        mov r15, r13
        mov.l r11, @-r15
        add #0x28, r13
        mov.l r10, @-r15
        mov.l r9, @-r15
        mov.l r8, @-r15
        mov.l r7, @-r15
        mov.l r6, @-r15
        mov.l r5, @-r15
        mov.l r4, @-r15
        mov.l r3, @-r15
        mov.l r2, @-r15
        mov.l r1, @-r15
        mov.l r0, @-r15
        mov.l r13, @-r15
        jmp @r14
        mov r15, r4
.endm

.text

.align 4
.global _exception_illegal_instruction
.type _exception_illegal_instruction, @function

_exception_illegal_instruction:
        MACRO_EXCEPTION_TRAMPOLINE .LC1

.align 4
.global _exception_illegal_slot
.type _exception_illegal_slot, @function

_exception_illegal_slot:
        MACRO_EXCEPTION_TRAMPOLINE .LC2

.align 4
.global _exception_cpu_address_error
.type _exception_cpu_address_error, @function

_exception_cpu_address_error:
        MACRO_EXCEPTION_TRAMPOLINE .LC3

.align 4
.global _exception_dma_address_error
.type _exception_dma_address_error, @function

_exception_dma_address_error:
        MACRO_EXCEPTION_TRAMPOLINE .LC4

.align 2

.LC1:
.long _exception_ihr_illegal_instruction

.LC2:
.long _exception_ihr_illegal_slot

.LC3:
.long _exception_ihr_cpu_address_error

.LC4:
.long _exception_ihr_dma_address_error
