#include "ptouch.h"
#include <stdlib.h>
#include <string.h>

void ptouch_free(ptouch_dev *ptdev) {
	if(ptdev) {
		if((*ptdev)->h) {
			ptouch_close((*ptdev));
			(*ptdev)->h = NULL;
		}
		free((*ptdev)->devinfo);
		(*ptdev)->devinfo = NULL;
		free((*ptdev)->status);
		(*ptdev)->status = NULL;
		free(*ptdev);
		(*ptdev) = NULL;
	}
}

void rasterline_setpixel(uint8_t *rasterline, size_t size, int pixel) {
	//	TODO: pixel should be unsigned, since we can't have negative
	//	if (pixel > ptdev->devinfo->device_max_px) {
	if(pixel > (int)(size * 8)) {
		return;
	}
	rasterline[(size - 1) - (pixel / 8)] |= (uint8_t)(1 << (pixel % 8));
}

int print_img(ptouch_dev ptdev, const uint8_t *img, int width, int height, int bytesPerLine) {
	int d, x, y, offset, tape_width;
	uint8_t rasterline[ptdev->devinfo->max_px / 8];

	/*
	if(!im) {
	  printf(_("nothing to print\n"));
	  return -1;
	}

	// find out whether color 0 or color 1 is darker
	d = (gdImageRed(im, 1) + gdImageGreen(im, 1) + gdImageBlue(im, 1) < gdImageRed(im, 0) + gdImageGreen(im, 0) + gdImageBlue(im, 0)) ? 1 : 0;
*/
	tape_width = ptouch_get_tape_width(ptdev);
	if(height > tape_width) {
		return -1;
	}

	// offset=64-(gdImageSY(im)/2);	/* always print centered  */
	size_t max_pixels = ptouch_get_max_width(ptdev);
	offset = ((int)max_pixels / 2) - (height / 2); /* always print centered  */
	// printf("max_pixels=%ld, offset=%d\n", max_pixels, offset);
	if((ptdev->devinfo->flags & FLAG_RASTER_PACKBITS) == FLAG_RASTER_PACKBITS) {
		/*
		if(debug) {
		  printf("enable PackBits mode\n");
		}*/
		ptouch_enable_packbits(ptdev);
	}

	if(ptouch_rasterstart(ptdev) != 0) {
		// printf(_("ptouch_rasterstart() failed\n"));
		return -1;
	}
	if((ptdev->devinfo->flags & FLAG_USE_INFO_CMD) == FLAG_USE_INFO_CMD) {
		ptouch_info_cmd(ptdev, width);
		/*
		if(debug) {
		  printf(_("send print information command\n"));
		}*/
	}
	if((ptdev->devinfo->flags & FLAG_D460BT_MAGIC) == FLAG_D460BT_MAGIC) {
		ptouch_send_d460bt_magic(ptdev);
		/*
		if(debug) {
		  printf(_("send PT-D460BT magic commands\n"));
		}*/
	}
	if((ptdev->devinfo->flags & FLAG_HAS_PRECUT) == FLAG_HAS_PRECUT) {
		ptouch_send_precut_cmd(ptdev, 1);
		/*
		if(debug) {
		  printf(_("send precut command\n"));
		}*/
	}
	for(x = width; x >= 0; x -= 1) {
		memset(rasterline, 0, sizeof(rasterline));
		for(y = 0; y < height; y += 1) {
			const uint8_t val = img[y * bytesPerLine + x];
			if(val < 128) {
				rasterline_setpixel(rasterline, sizeof(rasterline), offset + y);
			}
		}
		if(ptouch_sendraster(ptdev, rasterline, 16) != 0) {
			// printf(_("ptouch_sendraster() failed\n"));
			return -1;
		}
	}
	return 0;
}
