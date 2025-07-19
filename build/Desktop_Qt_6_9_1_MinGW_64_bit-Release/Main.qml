import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Window


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

    //flags: Qt.FramelessWindowHint

    // Load data when the application starts
    Component.onCompleted: {
        AppViewModel.loadData()
    }

    // Make AppViewModel available in this QML file
    // Create rectangle

    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        // --- Кастомная панель заголовка ---
        Rectangle {
            id: titleBar
            Layout.fillWidth: true
            height: 30 // Высота нашей кастомной полоски
            color: "#1E1E1E" // Цвет, соответствующий твоему дизайну
            // Установи dragging для перемещения окна
            MouseArea {
                anchors.fill: parent
                drag.target: null
                onPressed: mouse.accepted = true
                onMouseXChanged: {} // нужно указать хоть одно изменение, чтобы onPressed работал
                onPressedChanged: {
                    if (pressed) {
                        mainWindow.startSystemMove(); // перемещение окна
                    }
                }
            }

            RowLayout {
                anchors.fill: parent
                spacing: 0

                Text {
                    id: windowTitleText
                    text: mainWindow.title // Используем заголовок окна
                    color: "white"
                    font.pointSize: 10
                    verticalAlignment: Text.AlignVCenter
                    Layout.leftMargin: 10
                    Layout.fillWidth: true // Занимает всё доступное пространство
                }

                // Кнопка свернуть
                Button {
                    text: "—" // Символ для свернуть
                    font.bold: true
                    width: 40
                    height: parent.height
                    contentItem: Text {
                        text: parent.text
                        color: "white"
                        font.bold: true
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        anchors.fill: parent
                    }
                    background: Rectangle {
                        color: parent.hovered ? "#4A4A4A" : "#1E1E1E"
                    }
                    onClicked: mainWindow.showMinimized()
                }

                // Кнопка закрыть
                Button {
                    text: "✕" // Символ для закрыть
                    font.bold: true
                    width: 40
                    height: parent.height
                    contentItem: Text {
                        text: parent.text
                        color: "white"
                        font.bold: true
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        anchors.fill: parent
                    }
                    background: Rectangle {
                        color: parent.hovered ? "red" : "#1E1E1E" // Красный при наведении
                    }
                    onClicked: mainWindow.close()
                }
            }
        }
        // --- Конец кастомной панели заголовка ---

        // --- Top Section (half of big circle) ---
        Item {
            id: topSection
            Layout.fillWidth: true
            Layout.preferredHeight: mainWindow.height / 2

            // Gray background
            Rectangle {
                anchors.fill: parent
                color: "#1E1E1E"
                z: 0
            }

            Canvas {
                id: bigCircle
                anchors.fill: parent
                onPaint: {
                    var ctx = getContext("2d");                    ctx.clearRect(0, 0, width, height);
                    var radius = width > height ? width * 0.9 : height * 1.8;
                    ctx.beginPath();                    ctx.arc(width / 2, 0, radius / 2, 0, Math.PI, false);
                    ctx.closePath();
                    ctx.fillStyle = "#F3C44A";
                    ctx.fill();                }
            }

            // Red circle (Goal)
            Rectangle {
                id: goalCircle
                width: topSection.height * 1
                height: width
                radius: width / 2
                color: "#E95B5B"
                anchors.horizontalCenter: parent.horizontalCenter
                y: -height / 3

                Column {
                    anchors.centerIn: parent
                    spacing: 10

                    Text {
                        id: goalNameText
                        text: AppViewModel.currentGoalText
                        font.pointSize: 20
                        font.bold: true
                        color: "white"
                        horizontalAlignment: Text.AlignHCenter
                        wrapMode: Text.WordWrap
                        width: goalCircle.width * 0.8
                    }
                    Text {
                        id: goalDescriptionText
                        text: AppViewModel.currentGoalDescription
                        font.pointSize: 12
                        color: "white"
                        horizontalAlignment: Text.AlignHCenter
                        wrapMode: Text.WordWrap
                        width: goalCircle.width * 0.8
                    }
                }

                // Button for editing the target
                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        editGoalDialog.open()
                    }
                    hoverEnabled: true
                    onEntered: parent.color = "#F76B6B"
                    onExited: parent.color = "#E95B5B"
                }
            }

            // Отображение SubGoals с использованием современного дизайна
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
                        color: "#FFFFFF"
                        font.pointSize: 14
                        font.bold: true
                        Layout.alignment: Qt.AlignLeft
                    }

                    // Контейнер для горизонтального скролла SubGoals
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 90
                        color: "transparent"

                        ScrollView {
                            id: subGoalsScrollView
                            anchors.fill: parent
                            anchors.bottomMargin: -10  // Место для скроллбара

                            clip: true

                            // Отключаем вертикальный скроллбар
                            ScrollBar.vertical.policy: ScrollBar.AlwaysOff

                            // Включаем горизонтальный скроллбар
                            ScrollBar.horizontal.policy: ScrollBar.AsNeeded

                            // MouseArea для прокрутки колесиком мыши
                            MouseArea {
                                anchors.fill: parent
                                onWheel: {
                                    // Прокрутка горизонтального скроллбара колесиком мыши
                                    var delta = wheel.angleDelta.y > 0 ? -30 : 30;
                                    subGoalsList.contentX = Math.max(0,
                                        Math.min(subGoalsList.contentWidth - subGoalsList.width,
                                        subGoalsList.contentX + delta));
                                }
                                // Пропускаем клики через MouseArea к элементам ниже
                                propagateComposedEvents: true
                                z: -1
                            }

                            ListView {
                                id: subGoalsList

                                // КРИТИЧНО: устанавливаем горизонтальную ориентацию
                                orientation: ListView.Horizontal

                                // Привязка к размерам родителя
                                anchors.fill: parent

                                model: AppViewModel.subGoalsListModel
                                spacing: 15

                                // Отступы от краев
                                leftMargin: 5
                                rightMargin: 5

                            delegate: Rectangle {
                                width: 180
                                height: 80
                                color: modelData.id === AppViewModel.selectedSubGoalId ? "#4A4A4A" : "#2D2D2D"
                                radius: 15
                                border.color: modelData.id === AppViewModel.selectedSubGoalId ? "#F5D665" : "#F3C44A"
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
                                        Layout.alignment: Qt.AlignTop

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
                                        Layout.fillHeight: true
                                        spacing: 2

                                        Text {
                                            text: modelData.name || "Unnamed SubGoal"
                                            color: "#FFFFFF"
                                            font.pointSize: 12
                                            font.bold: true
                                            Layout.fillWidth: true
                                            wrapMode: Text.WordWrap
                                            maximumLineCount: 2
                                            elide: Text.ElideRight
                                        }

                                        Text {
                                            text: modelData.id === AppViewModel.selectedSubGoalId ? "Selected" : "Click to select"
                                            color: modelData.id === AppViewModel.selectedSubGoalId ? "#F5D665" : "#AAAAAA"
                                            font.pointSize: 9
                                            Layout.fillWidth: true
                                        }
                                    }

                                    // Контейнер для кнопок
                                    RowLayout {
                                        Layout.alignment: Qt.AlignTop
                                        spacing: 5

                                        // Кнопка редактирования SubGoal
                                        Rectangle {
                                            width: 25
                                            height: 25
                                            color: "#F3C44A"
                                            radius: 12

                                            Text {
                                                text: "✎" // Edit icon
                                                anchors.centerIn: parent
                                                font.pointSize: 12
                                                color: "#1E1E1E"
                                                font.bold: true
                                            }

                                            MouseArea {
                                                anchors.fill: parent
                                                onClicked: {
                                                    editSubGoalDialog.openForEditing(modelData)
                                                }
                                                hoverEnabled: true
                                                onEntered: parent.color = "#F5D665"
                                                onExited: parent.color = "#F3C44A"
                                            }
                                        }

                                        // Кнопка удаления SubGoal
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
                                }

                                // Эффект при наведении на весь элемент
                                MouseArea {
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    onEntered: {
                                        if (modelData.id !== AppViewModel.selectedSubGoalId) {
                                            parent.color = "#353535"
                                        }
                                    }
                                    onExited: {
                                        if (modelData.id !== AppViewModel.selectedSubGoalId) {
                                            parent.color = "#2D2D2D"
                                        }
                                    }
                                    onClicked: {
                                        AppViewModel.selectSubGoal(modelData.id)
                                    }
                                    z: -1
                                }
                            }
                        }

                        // Кастомный горизонтальный скроллбар - размещаем ВНУТРИ Rectangle
                        // Кастомный скроллбар без использования ScrollBar
                        Rectangle {
                            id: customScrollBar
                            anchors.left: parent.left
                            anchors.right: parent.right
                            anchors.bottom: parent.bottom
                            height: 8
                            color: "#3A3A3A"
                            border.color: "#444444"
                            border.width: 1
                            radius: 4

                            Component.onCompleted: {
                                // Убеждаемся что радиус применился
                                radius = 4
                            }

                            Rectangle {
                                id: scrollHandle
                                height: parent.height - 1
                                width: parent.width * 0.3  // Фиксированный размер
                                y: 1
                                radius: 4

                                Component.onCompleted: {
                                    // Принудительно обновляем позицию при загрузке
                                    x = Qt.binding(function() {
                                        return subGoalsList.contentWidth > subGoalsList.width ?
                                               (subGoalsList.contentX / (subGoalsList.contentWidth - subGoalsList.width)) * maxX : 0
                                    })
                                }

                                property real maxX: parent.width - width
                                x: 1


                                gradient: Gradient {
                                    GradientStop { position: 0.0; color: scrollMouseArea.containsMouse ? "#FFD700" : "#F3C44A" }
                                    GradientStop { position: 0.5; color: scrollMouseArea.containsMouse ? "#FFF200" : "#E8B332" }
                                    GradientStop { position: 1.0; color: scrollMouseArea.containsMouse ? "#FFED4E" : "#D35400" }
                                }

                                border.color: scrollMouseArea.containsMouse ? "#D4A017" : "#C0392B"
                                border.width: 1

                                MouseArea {
                                    id: scrollMouseArea
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    drag.target: parent
                                    drag.axis: Drag.XAxis
                                    drag.minimumX: 1
                                    drag.maximumX: parent.maxX - 1

                                    onPositionChanged: {
                                        if (drag.active && subGoalsList.contentWidth > subGoalsList.width) {
                                            var ratio = parent.x / parent.maxX
                                            subGoalsList.contentX = ratio * (subGoalsList.contentWidth - subGoalsList.width)
                                        }
                                    }
                                }
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
                    text: AppViewModel.selectedSubGoalId !== 0 ? "Tasks for: " + AppViewModel.selectedSubGoalName : "No SubGoal Selected"
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
                            opacity: modelData.completed ? 0.7 : 1.0 // Visual indication for completed tasks

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
                                    color: modelData.completed ? "#66BB6A" : "#F3C44A" // Green for completed, yellow for not
                                    radius: 8

                                    Text {
                                        text: modelData.completed ? "✓" : "☐" // Checkmark or empty box
                                        anchors.centerIn: parent
                                        font.pointSize: 18
                                        color: "#1E1E1E"
                                        font.bold: true
                                    }

                                    MouseArea {
                                        anchors.fill: parent
                                        onClicked: {
                                            AppViewModel.completeTask(modelData.id) //
                                        }
                                        hoverEnabled: true
                                        onEntered: parent.color = modelData.completed ? "#76CC7A" : "#F5D665"
                                        onExited: parent.color = modelData.completed ? "#66BB6A" : "#F3C44A"
                                    }
                                }

                                // Текст задачи
                                ColumnLayout {
                                    Layout.fillWidth: true
                                    spacing: 2

                                    Text {
                                        //text: modelData.name
                                        color: "#FFFFFF"
                                        font.pointSize: 14
                                        font.bold: true
                                        Layout.fillWidth: true
                                        wrapMode: Text.WordWrap
                                        textFormat: Text.RichText // Allow HTML for strikethrough
                                        text: modelData.completed ? "<s>" + modelData.name + "</s>" : modelData.name
                                    }

                                    Text {
                                        text: modelData.completed ? "Completed" : "Active task" //
                                        color: modelData.completed ? "#66BB6A" : "#AAAAAA"
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

                                // Кнопка редактирования задачи
                                Rectangle {
                                    width: 35
                                    height: 35
                                    color: "#F3C44A"
                                    radius: 17

                                    Text {
                                        text: "✎" // Edit icon
                                        anchors.centerIn: parent
                                        font.pointSize: 16
                                        color: "#1E1E1E"
                                        font.bold: true
                                    }

                                    MouseArea {
                                        anchors.fill: parent
                                        onClicked: {
                                            editTaskDialog.openForEditing(modelData)
                                        }
                                        hoverEnabled: true
                                        onEntered: parent.color = "#F5D665"
                                        onExited: parent.color = "#F3C44A"
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
    }

    // Диалог подтверждения удаления SubGoal
    Dialog {
        id: confirmationDialog
        modal: true
        title: "Confirm SubGoal Deletion"
        width: 350
        height: 180

        parent: Overlay.overlay
        anchors.centerIn: Overlay.overlay

        property var subGoalToRemove

        focus: true
        Keys.onReturnPressed: {
            AppViewModel.removeSubGoal(confirmationDialog.subGoalToRemove)
            confirmationDialog.close()
        }

        background: Rectangle { // Добавим фон для затемнения, как в Popup
            color: "#CC000000" // Полупрозрачный черный
            radius: 10 // Если хочешь скругленные углы для самого диалога
        }

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

        parent: Overlay.overlay
        anchors.centerIn: Overlay.overlay

        // ADDED: Set focus on open
        onOpened: {
            subGoalNameField.forceActiveFocus()
        }

        background: Rectangle {
            color: "#CC000000"
            radius: 10
        }

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
                        onAccepted: {
                            if (subGoalNameField.text !== "") {
                                AppViewModel.addSubGoal(subGoalNameField.text)
                                subGoalNameField.text = ""
                                addSubGoalDialog.close()
                            }
                        }
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

    // Диалог редактирования SubGoal
    Dialog {
        id: editSubGoalDialog
        modal: true
        title: "Edit SubGoal"
        width: 400
        height: 200

        parent: Overlay.overlay
        anchors.centerIn: Overlay.overlay

        // This property will hold the data for the item being edited
        property var subGoalToEdit: null


        function openForEditing(itemData) {
            // Step 1: Securely receive and store the data
            subGoalToEdit = itemData;

            // Step 2: Now, with the data safely stored, call the built-in open()
            open();
        }

        // MODIFIED: This block now fills the text field when the dialog opens
        onOpened: {
            // First, check that data was actually passed to the dialog
            if (subGoalToEdit) {
                // Set the text field's content to the current name of the sub-goal
                editNameField.text = subGoalToEdit.name
            }
            // Then, give focus to the text field
            editNameField.forceActiveFocus()
            // And select the text for easy editing
            editNameField.selectAll()
        }

        background: Rectangle {
            color: "#CC000000"
            radius: 10
        }

        Rectangle {
            anchors.fill: parent
            color: "#2D2D2D"
            radius: 10

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 20
                spacing: 20

                Text {
                    text: "Edit sub-goal name:"
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
                        id: editNameField
                        anchors.fill: parent
                        anchors.margins: 10
                        placeholderText: "New sub-goal name..."
                        color: "#FFFFFF"
                        font.pointSize: 12
                        background: Rectangle {
                            color: "transparent"
                        }
                        placeholderTextColor: "#AAAAAA"
                        onAccepted: {
                            if (editNameField.text !== "" && editSubGoalDialog.subGoalToEdit !== null) {
                                AppViewModel.editSubGoal(editSubGoalDialog.subGoalToEdit.id, editNameField.text)
                                editSubGoalDialog.close()
                            }
                        }
                    }
                }

                RowLayout {
                    Layout.fillWidth: true
                    spacing: 10

                    // "Save Changes" Button
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 40
                        color: "#F3C44A"
                        radius: 8
                        // ... (rest of the button is unchanged)
                        Text {
                            text: "Save Changes"
                            anchors.centerIn: parent
                            color: "#1E1E1E"
                            font.pointSize: 12
                            font.bold: true
                        }
                        MouseArea {
                            anchors.fill: parent
                            onClicked: {
                                if (editNameField.text !== "" && editSubGoalDialog.subGoalToEdit !== null) {
                                    AppViewModel.editSubGoal(editSubGoalDialog.subGoalToEdit.id, editNameField.text)
                                    editSubGoalDialog.close()
                                }
                            }
                            hoverEnabled: true
                            onEntered: parent.color = "#F5D665"
                            onExited: parent.color = "#F3C44A"
                        }
                    }

                    // "Cancel" Button
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 40
                        color: "#3A3A3A"
                        radius: 8
                        // ... (rest of the button is unchanged)
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
                                editSubGoalDialog.close()
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



    // Диалог подтверждения удаления задачи
    Dialog {
        id: taskConfirmationDialog
        modal: true
        title: "Confirm Task Deletion"
        width: 350
        height: 180

        parent: Overlay.overlay
        anchors.centerIn: Overlay.overlay

        background: Rectangle {
            color: "#CC000000"
            radius: 10
        }

        focus: true
        Keys.onReturnPressed: {
            AppViewModel.removeTask(taskConfirmationDialog.taskToRemove)
            taskConfirmationDialog.close()
        }

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

        parent: Overlay.overlay
        anchors.centerIn: Overlay.overlay

        // ADDED: Set focus on open
        onOpened: {
            taskNameField.forceActiveFocus()
        }

        background: Rectangle {
            color: "#CC000000"
            radius: 10
        }

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
                        onAccepted: {
                            if (taskNameField.text !== "") {
                                AppViewModel.addTask(taskNameField.text)
                                taskNameField.text = ""
                                addTaskDialog.close()
                            }
                        }
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

    // Диалог редактирования задачи
    Dialog {
        id: editTaskDialog
        modal: true
        title: "Edit Task"
        width: 400
        height: 200

        parent: Overlay.overlay
        anchors.centerIn: Overlay.overlay

        // ADDED: Set focus on open
        onOpened: {
            if (taskToEdit) {
                editTaskNameField.text = taskToEdit.name
            }
            editTaskNameField.forceActiveFocus()
            editTaskNameField.selectAll()
        }

        background: Rectangle {
            color: "#CC000000"
            radius: 10
        }

        property var taskToEdit: null

        function openForEditing(itemData) {
            taskToEdit = itemData;
            open();
        }

        Rectangle {
            anchors.fill: parent
            color: "#2D2D2D"
            radius: 10

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 20
                spacing: 20

                Text {
                    text: "Edit task name:"
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
                        id: editTaskNameField
                        anchors.fill: parent
                        anchors.margins: 10
                        placeholderText: "New task name..."
                        color: "#FFFFFF"
                        font.pointSize: 12
                        background: Rectangle {
                            color: "transparent"
                        }
                        placeholderTextColor: "#AAAAAA"
                        onAccepted: {
                            if (editTaskNameField.text !== "" && editTaskDialog.taskToEdit !== null) {
                                AppViewModel.editTask(editTaskDialog.taskToEdit.id, editTaskNameField.text) //
                                editTaskDialog.close()
                            }
                        }
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
                            text: "Save Changes"
                            anchors.centerIn: parent
                            color: "#1E1E1E"
                            font.pointSize: 12
                            font.bold: true
                        }

                        MouseArea {
                            anchors.fill: parent
                            onClicked: {
                                if (editTaskNameField.text !== "" && editTaskDialog.taskToEdit !== null) {
                                    AppViewModel.editTask(editTaskDialog.taskToEdit.id, editTaskNameField.text) //
                                    editTaskDialog.close()
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
                                editTaskDialog.close()
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

    // Диалог редактирования основной цели
    Dialog {
        id: editGoalDialog
        modal: true
        title: "Edit Main Goal"
        width: 450
        height: 250

        parent: Overlay.overlay
        anchors.centerIn: Overlay.overlay

        // ADDED: Set focus on open
        onOpened: {
            editGoalNameField.forceActiveFocus()
        }

        background: Rectangle {
            color: "#CC000000"
            radius: 10
        }

        Rectangle {
            anchors.fill: parent
            color: "#2D2D2D"
            radius: 10

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 20
                spacing: 15

                Text {
                    text: "Main Goal Name:"
                    color: "#FFFFFF"
                    font.pointSize: 14
                    font.bold: true
                }
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 45
                    color: "#3A3A3A"
                    radius: 8
                    border.color: "#E95B5B"
                    border.width: 1

                    TextField {
                        id: editGoalNameField
                        anchors.fill: parent
                        anchors.margins: 10
                        placeholderText: "Enter main goal name..."
                        text: AppViewModel.currentGoalText // Pre-fill with current value
                        color: "#FFFFFF"
                        font.pointSize: 12
                        background: Rectangle { color: "transparent" }
                        placeholderTextColor: "#AAAAAA"
                        onAccepted: {
                             AppViewModel.setMainGoal(editGoalNameField.text, editGoalDescriptionField.text)
                             editGoalDialog.close()
                        }
                    }
                }

                Text {
                    text: "Main Goal Description (Target Date):"
                    color: "#FFFFFF"
                    font.pointSize: 14
                    font.bold: true
                }
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 45
                    color: "#3A3A3A"
                    radius: 8
                    border.color: "#E95B5B"
                    border.width: 1

                    TextField {
                        id: editGoalDescriptionField
                        anchors.fill: parent
                        anchors.margins: 10
                        placeholderText: "Enter target date or description..."
                        text: AppViewModel.currentGoalDescription // Pre-fill with current value
                        color: "#FFFFFF"
                        font.pointSize: 12
                        background: Rectangle { color: "transparent" }
                        placeholderTextColor: "#AAAAAA"
                        onAccepted: {
                             AppViewModel.setMainGoal(editGoalNameField.text, editGoalDescriptionField.text)
                             editGoalDialog.close()
                        }
                    }
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
                            text: "Save Goal"
                            anchors.centerIn: parent
                            color: "#FFFFFF"
                            font.pointSize: 12
                            font.bold: true
                        }

                        MouseArea {
                            anchors.fill: parent
                            onClicked: {
                                AppViewModel.setMainGoal(editGoalNameField.text, editGoalDescriptionField.text) //
                                editGoalDialog.close()
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
                                editGoalDialog.close()
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
