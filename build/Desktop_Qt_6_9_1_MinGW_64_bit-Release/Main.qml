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
    // Create rectangle

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

            // Отображение SubGoals с использованием современного дизайна
            Rectangle {
                id: subGoalsContainer
                anchors.bottom: parent.bottom
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.margins: 20
                height: 120
                color: "transparent"

                ColumnLayout {
                    anchors.fill: parent
                    spacing: 10

                    // Заголовок секции SubGoals
                    Text {
                        text: "Sub Goals"
                        color: "#1E1E1E"
                        font.pointSize: 14
                        font.bold: true
                        Layout.alignment: Qt.AlignLeft
                    }

                    // Горизонтальный скролл для SubGoals
                    ScrollView {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        clip: true

                        ListView {
                            id: subGoalsList
                            orientation: ListView.Horizontal
                            model: AppViewModel.subGoalsListModel
                            spacing: 15

                            delegate: Rectangle {
                                width: 180
                                height: 80
                                color: "#2D2D2D"
                                radius: 15
                                border.color: "#F3C44A"
                                border.width: 2

                                // Верхняя цветная полоска
                                Rectangle {
                                    width: parent.width - 10
                                    height: 4
                                    anchors.top: parent.top
                                    anchors.topMargin: 5
                                    anchors.horizontalCenter: parent.horizontalCenter
                                    color: "#F3C44A"
                                    radius: 2
                                }

                                // Основное содержимое SubGoal
                                RowLayout {
                                    anchors.fill: parent
                                    anchors.margins: 12
                                    spacing: 10

                                    // Иконка SubGoal
                                    Rectangle {
                                        width: 30
                                        height: 30
                                        color: "#F3C44A"
                                        radius: 6

                                        Text {
                                            text: "◉"
                                            anchors.centerIn: parent
                                            font.pointSize: 14
                                            color: "#1E1E1E"
                                            font.bold: true
                                        }
                                    }

                                    // Текст SubGoal
                                    ColumnLayout {
                                        Layout.fillWidth: true
                                        spacing: 2

                                        Text {
                                            text: modelData.name
                                            color: "#FFFFFF"
                                            font.pointSize: 12
                                            font.bold: true
                                            Layout.fillWidth: true
                                            wrapMode: Text.WordWrap
                                            maximumLineCount: 2
                                            elide: Text.ElideRight
                                        }

                                        Text {
                                            text: "Active"
                                            color: "#F3C44A"
                                            font.pointSize: 9
                                            Layout.fillWidth: true
                                        }
                                    }

                                    // Кнопка удаления
                                    Rectangle {
                                        width: 25
                                        height: 25
                                        color: "#E95B5B"
                                        radius: 12

                                        Text {
                                            text: "✕"
                                            anchors.centerIn: parent
                                            font.pointSize: 12
                                            color: "#FFFFFF"
                                            font.bold: true
                                        }

                                        MouseArea {
                                            anchors.fill: parent
                                            onClicked: {
                                                confirmationDialog.open()
                                                confirmationDialog.subGoalToRemove = modelData
                                            }
                                            hoverEnabled: true
                                            onEntered: parent.color = "#F76B6B"
                                            onExited: parent.color = "#E95B5B"
                                        }
                                    }
                                }

                                // Эффект при наведении
                                MouseArea {
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    onEntered: parent.color = "#353535"
                                    onExited: parent.color = "#2D2D2D"
                                    z: -1
                                }
                            }
                        }
                    }
                }
            }

            // Диалог подтверждения удаления SubGoal
            Dialog {
                id: confirmationDialog
                modal: true
                title: "Confirm SubGoal Deletion"
                width: 350
                height: 180

                property var subGoalToRemove

                Rectangle {
                    anchors.fill: parent
                    color: "#2D2D2D"
                    radius: 10

                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: 20
                        spacing: 20

                        Text {
                            text: "Are you sure you want to delete this sub-goal?"
                            font.pointSize: 14
                            color: "#FFFFFF"
                            horizontalAlignment: Text.AlignHCenter
                            Layout.fillWidth: true
                            wrapMode: Text.WordWrap
                        }

                        RowLayout {
                            Layout.fillWidth: true
                            spacing: 10

                            Rectangle {
                                Layout.fillWidth: true
                                Layout.preferredHeight: 40
                                color: "#E95B5B"
                                radius: 8

                                Text {
                                    text: "Yes, Delete"
                                    anchors.centerIn: parent
                                    color: "#FFFFFF"
                                    font.pointSize: 12
                                    font.bold: true
                                }

                                MouseArea {
                                    anchors.fill: parent
                                    onClicked: {
                                        AppViewModel.removeSubGoal(confirmationDialog.subGoalToRemove)
                                        confirmationDialog.close()
                                    }
                                    hoverEnabled: true
                                    onEntered: parent.color = "#F76B6B"
                                    onExited: parent.color = "#E95B5B"
                                }
                            }

                            Rectangle {
                                Layout.fillWidth: true
                                Layout.preferredHeight: 40
                                color: "#3A3A3A"
                                radius: 8

                                Text {
                                    text: "Cancel"
                                    anchors.centerIn: parent
                                    color: "#FFFFFF"
                                    font.pointSize: 12
                                    font.bold: true
                                }

                                MouseArea {
                                    anchors.fill: parent
                                    onClicked: {
                                        confirmationDialog.close()
                                    }
                                    hoverEnabled: true
                                    onEntered: parent.color = "#4A4A4A"
                                    onExited: parent.color = "#3A3A3A"
                                }
                            }
                        }
                    }
                }
            }

            // Диалог добавления SubGoal
            Dialog {
                id: addSubGoalDialog
                modal: true
                title: "Add New SubGoal"
                width: 400
                height: 200

                Rectangle {
                    anchors.fill: parent
                    color: "#2D2D2D"
                    radius: 10

                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: 20
                        spacing: 20

                        Text {
                            text: "Enter sub-goal name:"
                            color: "#FFFFFF"
                            font.pointSize: 14
                            font.bold: true
                        }

                        Rectangle {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 45
                            color: "#3A3A3A"
                            radius: 8
                            border.color: "#F3C44A"
                            border.width: 1

                            TextField {
                                id: subGoalNameField
                                anchors.fill: parent
                                anchors.margins: 10
                                placeholderText: "Enter sub-goal name..."
                                color: "#FFFFFF"
                                font.pointSize: 12
                                background: Rectangle {
                                    color: "transparent"
                                }
                                placeholderTextColor: "#AAAAAA"
                            }
                        }

                        RowLayout {
                            Layout.fillWidth: true
                            spacing: 10

                            Rectangle {
                                Layout.fillWidth: true
                                Layout.preferredHeight: 40
                                color: "#F3C44A"
                                radius: 8

                                Text {
                                    text: "Add SubGoal"
                                    anchors.centerIn: parent
                                    color: "#1E1E1E"
                                    font.pointSize: 12
                                    font.bold: true
                                }

                                MouseArea {
                                    anchors.fill: parent
                                    onClicked: {
                                        if (subGoalNameField.text !== "") {
                                            AppViewModel.addSubGoal(subGoalNameField.text)
                                            subGoalNameField.text = ""
                                            addSubGoalDialog.close()
                                        }
                                    }
                                    hoverEnabled: true
                                    onEntered: parent.color = "#F5D665"
                                    onExited: parent.color = "#F3C44A"
                                }
                            }

                            Rectangle {
                                Layout.fillWidth: true
                                Layout.preferredHeight: 40
                                color: "#3A3A3A"
                                radius: 8

                                Text {
                                    text: "Cancel"
                                    anchors.centerIn: parent
                                    color: "#FFFFFF"
                                    font.pointSize: 12
                                    font.bold: true
                                }

                                MouseArea {
                                    anchors.fill: parent
                                    onClicked: {
                                        subGoalNameField.text = ""
                                        addSubGoalDialog.close()
                                    }
                                    hoverEnabled: true
                                    onEntered: parent.color = "#4A4A4A"
                                    onExited: parent.color = "#3A3A3A"
                                }
                            }
                        }
                    }
                }
            }

            // Кнопка добавления SubGoal (справа сверху на желтой области)
            Rectangle {
                id: addSubGoalButtonTop
                width: 50
                height: 50
                anchors.top: parent.top
                anchors.right: parent.right
                anchors.margins: 15
                color: "#2D2D2D"
                radius: 25
                border.color: "#F3C44A"
                border.width: 2

                Rectangle {
                    anchors.centerIn: parent
                    width: 30
                    height: 30
                    radius: 15
                    color: "#F3C44A"

                    Text {
                        text: "+"
                        anchors.centerIn: parent
                        font.pointSize: 18
                        font.bold: true
                        color: "#1E1E1E"
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        addSubGoalDialog.open()
                    }
                    hoverEnabled: true
                    onEntered: parent.color = "#353535"
                    onExited: parent.color = "#2D2D2D"
                }
            }
        }

        // --- Нижняя секция (Задачи) ---
        Rectangle {
            id: bottomSection
            Layout.fillWidth: true
            Layout.fillHeight: true // Занимает оставшееся место
            color: "#1E1E1E" // Более темный фон для задач

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 20
                spacing: 15

                // Заголовок секции
                Text {
                    text: "Tasks"
                    color: "#FFFFFF"
                    font.pointSize: 18
                    font.bold: true
                    Layout.alignment: Qt.AlignLeft
                }

                // Кнопка добавления новой задачи
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 60
                    color: "#3A3A3A"
                    radius: 15
                    border.color: "#F3C44A"
                    border.width: 2

                    Rectangle {
                        anchors.centerIn: parent
                        width: 40
                        height: 40
                        radius: 20
                        color: "#F3C44A"

                        Text {
                            text: "+"
                            anchors.centerIn: parent
                            font.pointSize: 24
                            font.bold: true
                            color: "#1E1E1E"
                        }
                    }

                    Text {
                        text: "Add New Task"
                        anchors.centerIn: parent
                        anchors.leftMargin: 60
                        color: "#FFFFFF"
                        font.pointSize: 14
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            addTaskDialog.open()
                        }
                        hoverEnabled: true
                        onEntered: parent.color = "#4A4A4A"
                        onExited: parent.color = "#3A3A3A"
                    }
                }

                // Список задач
                ScrollView {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    clip: true

                    ListView {
                        id: taskListView
                        anchors.fill: parent
                        model: AppViewModel.currentTasksListModel
                        spacing: 10

                        delegate: Rectangle {
                            width: taskListView.width
                            height: 80
                            color: "#2D2D2D"
                            radius: 15
                            border.color: "#444444"
                            border.width: 1

                            // Левая цветная полоска
                            Rectangle {
                                width: 5
                                height: parent.height - 10
                                anchors.left: parent.left
                                anchors.leftMargin: 5
                                anchors.verticalCenter: parent.verticalCenter
                                color: "#F3C44A"
                                radius: 2
                            }

                            // Основное содержимое задачи
                            RowLayout {
                                anchors.fill: parent
                                anchors.margins: 15
                                spacing: 15

                                // Иконка задачи
                                Rectangle {
                                    width: 40
                                    height: 40
                                    color: "#F3C44A"
                                    radius: 8

                                    Text {
                                        text: "✓"
                                        anchors.centerIn: parent
                                        font.pointSize: 18
                                        color: "#1E1E1E"
                                        font.bold: true
                                    }
                                }

                                // Текст задачи
                                ColumnLayout {
                                    Layout.fillWidth: true
                                    spacing: 2

                                    Text {
                                        text: modelData.name
                                        color: "#FFFFFF"
                                        font.pointSize: 14
                                        font.bold: true
                                        Layout.fillWidth: true
                                        wrapMode: Text.WordWrap
                                    }

                                    Text {
                                        text: "Active task"
                                        color: "#AAAAAA"
                                        font.pointSize: 11
                                        Layout.fillWidth: true
                                    }
                                }

                                // Кнопка удаления
                                Rectangle {
                                    width: 35
                                    height: 35
                                    color: "#E95B5B"
                                    radius: 17

                                    Text {
                                        text: "✕"
                                        anchors.centerIn: parent
                                        font.pointSize: 16
                                        color: "#FFFFFF"
                                        font.bold: true
                                    }

                                    MouseArea {
                                        anchors.fill: parent
                                        onClicked: {
                                            taskConfirmationDialog.open()
                                            taskConfirmationDialog.taskToRemove = modelData
                                        }
                                        hoverEnabled: true
                                        onEntered: parent.color = "#F76B6B"
                                        onExited: parent.color = "#E95B5B"
                                    }
                                }
                            }

                            // Эффект при наведении
                            MouseArea {
                                anchors.fill: parent
                                hoverEnabled: true
                                onEntered: parent.color = "#353535"
                                onExited: parent.color = "#2D2D2D"
                                z: -1
                            }
                        }
                    }
                }

                // Диалог подтверждения удаления задачи
                Dialog {
                    id: taskConfirmationDialog
                    modal: true
                    title: "Confirm Task Deletion"
                    width: 350
                    height: 180

                    property var taskToRemove

                    Rectangle {
                        anchors.fill: parent
                        color: "#2D2D2D"
                        radius: 10

                        ColumnLayout {
                            anchors.fill: parent
                            anchors.margins: 20
                            spacing: 20

                            Text {
                                text: "Are you sure you want to delete this task?"
                                font.pointSize: 14
                                color: "#FFFFFF"
                                horizontalAlignment: Text.AlignHCenter
                                Layout.fillWidth: true
                                wrapMode: Text.WordWrap
                            }

                            RowLayout {
                                Layout.fillWidth: true
                                spacing: 10

                                Rectangle {
                                    Layout.fillWidth: true
                                    Layout.preferredHeight: 40
                                    color: "#E95B5B"
                                    radius: 8

                                    Text {
                                        text: "Yes, Delete"
                                        anchors.centerIn: parent
                                        color: "#FFFFFF"
                                        font.pointSize: 12
                                        font.bold: true
                                    }

                                    MouseArea {
                                        anchors.fill: parent
                                        onClicked: {
                                            AppViewModel.removeTask(taskConfirmationDialog.taskToRemove)
                                            taskConfirmationDialog.close()
                                        }
                                        hoverEnabled: true
                                        onEntered: parent.color = "#F76B6B"
                                        onExited: parent.color = "#E95B5B"
                                    }
                                }

                                Rectangle {
                                    Layout.fillWidth: true
                                    Layout.preferredHeight: 40
                                    color: "#3A3A3A"
                                    radius: 8

                                    Text {
                                        text: "Cancel"
                                        anchors.centerIn: parent
                                        color: "#FFFFFF"
                                        font.pointSize: 12
                                        font.bold: true
                                    }

                                    MouseArea {
                                        anchors.fill: parent
                                        onClicked: {
                                            taskConfirmationDialog.close()
                                        }
                                        hoverEnabled: true
                                        onEntered: parent.color = "#4A4A4A"
                                        onExited: parent.color = "#3A3A3A"
                                    }
                                }
                            }
                        }
                    }
                }

                // Диалог добавления задачи
                Dialog {
                    id: addTaskDialog
                    modal: true
                    title: "Add New Task"
                    width: 400
                    height: 200

                    Rectangle {
                        anchors.fill: parent
                        color: "#2D2D2D"
                        radius: 10

                        ColumnLayout {
                            anchors.fill: parent
                            anchors.margins: 20
                            spacing: 20

                            Text {
                                text: "Enter task name:"
                                color: "#FFFFFF"
                                font.pointSize: 14
                                font.bold: true
                            }

                            Rectangle {
                                Layout.fillWidth: true
                                Layout.preferredHeight: 45
                                color: "#3A3A3A"
                                radius: 8
                                border.color: "#F3C44A"
                                border.width: 1

                                TextField {
                                    id: taskNameField
                                    anchors.fill: parent
                                    anchors.margins: 10
                                    placeholderText: "Enter task name..."
                                    color: "#FFFFFF"
                                    font.pointSize: 12
                                    background: Rectangle {
                                        color: "transparent"
                                    }
                                    placeholderTextColor: "#AAAAAA"
                                }
                            }

                            RowLayout {
                                Layout.fillWidth: true
                                spacing: 10

                                Rectangle {
                                    Layout.fillWidth: true
                                    Layout.preferredHeight: 40
                                    color: "#F3C44A"
                                    radius: 8

                                    Text {
                                        text: "Add Task"
                                        anchors.centerIn: parent
                                        color: "#1E1E1E"
                                        font.pointSize: 12
                                        font.bold: true
                                    }

                                    MouseArea {
                                        anchors.fill: parent
                                        onClicked: {
                                            if (taskNameField.text !== "") {
                                                AppViewModel.addTask(taskNameField.text)
                                                taskNameField.text = ""
                                                addTaskDialog.close()
                                            }
                                        }
                                        hoverEnabled: true
                                        onEntered: parent.color = "#F5D665"
                                        onExited: parent.color = "#F3C44A"
                                    }
                                }

                                Rectangle {
                                    Layout.fillWidth: true
                                    Layout.preferredHeight: 40
                                    color: "#3A3A3A"
                                    radius: 8

                                    Text {
                                        text: "Cancel"
                                        anchors.centerIn: parent
                                        color: "#FFFFFF"
                                        font.pointSize: 12
                                        font.bold: true
                                    }

                                    MouseArea {
                                        anchors.fill: parent
                                        onClicked: {
                                            taskNameField.text = ""
                                            addTaskDialog.close()
                                        }
                                        hoverEnabled: true
                                        onEntered: parent.color = "#4A4A4A"
                                        onExited: parent.color = "#3A3A3A"
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
