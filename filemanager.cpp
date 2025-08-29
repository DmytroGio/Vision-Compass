#include "filemanager.h"
#include <QDebug>
#include <QDir>
#include <QStandardPaths>
#include <QDateTime>
#include <QStringConverter>

FileManager::FileManager(QObject *parent) : QObject(parent)
{
}

void FileManager::exportToFile(const QString& filePath, const QString& jsonData)
{
    try {
        QString actualPath = normalizeFilePath(filePath);

        // If path is empty, create default export path in organized folder
        if (actualPath.isEmpty()) {
            QString documentsDir = QStandardPaths::writableLocation(QStandardPaths::DocumentsLocation);
            QString backupsDir = QDir(documentsDir).filePath("VisionCompass_Backups");

            // Create backups directory if it doesn't exist
            QDir dir(backupsDir);
            if (!dir.exists()) {
                dir.mkpath(".");
            }

            QString timestamp = QDateTime::currentDateTime().toString("yyyy-MM-dd_hh-mm-ss");
            actualPath = QDir(backupsDir).filePath(QString("VisionCompass_backup_%1.json").arg(timestamp));
        } else {
            actualPath = ensureJsonExtension(actualPath);
        }

        // Ensure directory exists
        QFileInfo fileInfo(actualPath);
        QDir dir = fileInfo.absoluteDir();
        if (!dir.exists()) {
            dir.mkpath(".");
        }

        QFile file(actualPath);
        if (!file.open(QIODevice::WriteOnly | QIODevice::Text)) {
            emit exportCompleted(false, QString("Cannot open file for writing: %1").arg(file.errorString()), actualPath);
            return;
        }

        QTextStream out(&file);
        out.setEncoding(QStringConverter::Utf8);
        out << jsonData;
        file.close();

        qDebug() << "Export completed successfully to:" << actualPath;
        emit exportCompleted(true, "Export completed successfully", actualPath);


    } catch (const std::exception& e) {
        QString errorMsg = QString("Export error: %1").arg(e.what());
        qDebug() << errorMsg;
        emit exportCompleted(false, errorMsg, filePath);
    }
}

void FileManager::importFromFile(const QString& filePath)
{
    try {
        QString actualPath = normalizeFilePath(filePath);

        if (actualPath.isEmpty()) {
            emit importCompleted(false, "File path is empty", "");
            return;
        }

        QFile file(actualPath);
        if (!file.exists()) {
            emit importCompleted(false, QString("File does not exist: %1").arg(actualPath), "");
            return;
        }

        if (!file.open(QIODevice::ReadOnly | QIODevice::Text)) {
            emit importCompleted(false, QString("Cannot open file for reading: %1").arg(file.errorString()), "");
            return;
        }

        QTextStream in(&file);
        in.setEncoding(QStringConverter::Utf8);
        QString jsonData = in.readAll();
        file.close();

        if (jsonData.isEmpty()) {
            emit importCompleted(false, "File is empty or contains no valid data", "");
            return;
        }

        qDebug() << "Import completed successfully from:" << actualPath;
        emit importCompleted(true, "Import completed successfully", jsonData);

    } catch (const std::exception& e) {
        QString errorMsg = QString("Import error: %1").arg(e.what());
        qDebug() << errorMsg;
        emit importCompleted(false, errorMsg, "");
    }
}

QString FileManager::normalizeFilePath(const QString& path)
{
    if (path.isEmpty()) {
        return QString();
    }

    // Convert QML file:// URL to local file path
    QUrl url(path);
    if (url.isLocalFile()) {
        return url.toLocalFile();
    }

    // If it's already a local path, return as is
    return path;
}

QString FileManager::ensureJsonExtension(const QString& path)
{
    if (path.endsWith(".json", Qt::CaseInsensitive)) {
        return path;
    }
    return path + ".json";
}
