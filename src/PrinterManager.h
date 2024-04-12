#pragma once
#include <QObject>
#include <QtQmlIntegration>

class Printer {
	Q_GADGET
	Q_PROPERTY(QString id MEMBER id)
	Q_PROPERTY(QString name MEMBER name)
	Q_PROPERTY(int tapeWidthPx MEMBER tapeWidthPx)
	Q_PROPERTY(bool ready MEMBER ready)

 public:
	QString id;
	QString name;
	int tapeWidthPx;
	bool ready;
};

class PrinterManager : public QObject {

	Q_OBJECT
	QML_SINGLETON
	QML_NAMED_ELEMENT(PrinterManager)
	Q_PROPERTY(Printer printer READ getPrinter NOTIFY printerChanged)

 public:
	explicit PrinterManager(QObject *pParent = nullptr);
	Printer getPrinter() const;

 signals:
	void printerChanged();

 private:
	void reloadDevice();
	Printer mPrinter;
};
