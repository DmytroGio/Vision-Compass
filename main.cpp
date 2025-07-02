#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext> // Required for setContextProperty
#include "appviewmodel.h" // Include the AppViewModel header

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);

    QQmlApplicationEngine engine;

    // Register AppViewModel with QML
    qmlRegisterSingletonType<AppViewModel>("com.visioncompass.data", 1, 0, "AppViewModel", [](QQmlEngine*, QJSEngine*) -> QObject* {
        return new AppViewModel();
    });
    // Or, for a single instance exposed as a context property:
    // AppViewModel appViewModel;
    // engine.rootContext()->setContextProperty("appViewModel", &appViewModel);
    // Using singleton type is often cleaner for models.

    const QUrl url(QStringLiteral("qrc:/VisionCompass/Main.qml"));
    QObject::connect(&engine, &QQmlApplicationEngine::objectCreated,
                     &app, [url](QObject *obj, const QUrl &objUrl) {
                         if (!obj && url == objUrl)
                             QCoreApplication::exit(-1);
                     }, Qt::QueuedConnection);
    engine.load(url);

    return app.exec();
}
