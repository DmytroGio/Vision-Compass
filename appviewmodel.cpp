#include "appviewmodel.h"
#include <QDebug>
#include <QStandardPaths>
#include <QDir>
#include <QFileDialog>
#include <QMessageBox>
#include <QDateTime>

AppViewModel::AppViewModel(QObject *parent) : QObject(parent)
{
    loadData();
}

// --- Property Getters ---
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
        map.insert("name", QString::fromStdString(sg.description)); // QML expects "name"
        map.insert("description", QString::fromStdString(sg.description)); // Also provide "description"
        list.append(map);
    }
    return list;
}

QVariantList AppViewModel::currentTasksListModel() const {
    QVariantList list;
    for (const auto& task : m_currentTasks) {
        QVariantMap map;
        map.insert("id", task.id);
        map.insert("name", QString::fromStdString(task.description)); // QML expects "name"
        map.insert("description", QString::fromStdString(task.description)); // Also provide "description"
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

void AppViewModel::updateSubGoalCompletionStatus()
{
    emit subGoalCompletionChanged();
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

// --- Property Setters ---
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

// --- Q_INVOKABLE Methods ---
void AppViewModel::loadData() {
    QString dataPath = QStandardPaths::writableLocation(QStandardPaths::AppDataLocation);
    QDir dir(dataPath);
    if (!dir.exists()) {
        dir.mkpath(".");
    }
    QString filePath = dataPath + "/tasks.json";
    m_taskManager.loadFromFile(filePath.toStdString());

    updateGoalProperties();
    updateSubGoalListModel();

    // --- НОВАЯ ЛОГИКА ---
    // Если список не пуст, выбираем первый SubGoal по умолчанию
    if (!m_subGoals.empty()) {
        selectSubGoal(m_subGoals.front().id);
    }
}

void AppViewModel::saveData() {
    m_taskManager.saveToFile(getTasksFilePath().toStdString());
    qDebug() << "Data saved to" << getTasksFilePath();
}

void AppViewModel::setMainGoal(const QString& name, const QString& description) {
    m_currentGoal.description = name.toStdString();
    m_currentGoal.targetDate = description.toStdString();
    m_taskManager.setGoal(m_currentGoal);
    saveData();
    emit currentGoalChanged();
}

// --- SubGoal Methods ---
void AppViewModel::addSubGoal(const QString& name) {
    if (name.isEmpty()) return;

    SubGoal sg;
    sg.description = name.toStdString();
    m_taskManager.addSubGoal(sg);
    saveData();
    updateSubGoalListModel(); // Обновляем список в модели

    // --- НОВАЯ ЛОГИКА ---
    // Если это был первый добавленный элемент, выбираем его
    if (m_subGoals.size() == 1) {
        selectSubGoal(m_subGoals.back().id);
    }
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

    // Находим индекс удаляемого элемента
    int indexToRemove = -1;
    for (int i = 0; i < m_subGoals.size(); ++i) {
        if (m_subGoals[i].id == id) {
            indexToRemove = i;
            break;
        }
    }

    if (indexToRemove == -1) return; // Элемент не найден

    // --- КЛЮЧЕВАЯ ЛОГИКА ВЫБОРА НОВОГО ЭЛЕМЕНТА ---
    int newIdToSelect = 0;
    if (id == m_selectedSubGoalId) { // Если удаляем выбранный элемент
        if (m_subGoals.size() > 1) {
            // Если удаляем не первый, выбираем предыдущий.
            // Если удаляем первый, выбираем новый первый (который был вторым).
            int newIndex = (indexToRemove > 0) ? (indexToRemove - 1) : 0;
            // Получаем ID нового элемента ДО удаления старого
            newIdToSelect = m_subGoals[newIndex].id;
            // Если удаляли первый, а выбрали новый первый, ID может совпасть.
            // Поэтому, если удаляем первый, то выбираем следующий за ним.
            if (indexToRemove == 0) {
                newIdToSelect = m_subGoals[1].id;
            }
        }
    } else {
        // Если удаляем НЕ выбранный элемент, то выделение остается на месте
        newIdToSelect = m_selectedSubGoalId;
    }

    // Удаляем SubGoal из TaskManager
    m_taskManager.deleteSubGoal(id);
    saveData();
    updateSubGoalListModel(); // Обновляем список m_subGoals

    // Выбираем новый элемент или очищаем, если список пуст
    if (!m_subGoals.empty()) {
        selectSubGoal(newIdToSelect);
    } else {
        // Список стал пустым
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
    // Проверяем, существует ли еще такой ID
    bool idExists = false;
    for(const auto& sg : m_subGoals) {
        if (sg.id == id) {
            idExists = true;
            break;
        }
    }
    // Если ID не существует (например, после удаления), но список не пуст, выбираем первый
    if (!idExists && !m_subGoals.empty()) {
        id = m_subGoals.front().id;
    } else if (m_subGoals.empty()) {
        id = 0; // Список пуст
    }


    if (m_selectedSubGoalId != id) {
        m_selectedSubGoalId = id;
        qDebug() << "SubGoal selected:" << m_selectedSubGoalId;
        updateTasksListModel();
        emit selectedSubGoalChanged();
        // emit subGoalsChanged(); // Этот сигнал лучше не трогать, чтобы избежать перерисовки всего списка
    }
}

// --- Task Methods ---
void AppViewModel::addTask(const QString& description) {
    addTaskToCurrentSubGoal(description);
}

void AppViewModel::addTaskToCurrentSubGoal(const QString& description) {
    if (description.isEmpty()) {
        qDebug() << "Cannot add task: description is empty";
        return;
    }

    if (m_selectedSubGoalId == 0) {
        qDebug() << "Cannot add task: no subgoal selected";
        return;
    }

    m_taskManager.addTask(description.toStdString(), "", m_selectedSubGoalId);
    saveData();
    updateTasksListModel();
    qDebug() << "Added task:" << description << "to SubGoal:" << m_selectedSubGoalId;
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
    updateTasksListModel(); //Update the model to refresh the UI
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

// --- Private Helper Methods ---
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


void AppViewModel::clearAllData() {
    // Clear all data and reset to defaults
    m_taskManager = TaskManager(); // Reset to default state

    // Set default goal
    Goal defaultGoal;
    defaultGoal.id = 1;
    defaultGoal.description = "My Main Goal";
    defaultGoal.targetDate = "Set your target date";
    m_taskManager.setGoal(defaultGoal);

    // Add default subgoal
    SubGoal defaultSubGoal;
    defaultSubGoal.description = "First Sub Goal";
    m_taskManager.addSubGoal(defaultSubGoal);

    // Update UI
    updateGoalProperties();
    updateSubGoalListModel();

    // Select the default subgoal
    if (!m_subGoals.empty()) {
        selectSubGoal(m_subGoals[0].id);
    }

    // Save the cleared state
    saveData();
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
    return QStandardPaths::writableLocation(QStandardPaths::DocumentsLocation);
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

    // Clean up temp file
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

        // Create backup of current data before importing
        QString backupPath = getTasksFilePath() + ".backup";
        m_taskManager.saveToFile(backupPath.toStdString());
        qDebug() << "Created backup at:" << backupPath;

        // Save JSON to temporary file and load
        QString tempPath = getTasksFilePath() + ".import_temp";
        QFile tempFile(tempPath);
        if (!tempFile.open(QIODevice::WriteOnly | QIODevice::Text)) {
            qDebug() << "Failed to create temporary import file";
            return;
        }

        QTextStream out(&tempFile);
        out << jsonData;
        tempFile.close();

        // Load from temporary file
        m_taskManager.loadFromFile(tempPath.toStdString());

        // Clean up temp file
        QFile::remove(tempPath);

        // Update UI
        updateGoalProperties();
        updateSubGoalListModel();

        // Select first subgoal if available
        if (!m_subGoals.empty()) {
            selectSubGoal(m_subGoals[0].id);
        } else {
            m_selectedSubGoalId = 0;
            updateTasksListModel();
            emit selectedSubGoalChanged();
        }

        // Save the imported data
        saveData();
        qDebug() << "Import completed successfully";

    } catch (const std::exception& e) {
        qDebug() << "Import error:" << e.what();
        // Restore from backup if import failed
        QString backupPath = getTasksFilePath() + ".backup";
        try {
            m_taskManager.loadFromFile(backupPath.toStdString());
            updateGoalProperties();
            updateSubGoalListModel();
            updateTasksListModel();
            qDebug() << "Restored from backup after failed import";
        } catch (const std::exception& restoreError) {
            qDebug() << "Failed to restore from backup:" << restoreError.what();
        }
    }
}

int AppViewModel::selectedTaskId() const
{
    return m_selectedTaskId;
}

void AppViewModel::selectTask(int id)
{
    if (m_selectedTaskId != id) {
        m_selectedTaskId = id;
        emit selectedTaskChanged();
    }
}
