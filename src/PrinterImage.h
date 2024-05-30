#pragma once
#include <QImage>
#include <QQuickItem>


class PrinterImage : public QQuickItem {

	Q_OBJECT
	QML_NAMED_ELEMENT(PrinterImage)
	Q_PROPERTY(QImage image READ getImage WRITE setImage NOTIFY imageChanged)
	Q_PROPERTY(bool dithering READ isDithering WRITE enableDithering NOTIFY ditheringChanged)

 public:
	explicit PrinterImage(QQuickItem *parent = nullptr);

	QImage getImage() const;
	void setImage(QImage image);
	bool isDithering() const;
	void enableDithering(bool dithering);

	Q_INVOKABLE QImage getTransformedImage();

 signals:
	void imageChanged();
	void ditheringChanged();

 protected:
	QSGNode *updatePaintNode(QSGNode *, UpdatePaintNodeData *) override;

 private:
	Q_DISABLE_COPY(PrinterImage);

	QImage transformImage();

	QImage mImage;
	bool mDithering;
};
