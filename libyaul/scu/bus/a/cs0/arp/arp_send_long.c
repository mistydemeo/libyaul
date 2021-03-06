/*
 * Copyright (c) 2012-2016 Israel Jacquez
 * See LICENSE for details.
 *
 * Israel Jacquez <mrkotfw@gmail.com>
 */

#include <arp.h>

#include "arp-internal.h"

void
arp_send_long(uint32_t w)
{

        arp_xchg_byte((w >> 24));
        arp_xchg_byte((w >> 16));
        arp_xchg_byte((w >> 8));
        arp_xchg_byte((w & 0xFF));
}
