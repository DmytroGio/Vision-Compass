#include "appviewmodel.h"
#include <QDebug>
#include <QStandardPaths>
#include <QDir>

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
}

void AppViewModel::saveData() {
    m_taskManager.saveToFile("tasks.json");
    qDebug() << "Data saved to tasks.json";
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
    updateSubGoalListModel();

    // Auto-select the new subgoal if it's the first one
    if (m_selectedSubGoalId == 0 && !m_subGoals.empty()) {
        m_selectedSubGoalId = m_subGoals.back().id;
        updateTasksListModel();
        emit selectedSubGoalChanged();
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
    // Delegate deletion to TaskManager, which handles cascading tasks deletion
    m_taskManager.deleteSubGoal(id);

    saveData();

    updateSubGoalListModel();

    // Handle selection change
    if (id == m_selectedSubGoalId) {
        // If the deleted subgoal was selected, clear selection or select another one
        // Re-fetch subgoals from TaskManager to get the updated list
        m_subGoals = m_taskManager.getSubGoals();

        if (!m_subGoals.empty()) {
            m_selectedSubGoalId = m_subGoals.front().id;
        } else {
            m_selectedSubGoalId = 0;
        }
        updateTasksListModel();
        emit selectedSubGoalChanged();
    } else {
        updateTasksListModel();
    }

    qDebug() << "Deleted subgoal ID:" << id;
}

void AppViewModel::removeSubGoal(const QVariantMap& subGoalData) {
    int id = subGoalData.value("id").toInt();
    deleteSubGoal(id);
}

void AppViewModel::selectSubGoal(int id) {
    if (m_selectedSubGoalId != id) {
        m_selectedSubGoalId = id;
        qDebug() << "SubGoal selected:" << m_selectedSubGoalId;
        updateTasksListModel();
        emit selectedSubGoalChanged();
        emit subGoalsChanged(); // Update UI selection
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
    emit currentTasksChanged();
}
