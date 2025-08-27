#ifndef FILEMANAGER_H
#define FILEMANAGER_H

#include <QObject>
#include <QString>
#include <QFile>
#include <QTextStream>
#include <QUrl>
#include <QFileInfo>
#include <qqmlregistration.h>

class FileManager : public QObject
{
    Q_OBJECT
    QML_ELEMENT

public:
    explicit FileManager(QObject *parent = nullptr);

public slots:
    void exportToFile(const QString& filePath, const QString& jsonData);
    void importFromFile(const QString& filePath);

signals:
    void exportCompleted(bool success, const QString& message, const QString& actualPath);
    void importCompleted(bool success, const QString& message, const QString& jsonData);

private:
    QString normalizeFilePath(const QString& path);
    QString ensureJsonExtension(const QString& path);
};

#endif // FILEMANAGER_H
