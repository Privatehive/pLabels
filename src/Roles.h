#include <QObject>
#include <QtQmlIntegration>

namespace Enums {

Q_NAMESPACE

enum Roles {

	TapeWidthPxRole = Qt::UserRole + 1,
	TapeWidthMmRole,
	TapeMarginsMmRole
};

Q_ENUM_NS(Roles)
} // namespace Enums

class Roles : public QObject {

	Q_OBJECT
	QML_ELEMENT
	QML_EXTENDED_NAMESPACE(Enums)
};
