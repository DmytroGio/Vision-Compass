#include "appviewmodel.h"
#include <QDebug>
#include <QStandardPaths>
#include <QDir>
#include <QFileDialog>
#include <QMessageBox>
#include <QDateTime>

// --- CONSTRUCTOR ---

AppViewModel::AppViewModel(QObject *parent) : QObject(parent)
{
    loadData();
}

// --- PROPERTY GETTERS ---

QString AppViewModel::currentGoalText() const {
    return QString::fromStdString(m_currentGoal.description);
}

QString AppViewModel::currentGoalDescription() const {
    return QString::fromStdString(m_currentGoal.targetDate);
}

QVariantList AppViewModel::subGoalsListModel() const {
    QVariantList list;
    for (const auto& sg : m_subGoals) {
        QVariantMap map;
        map.insert("id", sg.id);
        // QML model delegate often expects a "name" role for its text property.
        map.insert("name", QString::fromStdString(sg.description));
        map.insert("description", QString::fromStdString(sg.description));
        list.append(map);
    }
    return list;
}

QVariantList AppViewModel::currentTasksListModel() const {
    QVariantList list;
    for (const auto& task : m_currentTasks) {
        QVariantMap map;
        map.insert("id", task.id);
        // QML model delegate often expects a "name" role for its text property.
        map.insert("name", QString::fromStdString(task.description));
        map.insert("description", QString::fromStdString(task.description));
        map.insert("completed", task.completed);
        list.append(map);
    }
    return list;
}

QVariantList AppViewModel::subGoalCompletionStatus() const
{
    QVariantList statusList;
    for (const auto& subGoal : m_subGoals) {
        auto tasksForSubGoal = m_taskManager.getTasksForSubGoal(subGoal.id);

        bool allCompleted = false;
        if (!tasksForSubGoal.empty()) {
            allCompleted = std::all_of(tasksForSubGoal.begin(), tasksForSubGoal.end(),
                                       [](const Task& task) { return task.completed; });
        }

        QVariantMap statusMap;
        statusMap["subGoalId"] = subGoal.id;
        statusMap["allTasksCompleted"] = allCompleted;
        statusMap["hasAnyTasks"] = !tasksForSubGoal.empty();
        statusList.append(statusMap);
    }
    return statusList;
}

int AppViewModel::selectedSubGoalId() const {
    return m_selectedSubGoalId;
}

QString AppViewModel::selectedSubGoalName() const {
    if (m_selectedSubGoalId == 0) return QString();

    for (const auto& sg : m_subGoals) {
        if (sg.id == m_selectedSubGoalId) {
            return QString::fromStdString(sg.description);
        }
    }
    return QString();
}

int AppViewModel::selectedTaskId() const
{
    return m_selectedTaskId;
}


// --- PROPERTY SETTERS ---

void AppViewModel::setCurrentGoalText(const QString& text) {
    if (QString::fromStdString(m_currentGoal.description) != text) {
        m_currentGoal.description = text.toStdString();
        m_taskManager.setGoal(m_currentGoal);
        saveData();
        emit currentGoalChanged();
    }
}

void AppViewModel::setCurrentGoalDescription(const QString& description) {
    if (QString::fromStdString(m_currentGoal.targetDate) != description) {
        m_currentGoal.targetDate = description.toStdString();
        m_taskManager.setGoal(m_currentGoal);
        saveData();
        emit currentGoalChanged();
    }
}

// --- PUBLIC Q_INVOKABLE API for QML ---

void AppViewModel::setMainGoal(const QString& name, const QString& description) {
    m_currentGoal.description = name.toStdString();
    m_currentGoal.targetDate = description.toStdString();
    m_taskManager.setGoal(m_currentGoal);
    saveData();
    emit currentGoalChanged();
}

// --- SubGoal Management ---

int AppViewModel::addSubGoal(const QString& name) {
    if (name.isEmpty()) return 0;

    SubGoal sg;
    sg.description = name.toStdString();
    m_taskManager.addSubGoal(sg);
    saveData();
    updateSubGoalListModel();

    int newId = 0;
    if (!m_subGoals.empty()) {
        newId = m_subGoals.back().id;
    }

    if (m_subGoals.size() == 1) {
        selectSubGoal(newId);
    }

    emit newSubGoalAdded(newId);
    return newId;
}

void AppViewModel::editSubGoal(int id, const QString& newName) {
    if (newName.isEmpty()) return;

    SubGoal sg = m_taskManager.getSubGoalById(id);
    if (sg.id == 0) return;

    sg.description = newName.toStdString();
    m_taskManager.editSubGoal(id, sg);
    saveData();
    updateSubGoalListModel();

    if (id == m_selectedSubGoalId) {
        emit selectedSubGoalChanged();
    }
}

void AppViewModel::deleteSubGoal(int id) {
    if (m_subGoals.empty()) return;

    int indexToRemove = -1;
    for (int i = 0; i < m_subGoals.size(); ++i) {
        if (m_subGoals[i].id == id) {
            indexToRemove = i;
            break;
        }
    }

    if (indexToRemove == -1) return;

    int newIdToSelect = 0;
    if (id == m_selectedSubGoalId) {
        if (m_subGoals.size() > 1) {
            if (indexToRemove == 0) {
                newIdToSelect = m_subGoals[1].id;
            } else {
                newIdToSelect = m_subGoals[indexToRemove - 1].id;
            }
        }
    } else {
        newIdToSelect = m_selectedSubGoalId;
    }

    m_taskManager.deleteSubGoal(id);
    saveData();
    updateSubGoalListModel();

    if (!m_subGoals.empty()) {
        selectSubGoal(newIdToSelect);
    } else {
        m_selectedSubGoalId = 0;
        updateTasksListModel();
        emit selectedSubGoalChanged();
    }

    qDebug() << "Deleted subgoal ID:" << id << ", new selected ID:" << m_selectedSubGoalId;
}

void AppViewModel::removeSubGoal(const QVariantMap& subGoalData) {
    int id = subGoalData.value("id").toInt();
    deleteSubGoal(id);
}

void AppViewModel::selectSubGoal(int id) {
    bool idExists = false;
    for(const auto& sg : m_subGoals) {
        if (sg.id == id) {
            idExists = true;
            break;
        }
    }

    if (!idExists && !m_subGoals.empty()) {
        id = m_subGoals.front().id;
    } else if (m_subGoals.empty()) {
        id = 0;
    }


    if (m_selectedSubGoalId != id) {
        m_selectedSubGoalId = id;
        qDebug() << "SubGoal selected:" << m_selectedSubGoalId;
        updateTasksListModel();
        emit selectedSubGoalChanged();
    }
}

// --- Task Management ---

int AppViewModel::addTask(const QString& description) {
    return addTaskToCurrentSubGoal(description);
}

int AppViewModel::addTaskToCurrentSubGoal(const QString& description) {
    if (description.isEmpty()) {
        qDebug() << "Cannot add task: description is empty";
        return 0;
    }

    if (m_selectedSubGoalId == 0) {
        qDebug() << "Cannot add task: no subgoal selected";
        return 0;
    }

    m_taskManager.addTask(description.toStdString(), "", m_selectedSubGoalId);
    saveData();
    updateTasksListModel();

    int newTaskId = 0;
    if (!m_currentTasks.empty()) {
        newTaskId = m_currentTasks.back().id;
    }

    qDebug() << "Added task:" << description << "to SubGoal:" << m_selectedSubGoalId;
    emit newTaskAdded(newTaskId);
    return newTaskId;
}

void AppViewModel::editTask(int id, const QString& newDescription) {
    if (newDescription.isEmpty()) return;

    m_taskManager.editTask(id, newDescription.toStdString(), "", m_selectedSubGoalId);
    saveData();
    updateTasksListModel();
}

void AppViewModel::completeTask(int id){
    m_taskManager.completeTask(id);
    saveData();
    updateTasksListModel();
}

void AppViewModel::deleteTask(int id) {
    m_taskManager.deleteTask(id);
    saveData();
    updateTasksListModel();
    qDebug() << "Deleted task ID:" << id;
}

void AppViewModel::removeTask(const QVariantMap& taskData) {
    int id = taskData.value("id").toInt();
    deleteTask(id);
}

void AppViewModel::selectTask(int id)
{
    if (m_selectedTaskId != id) {
        m_selectedTaskId = id;
        emit selectedTaskChanged();
    }
}


// --- DATA PERSISTENCE & MANAGEMENT ---

void AppViewModel::loadData() {
    QString filePath = getTasksFilePath();
    m_taskManager.loadFromFile(filePath.toStdString());

    updateGoalProperties();
    updateSubGoalListModel();

    if (!m_subGoals.empty()) {
        selectSubGoal(m_subGoals.front().id);
    }
}

void AppViewModel::saveData() {
    m_taskManager.saveToFile(getTasksFilePath().toStdString());
    qDebug() << "Data saved to" << getTasksFilePath();
}

void AppViewModel::clearAllData() {
    m_taskManager = TaskManager();

    Goal defaultGoal;
    defaultGoal.id = 1;
    defaultGoal.description = "My Main Goal";
    defaultGoal.targetDate = "Set your target date";
    m_taskManager.setGoal(defaultGoal);

    SubGoal defaultSubGoal;
    defaultSubGoal.description = "First Sub Goal";
    m_taskManager.addSubGoal(defaultSubGoal);

    m_selectedSubGoalId = 0;

    updateGoalProperties();
    updateSubGoalListModel();

    if (!m_subGoals.empty()) {
        selectSubGoal(m_subGoals[0].id);
    } else {
        m_selectedSubGoalId = 0;
        updateTasksListModel();
        emit selectedSubGoalChanged();
    }

    saveData();
}

QString AppViewModel::getCurrentDataAsJson() const {
    QString tempPath = getTasksFilePath() + ".temp";
    m_taskManager.saveToFile(tempPath.toStdString());

    QFile file(tempPath);
    if (!file.open(QIODevice::ReadOnly | QIODevice::Text)) {
        qDebug() << "Failed to read temporary JSON data";
        return QString();
    }

    QTextStream in(&file);
    QString jsonData = in.readAll();
    file.close();

    QFile::remove(tempPath);
    return jsonData;
}

void AppViewModel::loadDataFromJson(const QString& jsonData) {
    try {
        if (jsonData.isEmpty()) {
            qDebug() << "Import cancelled: empty JSON data";
            return;
        }

        qDebug() << "Loading data from JSON";

        QString backupPath = getTasksFilePath() + ".backup";
        m_taskManager.saveToFile(backupPath.toStdString());
        qDebug() << "Created backup at:" << backupPath;

        QString tempPath = getTasksFilePath() + ".import_temp";
        QFile tempFile(tempPath);
        if (!tempFile.open(QIODevice::WriteOnly | QIODevice::Text)) {
            qDebug() << "Failed to create temporary import file";
            return;
        }

        QTextStream out(&tempFile);
        out << jsonData;
        tempFile.close();

        m_taskManager.loadFromFile(tempPath.toStdString());
        QFile::remove(tempPath);

        m_selectedSubGoalId = 0;

        updateGoalProperties();
        updateSubGoalListModel();

        if (!m_subGoals.empty()) {
            selectSubGoal(m_subGoals[0].id);
        } else {
            m_selectedSubGoalId = 0;
            updateTasksListModel();
            emit selectedSubGoalChanged();
        }

        saveData();
        qDebug() << "Import completed successfully";
    } catch (const std::exception& e) {
        qDebug() << "Import error:" << e.what();
        // Restore from backup if import failed
        QString backupPath = getTasksFilePath() + ".backup";
        try {
            m_taskManager.loadFromFile(backupPath.toStdString());
            m_selectedSubGoalId = 0;
            updateGoalProperties();
            updateSubGoalListModel();
            updateTasksListModel();
            qDebug() << "Restored from backup after failed import";
        } catch (const std::exception& restoreError) {
            qDebug() << "Failed to restore from backup:" << restoreError.what();
        }
    }
}

// --- PRIVATE HELPER METHODS ---

void AppViewModel::updateSubGoalCompletionStatus()
{
    emit subGoalCompletionChanged();
}

void AppViewModel::updateGoalProperties() {
    m_currentGoal = m_taskManager.getGoal();
    emit currentGoalChanged();
}

void AppViewModel::updateSubGoalListModel() {
    m_subGoals = m_taskManager.getSubGoals();
    updateSubGoalCompletionStatus();
    emit subGoalsChanged();
}

void AppViewModel::updateTasksListModel() {
    if (m_selectedSubGoalId != 0) {
        m_currentTasks = m_taskManager.getTasksForSubGoal(m_selectedSubGoalId);
        qDebug() << "Updated tasks for SubGoal" << m_selectedSubGoalId << ":" << m_currentTasks.size() << "tasks";
    } else {
        m_currentTasks.clear();
        qDebug() << "No SubGoal selected, cleared tasks";
    }
    updateSubGoalCompletionStatus();
    emit currentTasksChanged();
}

QString AppViewModel::getTasksFilePath() const {
    QString dataPath = QStandardPaths::writableLocation(QStandardPaths::AppDataLocation);
    QDir dir(dataPath);
    if (!dir.exists()) {
        dir.mkpath(".");
    }
    return dataPath + "/tasks.json";
}

QString AppViewModel::getDefaultDataPath() const {
    QString documentsDir = QStandardPaths::writableLocation(QStandardPaths::DocumentsLocation);
    return QDir(documentsDir).filePath("VisionCompass_Backups");
}

QString AppViewModel::getDefaultExportFileName() const {
    return "VisionCompass_backup_"
           + QDateTime::currentDateTime().toString("yyyy-MM-dd_hh-mm-ss")
           + ".json";
}

QString AppViewModel::getDefaultImportPath() const {
    QString backupDir = getDefaultDataPath();
    QDir dir(backupDir);

    if (!dir.exists()) {
        qDebug() << "Backup directory does not exist:" << backupDir;
        return backupDir;
    }

    QStringList nameFilters;
    nameFilters << "VisionCompass_backup_*.json";
    QFileInfoList backupFiles = dir.entryInfoList(nameFilters, QDir::Files, QDir::Time);

    if (backupFiles.isEmpty()) {
        qDebug() << "No backup files found in:" << backupDir;
        return backupDir;
    }

    QFileInfo latestFile = backupFiles.first();
    QString latestFilePath = latestFile.absoluteFilePath();

    qDebug() << "Latest backup file found:" << latestFilePath;
    return latestFilePath;
}
