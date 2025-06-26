#include "mainwindow.h"
#include "./ui_mainwindow.h"
#include <QMessageBox>
#include <QString>
#include <QDate>

MainWindow::MainWindow(QWidget *parent)
    : QMainWindow(parent)
    , ui(new Ui::MainWindow)
{
    ui->setupUi(this);

    // Настроим комбобокс приоритета
    ui->priorityComboBox->addItem("Low");
    ui->priorityComboBox->addItem("Medium");
    ui->priorityComboBox->addItem("High");

    manager.loadFromFile("tasks.json");
    updateTaskList();

    connect(ui->addTaskButton, &QPushButton::clicked, this, &MainWindow::on_addTaskButton_clicked);
}

MainWindow::~MainWindow()
{
    manager.saveToFile("tasks.json");
    delete ui;
}

void MainWindow::updateTaskList()
{
    ui->taskListWidget->clear();
    // Для доступа к задачам нужен метод getTasks(), добавим его в TaskManager
    const auto& tasks = manager.getTasks();
    for (const auto& task : tasks) {
        QString prioStr;
        switch (task.priority) {
        case Priority::Low: prioStr = "Low"; break;
        case Priority::Medium: prioStr = "Medium"; break;
        case Priority::High: prioStr = "High"; break;
        }
        QString item = QString("[%1] %2: %3 (Priority: %4, Due: %5)")
                           .arg(task.completed ? "x" : " ")
                           .arg(task.id)
                           .arg(QString::fromStdString(task.description))
                           .arg(prioStr)
                           .arg(QString::fromStdString(task.dueDate));
        ui->taskListWidget->addItem(item);
    }
}

void MainWindow::on_addTaskButton_clicked()
{
    QString desc = ui->descriptionLineEdit->text().trimmed();
    QString due = ui->dueDateEdit->text().trimmed();
    int prioIdx = ui->priorityComboBox->currentIndex();

    if (desc.isEmpty() || due.isEmpty()) {
        QMessageBox::warning(this, "Input error", "Please enter description and due date.");
        return;
    }
    // Simple date validation (YYYY-MM-DD)
    QDate date = QDate::fromString(due, "yyyy-MM-dd");
    if (!date.isValid()) {
        QMessageBox::warning(this, "Input error", "Date format must be YYYY-MM-DD.");
        return;
    }

    Priority prio = static_cast<Priority>(prioIdx);
    manager.addTask(desc.toStdString(), prio, due.toStdString());
    updateTaskList();

    // Очистим поля
    ui->descriptionLineEdit->clear();
    ui->dueDateEdit->clear();
    ui->priorityComboBox->setCurrentIndex(0);
}
