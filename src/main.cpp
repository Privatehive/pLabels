#include "AdvancedQmlApplicationEngine.h"
#include "QtApplicationBase.h"
#include <QIcon>
#include <QGuiApplication>
#include <QQuickStyle>

#ifdef Q_OS_WINDOWS
#include "qt_windows.h"
#endif

int main(int argc, char **argv) {


	// qputenv("QT_IM_MODULE", QByteArray("qtvirtualkeyboard"));
	// qputenv("QML_IMPORT_TRACE", "true");
	//qunsetenv("QT_STYLE_OVERRIDE");
	//qunsetenv("QT_QUICK_CONTROLS_STYLE");

	QtApplicationBase<QGuiApplication> app(argc, argv);

	// app.set(INFO_PROJECTNAME, QString("%1.%2.%3").arg(INFO_VERSION_MAJOR).arg(INFO_VERSION_MINOR).arg(INFO_VERSION_PATCH), INFO_DOMAIN);

	// qmlRegisterType<HabItemBase>("org.openhab", 1, 0, "HabItemBase");
	// qmlRegisterType<HabPersistentItemBase>("org.openhab", 1, 0, "HabPersistentItemBase");
	// qmlRegisterType<HabModel>("org.openhab", 1, 0, "HabModel");


	// qmlRegisterUncreatableType<FutureResult>("org.openhab", 1, 0, "FutureResult", "Can't be created from qml");
	// qmlRegisterUncreatableType<ItemDto>("org.openhab", 1, 0, "ItemDto", "Can't be created from qml");

	// qmlRegisterSingletonType<HabServer>("org.openhab", 1, 0, "HabServer", [](QQmlEngine *engine, QJSEngine *scriptEngine) -> QObject * {
	//	Q_UNUSED(engine)
	//	Q_UNUSED(scriptEngine)

	//	return HabServer::getGlobal();
	//});

	// qmlRegisterSingletonType<Command>("org.openhab", 1, 0, "Command", [](QQmlEngine *engine, QJSEngine *scriptEngine) -> QObject * {
	//	Q_UNUSED(engine)
	//	Q_UNUSED(scriptEngine)

	//	return new Command(qApp);
	//});

	AdvancedQmlApplicationEngine qmlEngine;
	QIcon::setThemeName("material");
	QQuickStyle::setStyle("Universal");

#ifdef QT_DEBUG
	auto qmlMainFile = QString("pTouch/pTouch/main.qml");
	if(QFile::exists(qmlMainFile)) {
		qInfo() << "QML hot reloading enabled";
		qmlEngine.setHotReload(true);
		qmlEngine.loadRootItem(qmlMainFile, false);
	} else {
		qmlEngine.setHotReload(false);
		qmlEngine.loadRootItem("qrc:/qt/qml/pTouch/pTouch/main.qml", false);
	}
#else
	qmlEngine.addImportPath("qrc:/qt/qml");
	qmlEngine.setHotReload(false);
	qmlEngine.loadRootItem("qrc:/qt/qml/pTouch/pTouch/main.qml", false);
#endif

	return app.start();
}
