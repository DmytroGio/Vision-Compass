import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import com.visioncompass.data 1.0 // Import our C++ ViewModel

ApplicationWindow {
    id: mainWindow
    visible: true
    width: 800
    height: 750 // Increased height to accommodate both sections
    title: "Vision Compass (QML)"

    // Make AppViewModel available in this QML file
    AppViewModel {
        id: appViewModel
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        // --- Верхняя секция (Цели и Подцели) ---
        Rectangle {
            id: topSection
            Layout.fillWidth: true
            Layout.preferredHeight: mainWindow.height / 2 // Верхняя половина
            color: "#F3C44A" // Желтый фон для SubGoals

            // Красный круг (Goal) - упрощенная версия
            Rectangle {
                id: goalCircle
                width: topSection.height * 0.7 // Примерный размер
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
                        text: appViewModel.currentGoalText // Связываем с ViewModel
                        font.pointSize: 20
                        font.bold: true
                        color: "white"
                        horizontalAlignment: Text.AlignHCenter
                        wrapMode: Text.WordWrap
                        width: goalCircle.width * 0.8
                    }
                    Text {
                        id: goalDescriptionText
                        text: appViewModel.currentGoalDescription // Связываем с ViewModel
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

                // Пример отображения первого SubGoal, если есть
                Text {
                    text: appViewModel.subGoalsListModel.length > 0 ? appViewModel.subGoalsListModel[0].name : "No Subgoals"
                    color: "black"
                    font.pointSize: 14
                }
                // В будущем здесь будет Repeater или ListView
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
                // onClicked: // Логика будет добавлена позже
            }
        }

        // --- Нижняя секция (Задачи) ---
        Rectangle {
            id: bottomSection
            Layout.fillWidth: true
            Layout.fillHeight: true // Занимает оставшееся место
            color: "#333333" // Темный фон для задач

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 10

                Text {
                    text: "Задачи для выбранной подцели:"
                    color: "white"
                    font.pointSize: 16
                    Layout.alignment: Qt.AlignHCenter
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
                    // onClicked: // Логика будет добавлена позже
                }
            }
        }
    }
}
