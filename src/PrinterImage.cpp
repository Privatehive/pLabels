#include "PrinterImage.h"
#include <QPainter>
#include <QSGImageNode>


PrinterImage::PrinterImage(QQuickItem *parent) : QQuickItem(parent), mImage(), mDithering(false) {

	setFlag(ItemHasContents);
}

QImage PrinterImage::getImage() const {

	return mImage;
}

void PrinterImage::setImage(QImage image) {

	mImage = image;
	setImplicitSize(image.size().width(), image.size().height());
	emit imageChanged();
	update();
}

bool PrinterImage::isDithering() const {

	return mDithering;
}

void PrinterImage::enableDithering(bool dithering) {

	mDithering = dithering;
	emit ditheringChanged();
	update();
}

QImage PrinterImage::getTransformedImage() {

	return transformImage();
}

QSGNode *PrinterImage::updatePaintNode(QSGNode *oldNode, UpdatePaintNodeData *updatePaintNodeData) {

	auto node = dynamic_cast<QSGImageNode *>(oldNode);

	if(!node) {
		node = window()->createImageNode();
	}

	QSGTexture *texture = window()->createTextureFromImage(transformImage(), QQuickWindow::TextureIsOpaque);
	node->setOwnsTexture(true);
	node->setRect(boundingRect());
	node->markDirty(QSGNode::DirtyForceUpdate);
	node->setTexture(texture);
	return node;
}

QImage PrinterImage::transformImage() {

	auto bg = QImage(mImage.width(), mImage.height(), QImage::Format_RGB32);
	bg.fill(Qt::white);
	QPainter p(&bg);
	p.setCompositionMode(QPainter::CompositionMode_SourceAtop);
	p.drawImage(0, 0, mImage);
	p.end();
	Qt::ImageConversionFlags flags = Qt::MonoOnly;
	if(mDithering) {
		flags |= Qt::DiffuseDither;
	} else {
		flags |= Qt::ThresholdDither;
	}
	bg.convertTo(QImage::Format_Mono, flags);
	bg.convertTo(QImage::Format_Grayscale8);
	return bg;
}
