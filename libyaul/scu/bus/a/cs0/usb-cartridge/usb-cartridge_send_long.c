/*
 * Copyright (c) 2012-2016
 * See LICENSE for details.
 *
 * Anders Montonen 
 * Israel Jacquez <mrkotfw@gmail.com>
 */

#include <usb-cartridge.h>

#include "usb-cartridge-internal.h"

void
usb_cartridge_send_long(uint32_t w)
{

        usb_cartridge_send_byte((w >> 24));
        usb_cartridge_send_byte((w >> 16));
        usb_cartridge_send_byte((w >> 8));
        usb_cartridge_send_byte((w & 0xFF));
}
