#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext> // Required for setContextProperty
#include "appviewmodel.h" // Include the AppViewModel header
#include <QtQuickControls2/QtQuickControls2>
#include <QQuickWindow>
#include <QIcon>


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

    // ИСПРАВЛЕНИЕ: Раскомментируйте эту строку - она нужна для работы AppViewModel в QML
    engine.rootContext()->setContextProperty("AppViewModel", appViewModel);

    const QUrl url(QStringLiteral("qrc:/VisionCompass/Main.qml"));

    QObject::connect(&engine, &QQmlApplicationEngine::objectCreated,
                     &app, [url](QObject *obj, const QUrl &objUrl) {
                         if (!obj && url == objUrl)
                             QCoreApplication::exit(-1);
                     }, Qt::QueuedConnection);

    engine.load(url);


    return app.exec();
}
