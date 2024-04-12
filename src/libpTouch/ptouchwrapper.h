#pragma once
#include "ptouch.h"

extern _pt_tape_info tape_info[];
extern _pt_dev_info ptdevs[];

void ptouch_free(ptouch_dev *ptdev);
