#ifndef MAINWINDOW_H
#define MAINWINDOW_H

#include <QMainWindow>
#include <QGraphicsView>
#include <QGraphicsScene>
#include <QListWidget>
#include <QPushButton>
#include "task_manager.hpp"

QT_BEGIN_NAMESPACE
namespace Ui {
class MainWindow;
}
QT_END_NAMESPACE

class MainWindow : public QMainWindow
{
    Q_OBJECT

public:
    explicit MainWindow(QWidget *parent = nullptr);
    ~MainWindow();

private slots:
    // Called when a subgoal (milestone) is clicked in the graphics view
    void onSubGoalClicked(int subGoalId);

    // Called when the "+" button is clicked
    void onAddButtonClicked();

    // Called when a task item is double-clicked for editing
    void onTaskDoubleClicked(QListWidgetItem* item);

private:
    // Draws the main goal and subgoals as circles in the graphics view
    void drawGoalView();

    // Updates the task list widget according to the selected subgoal
    void updateTaskList();

    QGraphicsView* graphicsView;    // View for goal/subgoal visualization
    QGraphicsScene* scene;          // Scene for custom drawing
    QListWidget* taskListWidget;    // Task list for the selected subgoal
    QPushButton* addButton;         // "+" button for adding subgoals or tasks
    TaskManager manager;            // Main data manager
    int currentSubGoalId = 0;       // Currently selected subgoal (0 = none)
};

#endif // MAINWINDOW_H
