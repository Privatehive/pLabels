//
// Created by bjoern on 10.04.24.
//

#include "PrinterManager.h"
#include <QPainter>
extern "C" {
#include "ptouchwrapper.h"
}


int libUsbCallback(libusb_context *ctx, libusb_device *device, libusb_hotplug_event event, void *user_data) {

	if(auto manager = static_cast<PrinterManager *>(user_data)) {
		QTimer::singleShot(0, manager, [manager]() { manager->reloadDevice(); });
	}
	return 0;
}

PrinterManager::PrinterManager(QObject *pParent /*= nullptr*/) : QObject(pParent), mPrinter(), mTimerId(0), mCallbackHandle(-1) {

	Q_ASSERT(QThread::currentThread() == qApp->thread());

	libusb_init(nullptr);
	if(supports_hot_plug()) {
		if(libusb_hotplug_register_callback(nullptr, LIBUSB_HOTPLUG_EVENT_DEVICE_ARRIVED | LIBUSB_HOTPLUG_EVENT_DEVICE_LEFT,
		                                    LIBUSB_HOTPLUG_NO_FLAGS, 0x04f9, LIBUSB_HOTPLUG_MATCH_ANY, LIBUSB_HOTPLUG_MATCH_ANY,
		                                    &libUsbCallback, static_cast<void *>(this), &mCallbackHandle) != LIBUSB_SUCCESS) {
			qInfo() << "libusb hotplug callback could not be installed";
		}
	} else {
		qInfo() << "libusb hotplug is not supported";
	}

	reloadDevice();
	mTimerId = startTimer(1000, Qt::VeryCoarseTimer);
}

PrinterManager::~PrinterManager() {

	killTimer(mTimerId);
	if(mCallbackHandle >= 0) {
		libusb_hotplug_deregister_callback(nullptr, mCallbackHandle);
	}
}

Printer PrinterManager::getPrinter() const {

	return mPrinter;
}

void PrinterManager::reloadDevice() {

	auto printer = Printer{};
	ptouch_dev ptdev = nullptr;
	if(ptouch_open(&ptdev) == 0) {
		printer.name = QString::fromLocal8Bit(ptdev->devinfo->name);
		printer.id = QString::number(ptdev->devinfo->vid);
		if(ptouch_getstatus(ptdev) == 0) {
			printer.tapeWidthPx = static_cast<int>(ptouch_get_tape_width(ptdev));
			printer.tapeWidthMm = PrinterManager::getTapeMm(printer.tapeWidthPx);
			printer.ready = true;
		}
	}
	if(mPrinter.ready && !printer.ready) {
		qInfo() << "pTouch device left:" << mPrinter.name;
	} else if(!mPrinter.ready && printer.ready) {
		qInfo() << "pTouch device joined:" << printer.name;
	}
	ptouch_free(&ptdev);
	mPrinter = printer;
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

// needed to poll for hotplug events
void PrinterManager::timerEvent(QTimerEvent *event) {

	QObject::timerEvent(event);
	if(event->timerId() == mTimerId) {
		auto tv = timeval();
		tv.tv_sec = 0;
		tv.tv_usec = 0;
		libusb_handle_events_timeout_completed(nullptr, &tv, nullptr);
	}
}
