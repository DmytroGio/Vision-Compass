#include "mainwindow.h"
#include <QVBoxLayout>
#include <QGraphicsEllipseItem>
#include <QGraphicsTextItem>
#include <QInputDialog>
#include <QMouseEvent>
#include <QFontMetrics>
#include <cmath>

// MainWindow constructor
MainWindow::MainWindow(QWidget *parent)
    : QMainWindow(parent)
{
    QWidget* central = new QWidget(this);
    QVBoxLayout* layout = new QVBoxLayout(central);

    // Circle visualization for main goal and subgoals
    graphicsView = new QGraphicsView(this);
    scene = new QGraphicsScene(this);
    graphicsView->setScene(scene);
    graphicsView->setFixedHeight(400);

    // Task list
    taskListWidget = new QListWidget(this);
    taskListWidget->setStyleSheet(
        "QListWidget{background:#222;color:#fff;}"
        "QListWidget::item{background:#ddd; color:#222; margin:8px; border-radius:10px; padding:10px;}"
        );

    // Add button
    addButton = new QPushButton("+", this);
    addButton->setFixedSize(60, 60);
    addButton->setStyleSheet("QPushButton{border-radius:30px; background:#fff; font-size:36px;}");

    layout->addWidget(graphicsView);
    layout->addWidget(taskListWidget);
    layout->addWidget(addButton, 0, Qt::AlignHCenter | Qt::AlignBottom);

    setCentralWidget(central);

    drawGoalView();
    updateTaskList();

    connect(addButton, &QPushButton::clicked, this, &MainWindow::onAddButtonClicked);
    connect(taskListWidget, &QListWidget::itemDoubleClicked, this, &MainWindow::onTaskDoubleClicked);
}

// MainWindow destructor
MainWindow::~MainWindow() = default;

// Draws the main goal and subgoals as circles/arcs with labels
void MainWindow::drawGoalView()
{
    scene->clear();

    int w = graphicsView->width();
    int h = graphicsView->height();
    int centerX = w/2, centerY = h/2+80;
    int outerR = 350, innerR = 200;

    // Outer circle (sub goals)
    scene->addEllipse(centerX-outerR/2, centerY-outerR/2, outerR, outerR, QPen(Qt::NoPen), QBrush(QColor("#F3C44A")));
    // Inner circle (main goal)
    scene->addEllipse(centerX-innerR/2, centerY-innerR/2, innerR, innerR, QPen(Qt::NoPen), QBrush(QColor("#E95B5B")));

    // Main goal label
    Goal goal = manager.getGoal();
    QGraphicsTextItem* mainTitle = scene->addText(QString::fromStdString(goal.description), QFont("Arial", 32, QFont::Bold));
    mainTitle->setDefaultTextColor(Qt::white);
    mainTitle->setPos(centerX - mainTitle->boundingRect().width()/2, centerY-innerR/2 + 16);

    // SubGoals on arc
    auto subGoals = manager.getSubGoals();
    int n = subGoals.size();
    if (n == 0)
        return;

    // Place subgoals on an arc, clickable
    for (int i = 0; i < n; ++i) {
        double angle = M_PI/2 + (n==1 ? 0 : i*M_PI/(n-1)); // spread on top arc
        int rx = centerX + std::cos(angle)*(outerR/2-40);
        int ry = centerY - std::sin(angle)*(outerR/2-40);

        QGraphicsTextItem* txt = scene->addText(QString::fromStdString(subGoals[i].description), QFont("Arial", 20, QFont::Bold));
        txt->setDefaultTextColor(subGoals[i].id == currentSubGoalId ? QColor("#B6FFD7") : QColor("#222"));
        txt->setPos(rx-txt->boundingRect().width()/2, ry-txt->boundingRect().height()/2);

        // Mouse area for subgoal selection (not interactive yet)
        QRectF rect = txt->boundingRect().translated(txt->pos());
        QGraphicsRectItem* hitRect = scene->addRect(rect, QPen(Qt::NoPen), QBrush(Qt::NoBrush));
        hitRect->setData(0, subGoals[i].id);
        hitRect->setFlag(QGraphicsItem::ItemHasNoContents, true); // Invisible
        hitRect->setAcceptHoverEvents(true);
        hitRect->setAcceptedMouseButtons(Qt::LeftButton);
        // For real interactivity, you would subclass QGraphicsRectItem or install an event filter
    }
}

// Updates the task list widget according to the selected subgoal
void MainWindow::updateTaskList()
{
    taskListWidget->clear();
    if (currentSubGoalId == 0) return;
    auto tasks = manager.getTasksForSubGoal(currentSubGoalId);
    for (const auto& t : tasks) {
        auto* item = new QListWidgetItem(QString("• ") + QString::fromStdString(t.description));
        taskListWidget->addItem(item);
    }
}

// Slot: called when a subgoal is clicked (stub implementation)
// You need to connect QGraphicsRectItem clicks to this slot for real interactivity
void MainWindow::onSubGoalClicked(int subGoalId)
{
    currentSubGoalId = subGoalId;
    updateTaskList();
    drawGoalView();
}

// Slot: called when "+" button is clicked
void MainWindow::onAddButtonClicked()
{
    if(currentSubGoalId == 0) {
        // Add SubGoal
        bool ok;
        QString txt = QInputDialog::getText(this, "New SubGoal", "Description:", QLineEdit::Normal, "", &ok);
        if(ok && !txt.isEmpty()) {
            SubGoal sg;
            sg.description = txt.toStdString();
            manager.addSubGoal(sg);
            drawGoalView();
        }
    } else {
        // Add Task
        bool ok;
        QString txt = QInputDialog::getText(this, "New Task", "Description:", QLineEdit::Normal, "", &ok);
        if(ok && !txt.isEmpty()) {
            manager.addTask(txt.toStdString(), "", currentSubGoalId);
            updateTaskList();
        }
    }
}

// Slot: called when a task is double-clicked for editing
void MainWindow::onTaskDoubleClicked(QListWidgetItem* item)
{
    int row = taskListWidget->row(item);
    auto tasks = manager.getTasksForSubGoal(currentSubGoalId);
    if (row < 0 || row >= static_cast<int>(tasks.size())) return;
    bool ok;
    QString txt = QInputDialog::getText(this, "Edit Task", "Description:", QLineEdit::Normal, QString::fromStdString(tasks[row].description), &ok);
    if(ok && !txt.isEmpty()) {
        manager.editTask(tasks[row].id, txt.toStdString(), "", currentSubGoalId);
        updateTaskList();
    }
}
