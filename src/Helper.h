#include <QFile>
#include <QQuickItem>
#include <QSaveFile>


class Helper : public QObject {
	Q_OBJECT
	QML_NAMED_ELEMENT(Helper)
	QML_SINGLETON

 public:
	Helper(QObject *pParent = nullptr) : QObject(pParent) {}

	Q_INVOKABLE static QPointF mapFromScene(QQuickItem *item, const QPointF &point) {
		if(item) {
			return item->mapFromScene(point);
		}
		return {};
	}

	Q_INVOKABLE static QPointF mapToScene(QQuickItem *item, const QPointF &point) {
		if(item) {
			return item->mapToScene(point);
		}
		return {};
	}

	Q_INVOKABLE static void saveLable(QString jsonString, QUrl fileUrl) {
		auto file = QSaveFile(fileUrl.toLocalFile());
		file.open(QIODeviceBase::WriteOnly | QIODeviceBase::Unbuffered);
		file.write(qCompress(jsonString.toUtf8()));
		file.commit();
	}

	Q_INVOKABLE static QString readLable(QUrl fileUrl) {
		auto file = QFile(fileUrl.toLocalFile());
		file.open(QIODeviceBase::ReadOnly | QIODeviceBase::Unbuffered);
		const auto data = QString::fromUtf8(qUncompress(file.readAll()));
		file.close();
		return data;
	}

	Q_INVOKABLE static bool fileExists(QUrl fileUrl) { return QFile::exists(fileUrl.toLocalFile()); }
};