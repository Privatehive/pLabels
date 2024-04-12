#include "ptouch.h"
#include <stdlib.h>

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