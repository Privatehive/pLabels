//
// Created by bjoern on 10.04.24.
//

#include "PrinterManager.h"
extern "C" {
#include "ptouch.h"
}

PrinterManager::PrinterManager(QObject *pParent /*= nullptr*/) : QObject(pParent), mPrinter() {

	reloadDevice();
}

Printer PrinterManager::getPrinter() const {

	return mPrinter;
}

void PrinterManager::reloadDevice() {

	mPrinter = {};
	mPrinter.ready = false;
	mPrinter.tapeWidth = 0;
	ptouch_dev ptdev = nullptr;
	if(ptouch_open(&ptdev) == 0) {
		mPrinter.name = QString::fromLocal8Bit(ptdev->devinfo->name);
		mPrinter.id = QString::number(ptdev->devinfo->vid);
		if(ptouch_getstatus(ptdev) == 0) {
			mPrinter.tapeWidth = static_cast<int>(ptouch_get_tape_width(ptdev));
			mPrinter.ready = true;
		}
	}
	emit printerChanged();
}
