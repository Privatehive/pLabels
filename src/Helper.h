#include <QQuickItem>

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
};