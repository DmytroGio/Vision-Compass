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

            // Отображение SubGoals с использованием Repeater
            Row {
                id: subGoalRow
                anchors.bottom: parent.bottom
                anchors.horizontalCenter: parent.horizontalCenter
                spacing: 20
                padding: 10

                Repeater {
                    model: AppViewModel.subGoalsListModel // Используем модель данных

                    delegate: Rectangle {
                        width: 100
                        height: 50
                        radius: 10
                        color: "#F3C44A" // Желтый цвет
                        border.color: "gray"

                        Text {
                            text: modelData.name // Отображаем имя SubGoal
                            anchors.centerIn: parent
                            font.pointSize: 14
                            color: "black"
                        }

                        // Кнопка удаления SubGoal (опционально)
                        Button {
                            id: removeSubGoalButton
                            text: "X"
                            anchors.right: parent.right
                            anchors.top: parent.top
                            anchors.margins: 5
                            onClicked: {
                                // Показываем диалог подтверждения удаления
                                confirmationDialog.open()
                                confirmationDialog.subGoalToRemove = modelData
                            }
                        }
                    }
                }
            }

            // Диалог подтверждения удаления SubGoal
            Dialog {
                id: confirmationDialog
                modal: true
                title: "Подтверждение удаления"
                width: 300
                height: 150

                ColumnLayout {
                    anchors.fill: parent
                    spacing: 10
                    //padding: 10

                    Text {
                        text: "Вы хотите действительно удалить этот подцель?"
                        font.pointSize: 14
                        color: "#373737"
                        horizontalAlignment: Text.AlignHCenter
                    }

                    RowLayout {
                        spacing: 10
                        Button {
                            text: "Да"
                            onClicked: {
                                // Удаляем SubGoal из модели
                                AppViewModel.removeSubGoal(confirmationDialog.subGoalToRemove)
                                confirmationDialog.close()
                            }
                        }
                        Button {
                            text: "Нет"
                            onClicked: {
                                confirmationDialog.close()
                            }
                        }
                    }
                }
            }

            // Диалог добавления SubGoal
            Dialog {
                id: addSubGoalDialog
                modal: true
                title: "Add SubGoal"

                ColumnLayout {
                    anchors.fill: parent
                    spacing: 10

                    TextField {
                        id: subGoalNameField
                        placeholderText: "Enter Name of Subgoal"
                        Layout.fillWidth: true
                    }
                    RowLayout {
                        spacing: 10
                        Button {
                            text: "Add"
                            onClicked: {
                                if (subGoalNameField.text !== "") {
                                    AppViewModel.addSubGoal(subGoalNameField.text)
                                    addSubGoalDialog.close()
                                }
                            }
                        }
                        Button {
                            text: "Cancel"
                            onClicked: addSubGoalDialog.close()
                        }
                    }
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

                // ListView для задач будет здесь
                Rectangle {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    color: "#444444"
                    border.color: "gray"
                    Text {
                        anchors.centerIn: parent
                        text: "Task List Placeholder"
                        color: "white"
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
                    // onClicked: // Логика будет добавлена поз
                }
            }
        }
    }
}
