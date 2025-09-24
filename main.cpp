#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include "appviewmodel.h"
#include <QtQuickControls2/QtQuickControls2>
#include <QQuickWindow>
#include <QFileDialog>
#include <QIcon>
#include <QtQml>
#include "filemanager.h"


int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);

    app.setAttribute(Qt::AA_UseStyleSheetPropagationInWidgetStyles, true);
    qputenv("QT_QUICK_CONTROLS_STYLE", "Material");
    qputenv("QT_QUICK_CONTROLS_MATERIAL_THEME", "Dark");


    QQuickWindow::setDefaultAlphaBuffer(true);
    app.setWindowIcon(QIcon(":/icons/compass-icon.png"));

    QCoreApplication::setOrganizationName("DmytroVision");
    QCoreApplication::setApplicationName("VisionCompass");

    AppViewModel* appViewModel = new AppViewModel();

    QObject::connect(&app, &QGuiApplication::aboutToQuit, appViewModel, &AppViewModel::saveData);

    QQmlApplicationEngine engine;

    engine.rootContext()->setContextProperty("AppViewModel", appViewModel);

    const QUrl url(QStringLiteral("qrc:/VisionCompass/Main.qml"));

    QObject::connect(&engine, &QQmlApplicationEngine::objectCreated,
                     &app, [url](QObject *obj, const QUrl &objUrl) {
                         if (!obj && url == objUrl)
                             QCoreApplication::exit(-1);
                     }, Qt::QueuedConnection);

    qmlRegisterType<FileManager>("com.visioncompass", 1, 0, "FileManager");

    engine.load(url);


    return app.exec();
}
