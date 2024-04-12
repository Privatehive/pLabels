/*
  libptouch - functions to help accessing a brother ptouch

  Copyright (C) 2013-2023 Dominic Radermacher <dominic@familie-radermacher.ch>

  This program is free software; you can redistribute it and/or modify it
  under the terms of the GNU General Public License version 3 as
  published by the Free Software Foundation

  This program is distributed in the hope that it will be useful, but
  WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
  See the GNU General Public License for more details.

  You should have received a copy of the GNU General Public License
  along with this program; if not, write to the Free Software Foundation,
  Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA
*/

#define _POSIX_C_SOURCE 199309L /* needed for nanosleep() when using -std=c11 */

#include <fcntl.h> /* open() */
#include <stdio.h>
#include <stdlib.h> /* malloc() */
#include <string.h> /* memcmp()  */
#include <sys/stat.h> /* open() */
#include <sys/types.h> /* open() */
#include <time.h> /* nanosleep(), struct timespec */

#include "gettext.h" /* gettext(), ngettext() */
#include "ptouch.h"

#define _(s) gettext(s)

/* Print area width in 180 DPI pixels */
struct _pt_tape_info tape_info[] = {
 {4, 24, 0.5}, /* 3.5 mm tape */
 {6, 32, 1.0}, /* 6 mm tape */
 {9, 52, 1.0}, /* 9 mm tape */
 {12, 76, 2.0}, /* 12 mm tape */
 {18, 120, 3.0}, /* 18 mm tape */
 {24, 128, 3.0}, /* 24 mm tape */
 {36, 192, 4.5}, /* 36 mm tape */
 {0, 0, 0.0} /* terminating entry */
};

struct _pt_dev_info ptdevs[] = {
 {0x04f9, 0x2007, "PT-2420PC", 128, 180,
  FLAG_RASTER_PACKBITS}, /* 180dpi, 128px, maximum tape width 24mm, must send TIFF compressed pixel data */
 {0x04f9, 0x2011, "PT-2450PC", 128, 180, FLAG_RASTER_PACKBITS},
 {0x04f9, 0x2019, "PT-1950", 128, 180,
  FLAG_RASTER_PACKBITS}, /* 180dpi, apparently 112px printhead ?, maximum tape width 18mm - unconfirmed if it works */
 {0x04f9, 0x201f, "PT-2700", 128, 180, FLAG_NONE},
 {0x04f9, 0x202c, "PT-1230PC", 128, 180, FLAG_NONE}, /* 180dpi, supports tapes up to 12mm - I don't know how much pixels it can print! */
 /* Notes about the PT-1230PC: While it is true that this printer supports
    max 12mm tapes, it apparently expects > 76px data - the first 32px
    must be blank. */
 {0x04f9, 0x202d, "PT-2430PC", 128, 180, FLAG_NONE}, /* 180dpi, maximum 128px */
 {0x04f9, 0x2030, "PT-1230PC (PLite Mode)", 128, 180, FLAG_PLITE},
 {0x04f9, 0x2031, "PT-2430PC (PLite Mode)", 128, 180, FLAG_PLITE},
 {0x04f9, 0x2041, "PT-2730", 128, 180, FLAG_NONE}, /* 180dpi, maximum 128px, max tape width 24mm - reported to work with some quirks */
 /* Notes about the PT-2730: was reported to need 48px whitespace
    within png-images before content is actually printed - can not check this */
 {0x04f9, 0x205e, "PT-H500", 128, 180, FLAG_RASTER_PACKBITS},
 /* Note about the PT-H500: was reported by Eike with the remark that
    it might need some trailing padding */
 {0x04f9, 0x205f, "PT-E500", 128, 180, FLAG_RASTER_PACKBITS},
 /* Note about the PT-E500: was reported by Jesse Becker with the
    remark that it also needs some padding (white pixels) */
 {0x04f9, 0x2061, "PT-P700", 128, 180, FLAG_RASTER_PACKBITS | FLAG_P700_INIT | FLAG_HAS_PRECUT},
 {0x04f9, 0x2062, "PT-P750W", 128, 180, FLAG_RASTER_PACKBITS | FLAG_P700_INIT},
 {0x04f9, 0x2064, "PT-P700 (PLite Mode)", 128, 180, FLAG_PLITE},
 {0x04f9, 0x2065, "PT-P750W (PLite Mode)", 128, 180, FLAG_PLITE},
 {0x04f9, 0x20df, "PT-D410", 128, 180, FLAG_USE_INFO_CMD | FLAG_HAS_PRECUT | FLAG_D460BT_MAGIC},
 {0x04f9, 0x2073, "PT-D450", 128, 180, FLAG_USE_INFO_CMD},
 /* Notes about the PT-D450: I'm unsure if print width really is 128px */
 {0x04f9, 0x20e0, "PT-D460BT", 128, 180, FLAG_P700_INIT | FLAG_USE_INFO_CMD | FLAG_HAS_PRECUT | FLAG_D460BT_MAGIC},
 {0x04f9, 0x2074, "PT-D600", 128, 180, FLAG_RASTER_PACKBITS},
 /* PT-D600 was reported to work, but with some quirks (premature
    cutting of tape, printing maximum of 73mm length) */
 {0x04f9, 0x20e1, "PT-D610BT", 128, 180, FLAG_P700_INIT | FLAG_USE_INFO_CMD | FLAG_HAS_PRECUT | FLAG_D460BT_MAGIC},
 //{0x04f9, 0x200d, "PT-3600", 384, 360, FLAG_RASTER_PACKBITS},
 {0x04f9, 0x20af, "PT-P710BT", 128, 180, FLAG_RASTER_PACKBITS},
 {0, 0, "", 0, 0, 0}};

int ptouch_open(ptouch_dev *ptdev) {
	libusb_device **devs;
	libusb_device *dev;
	libusb_device_handle *handle = NULL;
	struct libusb_device_descriptor desc;
	ssize_t cnt;
	int r, i = 0;

	if((*ptdev = malloc(sizeof(struct _ptouch_dev))) == NULL) {
		fprintf(stderr, _("out of memory\n"));
		return -1;
	}

	(*ptdev)->h = NULL;
	(*ptdev)->devinfo = NULL;
	(*ptdev)->status = NULL;

	if(((*ptdev)->devinfo = malloc(sizeof(struct _pt_dev_info))) == NULL) {
		fprintf(stderr, _("out of memory\n"));
		return -1;
	}
	if(((*ptdev)->status = malloc(sizeof(struct _ptouch_stat))) == NULL) {
		fprintf(stderr, _("out of memory\n"));
		return -1;
	}
	if((libusb_init(NULL)) < 0) {
		fprintf(stderr, _("libusb_init() failed\n"));
		return -1;
	}
	//	libusb_set_debug(NULL, 3);
	if((cnt = libusb_get_device_list(NULL, &devs)) < 0) {
		return -1;
	}
	while((dev = devs[i++]) != NULL) {
		if((r = libusb_get_device_descriptor(dev, &desc)) < 0) {
			fprintf(stderr, _("failed to get device descriptor"));
			libusb_free_device_list(devs, 1);
			return -1;
		}
		for(int k = 0; ptdevs[k].vid > 0; ++k) {
			if((desc.idVendor == ptdevs[k].vid) && (desc.idProduct == ptdevs[k].pid) && (ptdevs[k].flags >= 0)) {
				fprintf(stderr, _("%s found on USB bus %d, device %d\n"), ptdevs[k].name, libusb_get_bus_number(dev),
				        libusb_get_device_address(dev));
				if(ptdevs[k].flags & FLAG_PLITE) {
					printf("Printer is in P-Lite Mode, which is unsupported\n\n");
					printf("Turn off P-Lite mode by changing switch from position EL to position E\n");
					printf("or by pressing the PLite button for ~ 2 seconds (or consult the manual)\n");
					return -1;
				}
				if(ptdevs[k].flags & FLAG_UNSUP_RASTER) {
					printf("Unfortunately, that printer currently is unsupported (it has a different raster data transfer)\n");
					return -1;
				}
				if((r = libusb_open(dev, &handle)) != 0) {
					fprintf(stderr, _("libusb_open error :%s\n"), libusb_error_name(r));
					return -1;
				}
				libusb_free_device_list(devs, 1);
				if((r = libusb_kernel_driver_active(handle, 0)) == 1) {
					if((r = libusb_detach_kernel_driver(handle, 0)) != 0) {
						fprintf(stderr, _("error while detaching kernel driver: %s\n"), libusb_error_name(r));
					}
				}
				if((r = libusb_claim_interface(handle, 0)) != 0) {
					fprintf(stderr, _("interface claim error: %s\n"), libusb_error_name(r));
					return -1;
				}
				(*ptdev)->h = handle;
				(*ptdev)->devinfo->dpi = ptdevs[k].dpi;
				(*ptdev)->devinfo->max_px = ptdevs[k].max_px;
				(*ptdev)->devinfo->flags = ptdevs[k].flags;
				(*ptdev)->devinfo->name = ptdevs[k].name;
				return 0;
			}
		}
	}
	fprintf(stderr, _("No P-Touch printer found on USB (remember to put switch to position E)\n"));
	libusb_free_device_list(devs, 1);
	return -1;
}

int ptouch_close(ptouch_dev ptdev) {
	libusb_release_interface(ptdev->h, 0);
	libusb_close(ptdev->h);
	return 0;
}

int ptouch_send(ptouch_dev ptdev, uint8_t *data, size_t len) {
	int r, tx;

	if((ptdev == NULL) || (len > 128)) {
		return -1;
	}
	if((r = libusb_bulk_transfer(ptdev->h, 0x02, data, (int)len, &tx, 0)) != 0) {
		fprintf(stderr, _("write error: %s\n"), libusb_error_name(r));
		return -1;
	}
	if(tx != (int)len) {
		fprintf(stderr, _("write error: could send only %i of %ld bytes\n"), tx, len);
		return -1;
	}
	return 0;
}

int ptouch_init(ptouch_dev ptdev) {
	/* first invalidate, then send init command */
	uint8_t cmd[102];
	memset(cmd, 0, 100);
	cmd[100] = 0x1b; /* ESC */
	cmd[101] = 0x40; /* @ */
	return ptouch_send(ptdev, (uint8_t *)cmd, sizeof(cmd));
}

/* Sends some magic commands to make prints work on the PT-D460BT.
   These should go out after info_cmd and right before the raster data. */
int ptouch_send_d460bt_magic(ptouch_dev ptdev) {
	/* 1B 69 64 {n1} {n2} {n3} {n4} */
	uint8_t cmd[7];
	/* n1 and n2 are the length margin/spacing, in px? (uint16_t value, little endian) */
	/* A value of 0x06 is equivalent to the width margin on 6mm tape */
	/* The default for P-Touch software is 0x0e */
	/* n3 must be 0x4D or the print gets corrupted! */
	/* n4 seems to be ignored or reserved. */
	memcpy(cmd, "\x1b\x69\x64\x0e\x00\x4d\x00", 7);
	return ptouch_send(ptdev, (uint8_t *)cmd, sizeof(cmd));
}

int ptouch_enable_packbits(ptouch_dev ptdev) { /* 4D 00 = disable compression */
	char cmd[] = "M\x02"; /* 4D 02 = enable packbits compression mode */
	return ptouch_send(ptdev, (uint8_t *)cmd, strlen(cmd));
}

/* print information command */
int ptouch_info_cmd(ptouch_dev ptdev, int size_x) {
	/* 1B 69 7A {n1} {n2} {n3} {n4} {n5} {n6} {n7} {n8} {n9} {n10} */
	uint8_t cmd[] = "\x1b\x69\x7a\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00";

	/* {n3}: Media width (mm)
	   {n4}: Media length (mm)
	   For the media of width 24 mm, specify as n3 = 18h and n4 = 00h.
	   n4 is normally 00h, regardless of the paper length. */
	cmd[5] = ptdev->status->media_width;

	/* {n5} -{n8}: Raster number
	   n8*256*256*256 + n7*256*256 + n6*256 + n5 */
	cmd[7] = (uint8_t)size_x & 0xff;
	cmd[8] = (uint8_t)(size_x >> 8) & 0xff;
	cmd[9] = (uint8_t)(size_x >> 16) & 0xff;
	cmd[10] = (uint8_t)(size_x >> 24) & 0xff;
	if((ptdev->devinfo->flags & FLAG_D460BT_MAGIC) == FLAG_D460BT_MAGIC) {
		/* n9 is set to 2 in order to feed the last of the label and properly stop printing. */
		cmd[11] = (uint8_t)0x02;
	}
	return ptouch_send(ptdev, cmd, sizeof(cmd) - 1);
}

/* If set, printer will prompt to cut blank tape before finishing the print.
 If not set, printer will print normally with a big blank space on the label.
 The printer ignores this value if the print is very short. */
/* 0x80 horizontally mirrors the print */
int ptouch_send_precut_cmd(ptouch_dev ptdev, int precut) {
	char cmd[] = "\x1b\x69\x4d\x00";
	if(precut) {
		cmd[3] = 0x40;
	}
	return ptouch_send(ptdev, (uint8_t *)cmd, sizeof(cmd) - 1);
}

int ptouch_rasterstart(ptouch_dev ptdev) {
	/* 1B 69 52 01 = Select graphics transfer mode = Raster */
	char cmd[] = "\x1b\x69\x52\x01";
	/* 1B 69 61 01 = switch mode (0=esc/p, 1=raster mode) */
	char cmd2[] = "\x1b\x69\x61\x01";
	if(ptdev->devinfo->flags & FLAG_P700_INIT) {
		return ptouch_send(ptdev, (uint8_t *)cmd2, strlen(cmd2));
	} /* else */
	return ptouch_send(ptdev, (uint8_t *)cmd, strlen(cmd));
}

/* print an empty line */
int ptouch_lf(ptouch_dev ptdev) {
	char cmd[] = "\x5a";
	return ptouch_send(ptdev, (uint8_t *)cmd, strlen(cmd));
}

/* print and advance tape, but do not cut */
int ptouch_ff(ptouch_dev ptdev) {
	char cmd[] = "\x0c";
	return ptouch_send(ptdev, (uint8_t *)cmd, strlen(cmd));
}

/* print and cut tape */
int ptouch_eject(ptouch_dev ptdev) {
	char cmd[] = "\x1a";
	return ptouch_send(ptdev, (uint8_t *)cmd, strlen(cmd));
}

void ptouch_rawstatus(uint8_t raw[32]) {
	fprintf(stderr, _("debug: dumping raw status bytes\n"));
	for(int i = 0; i < 32; ++i) {
		fprintf(stderr, "%02x ", raw[i]);
		if(((i + 1) % 16) == 0) {
			fprintf(stderr, "\n");
		}
	}
	fprintf(stderr, "\n");
	return;
}

int ptouch_getstatus(ptouch_dev ptdev) {
	char cmd[] = "\x1biS"; /* 1B 69 53 = ESC i S = Status info request */
	uint8_t buf[32];
	int i, r, tx = 0, tries = 0;
	struct timespec w;

	ptouch_send(ptdev, (uint8_t *)cmd, strlen(cmd));
	while(tx == 0) {
		w.tv_sec = 0;
		w.tv_nsec = 100000000; /* 0.1 sec */
		r = nanosleep(&w, NULL);
		if((r = libusb_bulk_transfer(ptdev->h, 0x81, buf, 32, &tx, 0)) != 0) {
			fprintf(stderr, _("read error: %s\n"), libusb_error_name(r));
			return -1;
		}
		++tries;
		if(tries > 10) {
			fprintf(stderr, _("timeout while waiting for status response\n"));
			return -1;
		}
	}
	if(tx == 32) {
		if(buf[0] == 0x80 && buf[1] == 0x20) {
			memcpy(ptdev->status, buf, 32);
			ptdev->tape_width_px = 0;
			for(i = 0; tape_info[i].mm > 0; ++i) {
				if(tape_info[i].mm == buf[10]) {
					ptdev->tape_width_px = tape_info[i].px;
				}
			}
			if(ptdev->tape_width_px == 0) {
				fprintf(stderr, _("unknown tape width of %imm, please report this.\n"), buf[10]);
			}
			return 0;
		}
	}
	if(tx == 16) {
		fprintf(stderr, _("got only 16 bytes... wondering what they are:\n"));
		ptouch_rawstatus(buf);
	}
	if(tx != 32) {
		fprintf(stderr, _("read error: got %i instead of 32 bytes\n"), tx);
		return -1;
	}
	fprintf(stderr, _("strange status:\n"));
	ptouch_rawstatus(buf);
	fprintf(stderr, _("trying to flush junk\n"));
	if((r = libusb_bulk_transfer(ptdev->h, 0x81, buf, 32, &tx, 0)) != 0) {
		fprintf(stderr, _("read error: %s\n"), libusb_error_name(r));
		return -1;
	}
	fprintf(stderr, _("got another %i bytes. now try again\n"), tx);
	return -1;
}

size_t ptouch_get_tape_width(ptouch_dev ptdev) {
	return ptdev->tape_width_px;
}

size_t ptouch_get_max_width(ptouch_dev ptdev) {
	return ptdev->devinfo->max_px;
}

int ptouch_sendraster(ptouch_dev ptdev, uint8_t *data, size_t len) {
	uint8_t buf[64];
	int rc;

	if(len > (size_t)(ptdev->devinfo->max_px / 8)) {
		return -1;
	}
	buf[0] = 0x47;
	if(ptdev->devinfo->flags & FLAG_RASTER_PACKBITS) {
		/* Fake compression by encoding a single uncompressed run */
		buf[1] = (uint8_t)(len + 1);
		buf[2] = 0;
		buf[3] = (uint8_t)(len - 1);
		memcpy(buf + 4, data, len);
		rc = ptouch_send(ptdev, buf, len + 4);
	} else {
		buf[1] = (uint8_t)len;
		buf[2] = 0;
		memcpy(buf + 3, data, len);
		rc = ptouch_send(ptdev, buf, len + 3);
	}
	return rc;
}

void ptouch_list_supported() {
	printf("Supported printers (some might have quirks)\n");
	for(int i = 0; ptdevs[i].vid > 0; ++i) {
		if((ptdevs[i].flags & FLAG_PLITE) != FLAG_PLITE) {
			printf("\t%s\n", ptdevs[i].name);
		}
	}
	return;
}

const char *pt_mediatype(const uint8_t media_type) {
	switch(media_type) {
		case 0x00:
			return "No media";
			break;
		case 0x01:
			return "Laminated tape";
			break;
		case 0x03:
			return "Non-laminated tape";
			break;
		case 0x04:
			return "Fabric tape";
			break;
		case 0x11:
			return "Heat-shrink tube";
			break;
		case 0x13:
			return "Fle tape";
			break;
		case 0x14:
			return "Flexible ID tape";
			break;
		case 0x15:
			return "Satin tape";
			break;
		case 0xff:
			return "Incompatible tape";
			break;
		default:
			return "unknown";
	}
}

const char *pt_tapecolor(const uint8_t tape_color) {
	switch(tape_color) {
		case 0x01:
			return "White";
			break;
		case 0x02:
			return "Other";
			break;
		case 0x03:
			return "Clear";
			break;
		case 0x04:
			return "Red";
			break;
		case 0x05:
			return "Blue";
			break;
		case 0x06:
			return "Yellow";
			break;
		case 0x07:
			return "Green";
			break;
		case 0x08:
			return "Black";
			break;
		case 0x09:
			return "Clear";
			break;
		case 0x20:
			return "Matte White";
			break;
		case 0x21:
			return "Matte Clear";
			break;
		case 0x22:
			return "Matte Silver";
			break;
		case 0x23:
			return "Satin Gold";
			break;
		case 0x24:
			return "Satin Silver";
			break;
		case 0x30:
			return "Blue (TZe-5[345]5)";
			break;
		case 0x31:
			return "Red (TZe-435)";
			break;
		case 0x40:
			return "Fluorescent Orange";
			break;
		case 0x41:
			return "Fluorescent Yellow";
			break;
		case 0x50:
			return "Berry Pink (TZe-MQP35)";
			break;
		case 0x51:
			return "Light Gray (TZe-MQL35)";
			break;
		case 0x52:
			return "Lime Green (TZe-MQG35)";
			break;
		case 0x60:
			return "Yellow";
			break;
		case 0x61:
			return "Pink";
			break;
		case 0x62:
			return "Blue";
			break;
		case 0x70:
			return "Heat-shrink Tube";
			break;
		case 0x90:
			return "White(Flex. ID)";
			break;
		case 0x91:
			return "Yellow(Flex. ID)";
			break;
		case 0xf0:
			return "Cleaning";
			break;
		case 0xf1:
			return "Stencil";
			break;
		case 0xff:
			return "Incompatible";
			break;
		default:
			return "unknown";
	}
}

const char *pt_textcolor(const uint8_t text_color) {
	switch(text_color) {
		case 0x01:
			return "White";
			break;
		case 0x02:
			return "Other";
			break;
		case 0x04:
			return "Red";
			break;
		case 0x05:
			return "Blue";
			break;
		case 0x08:
			return "Black";
			break;
		case 0x0a:
			return "Gold";
			break;
		case 0x62:
			return "Blue(F)";
			break;
		case 0xf0:
			return "Cleaning";
			break;
		case 0xf1:
			return "Stencil";
			break;
		case 0xff:
			return "Incompatible";
			break;
		default:
			return "unknown";
	}
}
