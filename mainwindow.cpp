#include "mainwindow.h"
#include "./ui_mainwindow.h"
#include <QMessageBox>
#include <QString>
#include <QInputDialog>
#include <QDate>

MainWindow::MainWindow(QWidget *parent)
    : QMainWindow(parent)
    , ui(new Ui::MainWindow)
    , currentMilestoneId(0)
{
    ui->setupUi(this);

    // Priority combobox
    ui->priorityComboBox->addItem("Low");
    ui->priorityComboBox->addItem("Medium");
    ui->priorityComboBox->addItem("High");

    manager.loadFromFile("tasks.json");

    updateGoalView();
    updateMilestoneList();
    updateTaskList();

    connect(ui->addGoalButton, &QPushButton::clicked, this, &MainWindow::on_addGoalButton_clicked);
    connect(ui->editGoalButton, &QPushButton::clicked, this, &MainWindow::on_editGoalButton_clicked);
    connect(ui->addMilestoneButton, &QPushButton::clicked, this, &MainWindow::on_addMilestoneButton_clicked);
    connect(ui->milestoneListWidget, &QListWidget::currentRowChanged, this, &MainWindow::on_milestoneListWidget_currentRowChanged);
    connect(ui->addTaskButton, &QPushButton::clicked, this, &MainWindow::on_addTaskButton_clicked);
}

MainWindow::~MainWindow()
{
    manager.saveToFile("tasks.json");
    delete ui;
}

void MainWindow::updateGoalView()
{
    Goal goal = manager.getGoal();
    if (goal.description.empty()) {
        ui->goalLabel->setText("Main goal is not set.");
    } else {
        ui->goalLabel->setText(QString("Main goal: %1 (by %2)")
            .arg(QString::fromStdString(goal.description))
            .arg(QString::fromStdString(goal.targetDate)));
    }
}

void MainWindow::updateMilestoneList()
{
    ui->milestoneListWidget->clear();
    const auto& milestones = manager.getMilestones();
    for (const auto& m : milestones) {
        QString text = QString("%1 (%2 — %3)")
            .arg(QString::fromStdString(m.description))
            .arg(QString::fromStdString(m.startDate))
            .arg(QString::fromStdString(m.endDate));
        QListWidgetItem* item = new QListWidgetItem(text);
        item->setData(Qt::UserRole, m.id);
        ui->milestoneListWidget->addItem(item);
    }
    // Reset selection after update
    if (!milestones.empty()) {
        ui->milestoneListWidget->setCurrentRow(0);
        currentMilestoneId = milestones.front().id;
    } else {
        currentMilestoneId = 0;
    }
}

void MainWindow::updateTaskList()
{
    ui->taskListWidget->clear();
    if (currentMilestoneId == 0)
        return;
    const auto& tasks = manager.getTasksForMilestone(currentMilestoneId);
    for (const auto& t : tasks) {
        QString prioStr;
        switch (t.priority) {
            case Priority::Low: prioStr = "Low"; break;
            case Priority::Medium: prioStr = "Medium"; break;
            case Priority::High: prioStr = "High"; break;
        }
        QString item = QString("[%1] %2: %3 (Priority: %4, Due: %5)")
            .arg(t.completed ? "x" : " ")
            .arg(t.id)
            .arg(QString::fromStdString(t.description))
            .arg(prioStr)
            .arg(QString::fromStdString(t.dueDate));
        ui->taskListWidget->addItem(item);
    }
}

// Goal
void MainWindow::on_addGoalButton_clicked()
{
    bool ok;
    QString desc = QInputDialog::getText(this, "New Goal", "Goal description:", QLineEdit::Normal, "", &ok);
    if (!ok || desc.trimmed().isEmpty()) return;
    QString date = QInputDialog::getText(this, "New Goal", "Target date (YYYY-MM-DD):", QLineEdit::Normal, "", &ok);
    if (!ok || QDate::fromString(date, "yyyy-MM-dd").isValid() == false) {
        QMessageBox::warning(this, "Input error", "Date must be in YYYY-MM-DD format.");
        return;
    }
    Goal g;
    g.id = 0;
    g.description = desc.trimmed().toStdString();
    g.targetDate = date.trimmed().toStdString();
    manager.setGoal(g);
    updateGoalView();
}

void MainWindow::on_editGoalButton_clicked()
{
    Goal g = manager.getGoal();
    if (g.id == 0) return;
    bool ok;
    QString desc = QInputDialog::getText(this, "Edit Goal", "Goal description:", QLineEdit::Normal, QString::fromStdString(g.description), &ok);
    if (!ok || desc.trimmed().isEmpty()) return;
    QString date = QInputDialog::getText(this, "Edit Goal", "Target date (YYYY-MM-DD):", QLineEdit::Normal, QString::fromStdString(g.targetDate), &ok);
    if (!ok || QDate::fromString(date, "yyyy-MM-dd").isValid() == false) {
        QMessageBox::warning(this, "Input error", "Date must be in YYYY-MM-DD format.");
        return;
    }
    g.description = desc.trimmed().toStdString();
    g.targetDate = date.trimmed().toStdString();
    manager.setGoal(g);
    updateGoalView();
}

// Milestones
void MainWindow::on_addMilestoneButton_clicked()
{
    if (manager.getGoal().id == 0) {
        QMessageBox::warning(this, "Input error", "Please set a main goal first!");
        return;
    }
    bool ok;
    QString desc = QInputDialog::getText(this, "New Milestone", "Milestone description:", QLineEdit::Normal, "", &ok);
    if (!ok || desc.trimmed().isEmpty()) return;
    QString start = QInputDialog::getText(this, "New Milestone", "Start date (YYYY-MM-DD):", QLineEdit::Normal, "", &ok);
    if (!ok || QDate::fromString(start, "yyyy-MM-dd").isValid() == false) {
        QMessageBox::warning(this, "Input error", "Date must be in YYYY-MM-DD format.");
        return;
    }
    QString end = QInputDialog::getText(this, "New Milestone", "End date (YYYY-MM-DD):", QLineEdit::Normal, "", &ok);
    if (!ok || QDate::fromString(end, "yyyy-MM-dd").isValid() == false) {
        QMessageBox::warning(this, "Input error", "Date must be in YYYY-MM-DD format.");
        return;
    }
    Milestone m;
    m.id = 0;
    m.description = desc.trimmed().toStdString();
    m.startDate = start.trimmed().toStdString();
    m.endDate = end.trimmed().toStdString();
    m.goalId = manager.getGoal().id;
    manager.addMilestone(m);
    updateMilestoneList();
    updateTaskList();
}

void MainWindow::on_milestoneListWidget_currentRowChanged(int row)
{
    if (row < 0) {
        currentMilestoneId = 0;
        ui->taskListWidget->clear();
        return;
    }
    QListWidgetItem* item = ui->milestoneListWidget->item(row);
    if (!item) return;
    currentMilestoneId = item->data(Qt::UserRole).toInt();
    updateTaskList();
}

// Tasks
void MainWindow::on_addTaskButton_clicked()
{
    if (currentMilestoneId == 0) {
        QMessageBox::warning(this, "Input error", "Please select a milestone first!");
        return;
    }
    QString desc = ui->descriptionLineEdit->text().trimmed();
    QString due = ui->dueDateEdit->text().trimmed();
    int prioIdx = ui->priorityComboBox->currentIndex();

    if (desc.isEmpty() || due.isEmpty()) {
        QMessageBox::warning(this, "Input error", "Please enter a description and due date.");
        return;
    }
    QDate date = QDate::fromString(due, "yyyy-MM-dd");
    if (!date.isValid()) {
        QMessageBox::warning(this, "Input error", "Date must be in YYYY-MM-DD format.");
        return;
    }

    Priority prio = static_cast<Priority>(prioIdx);
    manager.addTask(desc.toStdString(), prio, due.toStdString(), currentMilestoneId);
    updateTaskList();

    ui->descriptionLineEdit->clear();
    ui->dueDateEdit->clear();
    ui->priorityComboBox->setCurrentIndex(0);
}