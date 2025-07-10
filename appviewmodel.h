#ifndef APPVIEWMODEL_H
#define APPVIEWMODEL_H

#include <QObject>
#include <QString>
#include <QVariantList>
#include <QVariantMap>
#include "task_manager.hpp"

class AppViewModel : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString currentGoalText READ currentGoalText WRITE setCurrentGoalText NOTIFY currentGoalChanged)
    Q_PROPERTY(QString currentGoalDescription READ currentGoalDescription WRITE setCurrentGoalDescription NOTIFY currentGoalChanged)
    Q_PROPERTY(QVariantList subGoalsListModel READ subGoalsListModel NOTIFY subGoalsChanged)
    Q_PROPERTY(QVariantList currentTasksListModel READ currentTasksListModel NOTIFY currentTasksChanged)
    Q_PROPERTY(int selectedSubGoalId READ selectedSubGoalId NOTIFY selectedSubGoalChanged)
    Q_PROPERTY(QString selectedSubGoalName READ selectedSubGoalName NOTIFY selectedSubGoalChanged)

public:
    explicit AppViewModel(QObject *parent = nullptr);

    // Property getters
    QString currentGoalText() const;
    QString currentGoalDescription() const;
    QVariantList subGoalsListModel() const;
    QVariantList currentTasksListModel() const;
    int selectedSubGoalId() const;
    QString selectedSubGoalName() const;

    // Property setters
    void setCurrentGoalText(const QString& text);
    void setCurrentGoalDescription(const QString& description);

    // Q_INVOKABLE methods - matching QML calls
    Q_INVOKABLE void loadData();
    Q_INVOKABLE void saveData();

    // Goal methods
    Q_INVOKABLE void setMainGoal(const QString& name, const QString& description);

    // SubGoal methods (matching QML calls)
    Q_INVOKABLE void addSubGoal(const QString& name);
    Q_INVOKABLE void editSubGoal(int id, const QString& newName);
    Q_INVOKABLE void deleteSubGoal(int id);
    Q_INVOKABLE void removeSubGoal(const QVariantMap& subGoalData); // For QML compatibility
    Q_INVOKABLE void selectSubGoal(int id);

    // Task methods (matching QML calls)
    Q_INVOKABLE void addTask(const QString& description);
    Q_INVOKABLE void addTaskToCurrentSubGoal(const QString& description);
    Q_INVOKABLE void editTask(int id, const QString& newDescription);
    Q_INVOKABLE void deleteTask(int id);
    Q_INVOKABLE void removeTask(const QVariantMap& taskData); // For QML compatibility

signals:
    void currentGoalChanged();
    void subGoalsChanged();
    void currentTasksChanged();
    void selectedSubGoalChanged();

private:
    void updateGoalProperties();
    void updateSubGoalListModel();
    void updateTasksListModel();

    TaskManager m_taskManager;
    Goal m_currentGoal;
    std::vector<SubGoal> m_subGoals;
    std::vector<Task> m_currentTasks;
    int m_selectedSubGoalId = 0;
};

#endif // APPVIEWMODEL_H
