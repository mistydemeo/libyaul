/*
 * Copyright (c) 2012 Israel Jacques
 * See LICENSE for details.
 *
 * Israel Jacques <mrko@eecs.berkeley.edu>
 */

#include <cpu/dmac.h>
#include <cpu/intc.h>

#include <assert.h>

#include "cpu_internal.h"

void
cpu_dmac_channel_set(struct cpu_channel_cfg *cfg)
{
        uint32_t len;
        uint32_t chcr;
        uint32_t vcrdma;

        switch (cfg->ch) {
        case CPU_DMAC_CHANNEL(0):
                /* Cleared by reading 1 from the TE bit and then writing
                 * zero */
                chcr = MEMORY_READ(32, CPU(CHCR0));

                /* Immediately disable channel */
                chcr &= 0xFFFFFFFC;
                MEMORY_WRITE(32, CPU(CHCR0), chcr);
                break;
        case CPU_DMAC_CHANNEL(1):
                /* Cleared by reading 1 from the TE bit and then writing
                 * zero */
                chcr = MEMORY_READ(32, CPU(CHCR1));

                /* Immediately disable channel */
                chcr &= 0xFFFFFFFC;
                MEMORY_WRITE(32, CPU(CHCR1), chcr);
                break;
        default:
                assert((cfg->ch == CPU_DMAC_CHANNEL(0)) ||
                    (cfg->ch == CPU_DMAC_CHANNEL(1)));
        }

        /* Source and destination address modes */
        chcr = cfg->src.mode | cfg->dst.mode;

        /* Able to transfer at most 16MiB exclusive when TCR0 is
         * 0x00FFFFFF, 16MliB inclusive when TCR0 is 0x00000000 */
        len = cfg->len;
        switch (len) {
        case 1:
                /* Byte unit */
                break;
        case 2:
                /* Word (2-byte) unit */
                chcr |= 0x00000400;
                break;
        case 8:
                /* Long (4-byte) unit */
                chcr |= 0x00000800;
                break;
        case 16:
                /* 16-byte unit */
                chcr |= 0x00000C00;
                /* For 16-byte transfers, set the count to 4
                 * times the number of transfers */
                len <<= 2;
                break;
        default:
                assert((len == 1) || (len == 2) || (len == 16));
                return;
        }

        assert(cfg->len <= 0x01000000);
        len &= 0x00FFFFFF;

        vcrdma = 0x00000000;
        if (cfg->ihr != NULL) {
                assert(cfg->vector <= 0x7F);

                vcrdma = cfg->vector;
                /* Interrupt enable */
                chcr |= 0x00000004;

                /* Set interrupt handling routine */
                cpu_intc_interrupt_set(cfg->vector, (uint32_t)&cfg->ihr);
        }

        switch (cfg->ch) {
        case CPU_DMAC_CHANNEL(0):
                /* Wait until a previous transfer has ended */
                while ((MEMORY_READ(32, CPU(CHCR0)) & 0x00000002) == 0x00000000);

                MEMORY_WRITE(32, CPU(DAR0), (uint32_t)cfg->dst.ptr);
                MEMORY_WRITE(32, CPU(SAR0), (uint32_t)cfg->src.ptr);
                MEMORY_WRITE(32, CPU(TCR0), len);
                MEMORY_WRITE(8, CPU(DRCR0), 0x00);

                /* Set DMA vector number */
                MEMORY_WRITE(32, CPU(VCRDMA0), vcrdma);
                /* Write to memory */
                MEMORY_WRITE(32, CPU(CHCR0), chcr);
                return;
        case CPU_DMAC_CHANNEL(1):
                /* Wait until a previous transfer has ended */
                while ((MEMORY_READ(32, CPU(CHCR1)) & 0x00000002) == 0x00000000);

                MEMORY_WRITE(32, CPU(DAR1), (uint32_t)cfg->dst.ptr);
                MEMORY_WRITE(32, CPU(SAR1), (uint32_t)cfg->src.ptr);
                MEMORY_WRITE(32, CPU(TCR1), len);
                MEMORY_WRITE(8, CPU(DRCR1), 0x00);

                /* Set DMA vector number */
                MEMORY_WRITE(32, CPU(VCRDMA1), vcrdma);
                /* Write to memory */
                MEMORY_WRITE(32, CPU(CHCR1), chcr);
                return;
        }
}