#include "appviewmodel.h"
#include <QDebug> // For logging/debugging

AppViewModel::AppViewModel(QObject *parent) : QObject(parent)
{
    loadData(); // Load data when the ViewModel is created
}

// --- Property Getters ---
QString AppViewModel::currentGoalText() const {
    return QString::fromStdString(m_currentGoal.description);
}

QString AppViewModel::currentGoalDescription() const {
    // Assuming Goal struct might have a separate detailed description field later,
    // or we can use targetDate for now if it's more relevant.
    // For this example, let's use targetDate as a placeholder for a second line.
    return QString::fromStdString(m_currentGoal.targetDate);
}

QVariantList AppViewModel::subGoalsListModel() const {
    QVariantList list;
    for (const auto& sg : m_subGoals) {
        QVariantMap map;
        map.insert("id", sg.id);
        map.insert("name", QString::fromStdString(sg.description));
        // Add other SubGoal properties if needed in QML
        list.append(map);
    }
    return list;
}

QVariantList AppViewModel::currentTasksListModel() const {
    QVariantList list;
    for (const auto& task : m_currentTasks) {
        QVariantMap map;
        map.insert("id", task.id);
        map.insert("description", QString::fromStdString(task.description));
        map.insert("completed", task.completed);
        // Add other Task properties if needed in QML (e.g., dueDate)
        list.append(map);
    }
    return list;
}

int AppViewModel::selectedSubGoalId() const {
    return m_selectedSubGoalId;
}

// --- Property Setters ---
// These are primarily for QML to notify C++ of changes if direct binding is used.
// For Goal, we'll use explicit setMainGoal method.
void AppViewModel::setCurrentGoalText(const QString& text) {
    if (QString::fromStdString(m_currentGoal.description) != text) {
        m_currentGoal.description = text.toStdString();
        // In a more robust system, you might have a temporary edit state
        // and then an explicit save action. For now, let's assume direct change.
        m_taskManager.setGoal(m_currentGoal);
        saveData(); // Auto-save
        emit currentGoalChanged();
    }
}

void AppViewModel::setCurrentGoalDescription(const QString& description) {
    if (QString::fromStdString(m_currentGoal.targetDate) != description) {
        m_currentGoal.targetDate = description.toStdString(); // Using targetDate as 'description line 2'
        m_taskManager.setGoal(m_currentGoal);
        saveData(); // Auto-save
        emit currentGoalChanged();
    }
}


// --- Q_INVOKABLE Methods ---
void AppViewModel::loadData() {
    m_taskManager.loadFromFile("tasks.json");
    updateGoalProperties();
    updateSubGoalListModel();
    // Initially, no subgoal is selected, or select the first one if available
    if (!m_subGoals.empty()) {
        // selectSubGoal(m_subGoals.front().id); // Optionally select first subgoal
        m_selectedSubGoalId = 0; // Or ensure no selection
        updateTasksListModel(); // this will be empty if m_selectedSubGoalId is 0
    } else {
        m_selectedSubGoalId = 0;
        updateTasksListModel();
    }
    emit selectedSubGoalChanged(); // Ensure QML is notified of initial state
}

void AppViewModel::saveData() {
    m_taskManager.saveToFile("tasks.json");
    qDebug() << "Data saved to tasks.json";
}

void AppViewModel::setMainGoal(const QString& name, const QString& description) {
    m_currentGoal.description = name.toStdString();
    m_currentGoal.targetDate = description.toStdString(); // Using targetDate for description line 2
    m_taskManager.setGoal(m_currentGoal);
    saveData();
    emit currentGoalChanged();
}

void AppViewModel::addSubGoal(const QString& name) {
    if (name.isEmpty()) return;
    SubGoal sg;
    sg.description = name.toStdString();
    m_taskManager.addSubGoal(sg);
    saveData();
    updateSubGoalListModel();
}

void AppViewModel::editSubGoal(int id, const QString& newName) {
    if (newName.isEmpty()) return;
    SubGoal sg = m_taskManager.getSubGoalById(id);
    if (sg.id == 0) return; // Not found

    sg.description = newName.toStdString();
    m_taskManager.editSubGoal(id, sg);
    saveData();
    updateSubGoalListModel();
    if (id == m_selectedSubGoalId) { // If editing the currently selected subgoal
        emit currentGoalChanged(); // To update any display that might show its name
    }
}

void AppViewModel::deleteSubGoal(int id) {
    // Remove from local ViewModel copy
    m_subGoals.erase(
        std::remove_if(m_subGoals.begin(), m_subGoals.end(),
            [id](const SubGoal& sg){ return sg.id == id; }),
        m_subGoals.end()
    );
    m_taskManager.deleteSubGoal(id); // Call the implemented TaskManager method
    saveData();
    updateSubGoalListModel(); // This will fetch the updated list from TaskManager
    if (id == m_selectedSubGoalId) {
        m_selectedSubGoalId = 0;
        updateTasksListModel();
        emit selectedSubGoalChanged();
    }
    qDebug() << "Attempted to delete subgoal ID:" << id << "(ViewModel needs TaskManager update for proper delete)";
}

void AppViewModel::selectSubGoal(int id) {
    if (m_selectedSubGoalId != id) {
        m_selectedSubGoalId = id;
        qDebug() << "SubGoal selected:" << m_selectedSubGoalId;
        updateTasksListModel();
        emit selectedSubGoalChanged();
        // Also emit subGoalsChanged to allow QML to update selection visuals
        emit subGoalsChanged();
    }
}

void AppViewModel::addTaskToCurrentSubGoal(const QString& description) {
    if (description.isEmpty() || m_selectedSubGoalId == 0) return;
    m_taskManager.addTask(description.toStdString(), "", m_selectedSubGoalId);
    saveData();
    updateTasksListModel();
}

void AppViewModel::editTask(int id, const QString& newDescription) {
    if (newDescription.isEmpty()) return;
    // DueDate is not handled by UI yet, pass empty
    m_taskManager.editTask(id, newDescription.toStdString(), "", m_selectedSubGoalId);
    saveData();
    updateTasksListModel();
}

void AppViewModel::deleteTask(int id) {
    m_taskManager.deleteTask(id);
    saveData();
    updateTasksListModel();
}

// --- Private Helper Methods ---
void AppViewModel::updateGoalProperties() {
    m_currentGoal = m_taskManager.getGoal();
    emit currentGoalChanged();
}

void AppViewModel::updateSubGoalListModel() {
    m_subGoals = m_taskManager.getSubGoals(); // Fetch fresh list
    emit subGoalsChanged();
}

void AppViewModel::updateTasksListModel() {
    if (m_selectedSubGoalId != 0) {
        m_currentTasks = m_taskManager.getTasksForSubGoal(m_selectedSubGoalId);
    } else {
        m_currentTasks.clear();
    }
    emit currentTasksChanged();
}
