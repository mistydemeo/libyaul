/*
 * Copyright (c) 2012-2016 Israel Jacquez
 * See LICENSE for details.
 *
 * Israel Jacquez <mrkotfw@gmail.com>
 */

#include <vdp2/scrn.h>

#include <assert.h>

#include "vdp2-internal.h"

void
vdp2_scrn_reduction_y_set(uint8_t scrn, fix16_t scale)
{
#ifdef DEBUG
        /* Check if the background passed is valid */
        assert((scrn == SCRN_NBG0) ||
               (scrn == SCRN_NBG1));
#endif /* DEBUG */

        scale = fix16_clamp(scale, SCRN_REDUCTION_MIN, SCRN_REDUCTION_MAX);

        uint16_t in;
        in = fix16_to_int(scale) & 0x0007;

        /* Only take into account the upper 8 bits of the fractional */
        uint16_t dn;
        dn = fix16_sub(scale, fix16_from_int(in)) & 0xFF00;

        switch (scrn) {
        case SCRN_NBG0:
                /* Write to memory */
                MEMORY_WRITE(16, VDP2(ZMYIN0), in);
                MEMORY_WRITE(16, VDP2(ZMYDN0), dn);
                break;
        case SCRN_NBG1:
                /* Write to memory */
                MEMORY_WRITE(16, VDP2(ZMYIN1), in);
                MEMORY_WRITE(16, VDP2(ZMYDN1), dn);
                break;
        default:
                return;
        }
}
