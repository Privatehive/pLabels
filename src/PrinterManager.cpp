//
// Created by bjoern on 10.04.24.
//

#include "PrinterManager.h"
#include <QPainter>
extern "C" {
#include "ptouchwrapper.h"
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
	mPrinter.tapeWidthPx = 0;
	mPrinter.tapeWidthMm = 0;
	ptouch_dev ptdev = nullptr;
	if(ptouch_open(&ptdev) == 0) {
		mPrinter.name = QString::fromLocal8Bit(ptdev->devinfo->name);
		mPrinter.id = QString::number(ptdev->devinfo->vid);
		if(ptouch_getstatus(ptdev) == 0) {
			mPrinter.tapeWidthPx = static_cast<int>(ptouch_get_tape_width(ptdev));
			mPrinter.tapeWidthMm = PrinterManager::getTapeMm(mPrinter.tapeWidthPx);
			mPrinter.ready = true;
		}
	}
	ptouch_free(&ptdev);
	emit printerChanged();
}

void PrinterManager::print(QVariant image) {

	if(image.isValid() && !image.isNull() && image.canConvert<QImage>()) {
		auto img = qvariant_cast<QImage>(image);
		if(!img.isNull()) {
			ptouch_dev ptdev = nullptr;
			if(ptouch_open(&ptdev) == 0) {
				if(ptouch_init(ptdev) == 0) {
					if(ptouch_getstatus(ptdev) == 0) {
						auto tape_width = ptouch_get_tape_width(ptdev);
						auto finalImg = QImage(img);
						if(tape_width == finalImg.height()) {
							if(finalImg.format() != QImage::Format_Grayscale8) {
								qInfo() << "The given image format is not 8 bit greyscale and must be converted";
								finalImg.convertTo(QImage::Format_Grayscale8);
							}
							print_img(ptdev, finalImg.constBits(), finalImg.width(), finalImg.height(), finalImg.bytesPerLine());
							if(ptouch_eject(ptdev) != 0) {
								qWarning() << "eject_failed";
							}
						} else {
							qWarning() << "The image height does not match the installed tape width: go image height" << finalImg.height()
							           << "but expected" << tape_width;
						}
					}
				}
			}
			ptouch_free(&ptdev);
		} else {
			qWarning() << "The image is empty";
		}
	} else {
		qWarning() << "No image that can be printed";
	}
}

int PrinterManager::getTapeMm(int tapePx) {

	for(auto i = 0;; i++) {
		if(tape_info[i].mm == 0 && tape_info[i].px == 0 && tape_info[i].margins == 0.) {
			break;
		}
		if(tapePx == tape_info[i].px) {
			return tape_info[i].mm;
		}
	}
	return 0;
}

int PrinterManager::getTapePx(int tapeMm) {

	for(auto i = 0;; i++) {
		if(tape_info[i].mm == 0 && tape_info[i].px == 0 && tape_info[i].margins == 0.) {
			break;
		}
		if(tapeMm == tape_info[i].mm) {
			return tape_info[i].px;
		}
	}
	return 0;
}