import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import com.visioncompass.data 1.0

ApplicationWindow {
    id: mainWindow
    visible: true
    width: 800
    height: 750
    minimumWidth: 800
    maximumWidth: 800
    minimumHeight: 750
    maximumHeight: 750
    title: "Vision Compass (QML)"

    // Make AppViewModel available in this QML file
 

    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        // --- Верхняя секция (половина большого круга) ---
        Item {
            id: topSection
            Layout.fillWidth: true
            Layout.preferredHeight: mainWindow.height / 2

            // Gray background
            Rectangle {
                anchors.fill: parent
                color: "#282828"
                z: 0
            }

            Canvas {
                id: bigCircle
                anchors.fill: parent
                onPaint: {
                    var ctx = getContext("2d");
                    ctx.clearRect(0, 0, width, height);
                    var radius = width > height ? width * 0.9 : height * 1.8;
                    ctx.beginPath();
                    ctx.arc(width / 2, 0, radius / 2, 0, Math.PI, false);
                    ctx.closePath();
                    ctx.fillStyle = "#F3C44A";
                    ctx.fill();
                }
            }

            // Красный круг (Goal) - упрощенная версия
            Rectangle {
                id: goalCircle
                width: topSection.height * 1 // Примерный размер
                height: width
                radius: width / 2
                color: "#E95B5B" // Красный цвет
                anchors.horizontalCenter: parent.horizontalCenter
                y: -height / 3 // Смещаем вверх, чтобы "обрезать"

                Column {
                    anchors.centerIn: parent
                    spacing: 10

                    Text {
                        id: goalNameText
                        text: AppViewModel.currentGoalText // Use singleton directly
                        font.pointSize: 20
                        font.bold: true
                        color: "white"
                        horizontalAlignment: Text.AlignHCenter
                        wrapMode: Text.WordWrap
                        width: goalCircle.width * 0.8
                    }
                    Text {
                        id: goalDescriptionText
                        text: AppViewModel.currentGoalDescription // Use singleton directly
                        font.pointSize: 12
                        color: "white"
                        horizontalAlignment: Text.AlignHCenter
                        wrapMode: Text.WordWrap
                        width: goalCircle.width * 0.8
                    }
                }
            }

            // Отображение SubGoals (пока очень упрощенно, без позиционирования на дуге)
            Row {
                id: subGoalRow // Placeholder for actual SubGoal items
                anchors.bottom: parent.bottom
                anchors.horizontalCenter: parent.horizontalCenter
                spacing: 20
                padding: 10

                // ListView for SubGoals
                ListView {
                    id: subGoalListView
                    anchors.fill: parent
                    clip: true
                    model: AppViewModel.subGoalsListModel // Direct binding
                    delegate: ItemDelegate {
                        width: parent.width
                        text: modelData.name // 'name' is what we defined in AppViewModel
                        highlighted: ListView.isCurrentItem // Highlight selected

                        Row {
                            anchors.right: parent.right
                            anchors.verticalCenter: parent.verticalCenter
                            spacing: 5
                            padding: 5

                            Button {
                                text: "Del"
                                onClicked: {
                                    AppViewModel.deleteSubGoal(modelData.id)
                                }
                            }
                        }
                        onClicked: {
                            subGoalListView.currentIndex = index
                            AppViewModel.selectSubGoal(modelData.id)
                        }
                    }
                    ScrollIndicator.vertical: ScrollIndicator { }
                }
            }
            
            // Кнопка добавления SubGoal (справа сверху на желтой области)
            Button {
                id: addSubGoalButtonTop
                text: "+"
                width: 50
                height: 50
                anchors.top: parent.top
                anchors.right: parent.right
                anchors.margins: 10
                font.pointSize: 20
                onClicked: {
                    addSubGoalDialog.open()
                }
            }
        }

        TextInputDialog {
            id: addSubGoalDialog
            title: "Add New Sub-Goal"
            textInput.placeholderText: "Enter sub-goal name"
            onAccepted: {
                if (textInput.text.trim() !== "") {
                    AppViewModel.addSubGoal(textInput.text.trim())
                }
            }
        }

        // --- Нижняя секция (Задачи) ---
        Rectangle {
            id: bottomSection
            Layout.fillWidth: true
            Layout.fillHeight: true // Занимает оставшееся место
            color: "#282828" // Темный фон для задач

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 10

                Text {
                    text: "Sub-objective task list:"
                    color: "#373737"
                    font.pointSize: 12
                    Layout.alignment: Qt.AlignLeft
                }

                // ListView for Tasks
                ListView {
                    id: taskListView
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    clip: true
                    model: AppViewModel.currentTasksListModel // Direct binding
                    delegate: ItemDelegate {
                        width: parent.width
                        text: modelData.description // 'description' from AppViewModel
                        // You can add more details like completion status here

                        Row {
                            anchors.right: parent.right
                            anchors.verticalCenter: parent.verticalCenter
                            spacing: 5
                            padding: 5

                            Button {
                                text: "Del"
                                onClicked: {
                                    AppViewModel.deleteTask(modelData.id)
                                }
                            }
                        }
                        // Add onClicked handler if tasks need to be selectable for editing, etc.
                    }
                    ScrollIndicator.vertical: ScrollIndicator { }

                    Text { // Placeholder when no tasks or no subgoal selected
                        anchors.centerIn: parent
                        text: AppViewModel.selectedSubGoalId === 0 ? "Select a sub-goal to see tasks" : (AppViewModel.currentTasksListModel.length === 0 ? "No tasks for this sub-goal" : "")
                        color: "lightgray"
                        font.italic: true
                        visible: AppViewModel.currentTasksListModel.length === 0 || AppViewModel.selectedSubGoalId === 0
                    }
                }

                 // Кнопка добавления Task (внизу по центру)
                Button {
                    id: addTaskButtonBottom
                    text: "+"
                    Layout.preferredWidth: 60
                    Layout.preferredHeight: 60
                    Layout.alignment: Qt.AlignHCenter
                    font.pointSize: 24
                    enabled: AppViewModel.selectedSubGoalId !== 0 // Enable only if a subgoal is selected
                    onClicked: {
                        addTaskDialog.open()
                    }
                }
            }
        }

        TextInputDialog {
            id: addTaskDialog
            title: "Add New Task"
            textInput.placeholderText: "Enter task description"
            onAccepted: {
                if (textInput.text.trim() !== "") {
                    AppViewModel.addTaskToCurrentSubGoal(textInput.text.trim())
                }
            }
        }
    }
}
