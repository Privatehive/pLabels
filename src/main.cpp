#include "AdvancedQmlApplicationEngine.h"
#include "QtApplicationBase.h"
#include "settings.h"
#include <QGuiApplication>
#include <QIcon>
#include <QQuickStyle>

#ifdef Q_OS_WINDOWS
#include "qt_windows.h"
#endif

int main(int argc, char **argv) {

	// qputenv("QT_IM_MODULE", QByteArray("qtvirtualkeyboard"));
	// qputenv("QML_IMPORT_TRACE", "true");
	// qunsetenv("QT_STYLE_OVERRIDE");
	// qunsetenv("QT_QUICK_CONTROLS_STYLE");

	// Q_INIT_RESOURCE(MaterialRally_raw_qml_0);
	// Q_INIT_RESOURCE(qmake_MaterialRally);

	QtApplicationBase<QGuiApplication> app(argc, argv);

	AdvancedQmlApplicationEngine qmlEngine;
	QIcon::setThemeName("material");

#ifdef QT_DEBUG_d
	auto qmlMainFile = QString("pTouch/pTouch/Main.qml");
	if(QFile::exists(qmlMainFile)) {
		qInfo() << "QML hot reloading enabled";
		qmlEngine.setHotReload(true);
		qmlEngine.loadRootItem(qmlMainFile, true);
	} else {
		qmlEngine.setHotReload(false);
		qmlEngine.loadRootItem("qrc:/qt/qml/pTouch/pTouch/Main.qml", true);
	}
#else
	qmlEngine.setHotReload(false);
	qmlEngine.loadRootItem("qrc:/qt/qml/pTouch/pTouch/Main.qml", false);
#endif

	return app.start();
}
