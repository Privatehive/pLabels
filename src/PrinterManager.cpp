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
	ptouch_dev ptdev = nullptr;
	if(ptouch_open(&ptdev) == 0) {
		mPrinter.name = QString::fromLocal8Bit(ptdev->devinfo->name);
		mPrinter.id = QString::number(ptdev->devinfo->vid);
		if(ptouch_getstatus(ptdev) == 0) {
			mPrinter.tapeWidthPx = static_cast<int>(ptouch_get_tape_width(ptdev));
			mPrinter.ready = true;
		}
	}
	ptouch_free(&ptdev);
	emit printerChanged();
}

void PrinterManager::print(QVariant image) {

	if(image.isValid() && !image.isNull() && image.canConvert<QImage>()) {
		auto img = qvariant_cast<QImage>(image);
		qDebug() << "sfasf" << img;
		ptouch_dev ptdev = nullptr;
		if(ptouch_open(&ptdev) == 0) {
			if(ptouch_init(ptdev) == 0) {
				if(ptouch_getstatus(ptdev) == 0) {
					auto tape_width = ptouch_get_tape_width(ptdev);
					auto bg = QImage(img.width(), img.height(), QImage::Format_RGB32);
					bg.fill(Qt::white);
					QPainter p(&bg);
					p.setCompositionMode(QPainter::CompositionMode_SourceAtop);
					p.drawImage(0, 0, img);
					p.end();
					bg.convertTo(QImage::Format_Mono, Qt::DiffuseDither | Qt::MonoOnly);
					bg.convertTo(QImage::Format_Grayscale8);
					print_img(ptdev, bg.constBits(), bg.width(), bg.height(), bg.bytesPerLine());
					if(ptouch_eject(ptdev) != 0) {
						qWarning() << "eject_failed";
					}
				}
			}
		}
		ptouch_free(&ptdev);
	} else {
		qWarning() << "No image provided that can be printed";
	}
}