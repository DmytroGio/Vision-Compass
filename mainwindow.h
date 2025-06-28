#ifndef MAINWINDOW_H
#define MAINWINDOW_H

#include <QMainWindow>
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
    MainWindow(QWidget *parent = nullptr);
    ~MainWindow();

private slots:
    void on_addGoalButton_clicked();
    void on_editGoalButton_clicked();
    void on_addMilestoneButton_clicked();
    void on_milestoneListWidget_currentRowChanged(int row);
    void on_addTaskButton_clicked();

private:
    void updateGoalView();
    void updateMilestoneList();
    void updateTaskList();

    Ui::MainWindow *ui;
    TaskManager manager;
    int currentMilestoneId; // 0 - не выбран этап
};

#endif // MAINWINDOW_H
