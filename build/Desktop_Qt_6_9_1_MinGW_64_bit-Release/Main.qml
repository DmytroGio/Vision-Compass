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
    title: "Vision Compass"

    //flags: Qt.FramelessWindowHint

    // Load data when the application starts
    Component.onCompleted: {
        AppViewModel.loadData()
    }

    function selectSubGoalByIndex(index) {
           if (AppViewModel.subGoalsListModel && AppViewModel.subGoalsListModel.length > index) {
               var subGoalId = AppViewModel.subGoalsListModel[index].id;
               AppViewModel.selectSubGoal(subGoalId);
           }
       }

       Shortcut {
           sequence: "1"
           onActivated: selectSubGoalByIndex(0)
       }
       Shortcut {
           sequence: "2"
           onActivated: selectSubGoalByIndex(1)
       }
       Shortcut {
           sequence: "3"
           onActivated: selectSubGoalByIndex(2)
       }
       Shortcut {
           sequence: "4"
           onActivated: selectSubGoalByIndex(3)
       }
       Shortcut {
           sequence: "5"
           onActivated: selectSubGoalByIndex(4)
       }
       Shortcut {
           sequence: "6"
           onActivated: selectSubGoalByIndex(5)
       }
       Shortcut {
           sequence: "7"
           onActivated: selectSubGoalByIndex(6)
       }
       Shortcut {
           sequence: "8"
           onActivated: selectSubGoalByIndex(7)
       }
       Shortcut {
           sequence: "9"
           onActivated: selectSubGoalByIndex(8)
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
                Rectangle {
                    width: 40
                    height: parent.height
                    color: minimizeMouseArea.containsMouse ? "#3A3A3A" : "#1E1E1E"

                    Text {
                        text: "—"
                        color: "white"
                        font.bold: true
                        font.pointSize: 12
                        anchors.centerIn: parent
                    }

                    MouseArea {
                        id: minimizeMouseArea
                        anchors.fill: parent
                        hoverEnabled: true
                        onClicked: mainWindow.showMinimized()
                    }
                }

                // Кнопка закрыть
                Rectangle {
                    width: 40
                    height: parent.height
                    color: closeMouseArea.containsMouse ? "#CC4444" : "#1E1E1E"

                    Text {
                        text: "✕"
                        color: "white"
                        font.bold: true
                        font.pointSize: 12
                        anchors.centerIn: parent
                    }

                    MouseArea {
                        id: closeMouseArea
                        anchors.fill: parent
                        hoverEnabled: true
                        onClicked: mainWindow.close()
                    }
                }
            }
        }
        // --- Конец кастомной панели заголовка ---

        // --- Top Section (half of big circle) ---
        Item {
            id: topSection
            Layout.fillWidth: true
            Layout.preferredHeight:  375

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
                    var ctx = getContext("2d");
                    ctx.clearRect(0, 0, width, height);
                    var radius = width * 0.9;
                    ctx.beginPath();
                    ctx.arc(width / 2, 0, radius / 2, 0, Math.PI, false);
                    ctx.closePath();
                    ctx.fillStyle = "#F3C44A";
                    ctx.fill();
                }
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

                                // Функция для автоматического скролла к выбранному элементу
                                function scrollToSelectedItem() {
                                    if (!AppViewModel.selectedSubGoalId || !AppViewModel.subGoalsListModel) return;

                                    // Находим индекс выбранного элемента
                                    var selectedIndex = -1;
                                    for (var i = 0; i < AppViewModel.subGoalsListModel.length; i++) {
                                        if (AppViewModel.subGoalsListModel[i].id === AppViewModel.selectedSubGoalId) {
                                            selectedIndex = i;
                                            break;
                                        }
                                    }

                                    if (selectedIndex === -1) return;

                                    // Вычисляем позицию элемента
                                    var itemWidth = 180; // Ширина элемента
                                    var itemSpacing = 15; // Расстояние между элементами
                                    var itemPosition = selectedIndex * (itemWidth + itemSpacing);
                                    var viewportWidth = subGoalsList.width;

                                    // Вычисляем оптимальную позицию для центрирования элемента
                                    var targetContentX = itemPosition - (viewportWidth - itemWidth) / 2;

                                    // Ограничиваем позицию границами контента
                                    var maxContentX = Math.max(0, subGoalsList.contentWidth - viewportWidth);
                                    targetContentX = Math.max(0, Math.min(maxContentX, targetContentX));

                                    // Плавная анимация к целевой позиции
                                    scrollAnimation.to = targetContentX;
                                    scrollAnimation.start();
                                }

                                // Анимация для плавного скролла
                                NumberAnimation {
                                    id: scrollAnimation
                                    target: subGoalsList
                                    property: "contentX"
                                    duration: 300
                                    easing.type: Easing.OutCubic
                                }

                                // Отслеживаем изменения выбранной SubGoal
                                Connections {
                                    target: AppViewModel
                                    function onSelectedSubGoalIdChanged() {
                                        Qt.callLater(subGoalsList.scrollToSelectedItem);
                                    }
                                }

                                // Также вызываем скролл при загрузке модели
                                onModelChanged: {
                                    Qt.callLater(scrollToSelectedItem);
                                }

                                delegate: Rectangle {
                                    id: subGoalItem
                                    width: 180
                                    height: 80
                                    radius: 15
                                    border.width: 2

                                    property bool isSelected: modelData.id === AppViewModel.selectedSubGoalId
                                    property bool isHovered: false

                                    // Основной фон - всегда одинаковый для выбранного элемента
                                    color: isSelected ? "transparent" : "#2D2D2D"
                                    border.color: isSelected ? "#FF8C00" : "#F3C44A"

                                    // Градиентный фон для выбранного элемента
                                    Rectangle {
                                        anchors.fill: parent
                                        radius: parent.radius
                                        visible: isSelected
                                        gradient: Gradient {
                                            GradientStop { position: 0.0; color: "#FF8C00" }
                                            GradientStop { position: 0.3; color: "#FF7F00" }
                                            GradientStop { position: 0.7; color: "#FF6500" }
                                            GradientStop { position: 1.0; color: "#E55B00" }
                                        }
                                        opacity: 0.8
                                    }

                                    // Эффект при наведении для НЕвыбранных элементов
                                    Rectangle {
                                        anchors.fill: parent
                                        radius: parent.radius
                                        gradient: Gradient {
                                            GradientStop { position: 0.0; color: "#B8860B" }
                                            GradientStop { position: 0.5; color: "#CD853F" }
                                            GradientStop { position: 1.0; color: "#A0522D" }
                                        }
                                        opacity: 0.6
                                        visible: !isSelected && isHovered
                                    }

                                    // Номер шортката (внизу справа, выходит за границы)
                                    Rectangle {
                                        width: 24
                                        height: 24
                                        anchors.bottom: parent.bottom
                                        anchors.right: parent.right
                                        anchors.bottomMargin: -8
                                        anchors.rightMargin: 8
                                        color: "#F3C44A"
                                        radius: 8
                                        visible: index < 9
                                        z: 10

                                        // Черная тень для цифры выбранной subgoal
                                        Text {
                                            text: (index + 1).toString()
                                            anchors.centerIn: parent
                                            anchors.horizontalCenterOffset: 1
                                            anchors.verticalCenterOffset: 1
                                            font.pointSize: 11
                                            font.bold: true
                                            color: "black"
                                            opacity: subGoalItem.isSelected ? 0.6 : 0
                                            z: 0
                                        }

                                        Text {
                                            text: (index + 1).toString()
                                            anchors.centerIn: parent
                                            font.pointSize: 11
                                            font.bold: true
                                            color: subGoalItem.isSelected ? "#FAF7F3" : "#1E1E1E"
                                        }
                                    }

                                    // Основное содержимое SubGoal
                                    RowLayout {
                                        anchors.fill: parent
                                        anchors.margins: 12
                                        spacing: 10

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
                                                    text: "✎"
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
                                                visible: AppViewModel.subGoalsListModel.length > 1

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

                                    // MouseArea для выбора и эффектов наведения
                                    MouseArea {
                                        anchors.fill: parent
                                        hoverEnabled: true
                                        onEntered: {
                                            subGoalItem.isHovered = true
                                        }
                                        onExited: {
                                            subGoalItem.isHovered = false
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

                                visible: subGoalsList.contentWidth > subGoalsList.width

                                // Принудительная установка радиуса при создании
                                Component.onCompleted: {
                                    radius = 4
                                }

                                Rectangle {
                                    id: scrollHandle
                                    height: parent.height - 2
                                    width: parent.width * 0.3  // Фиксированный размер
                                    y: 1
                                    radius: 3  // Чуть меньше радиус для лучшего отображения

                                    // Принудительная установка начальной позиции
                                    Component.onCompleted: {
                                        radius = 3;
                                        x = Qt.binding(function() {
                                            if (subGoalsList.contentWidth <= subGoalsList.width) {
                                                return 1;
                                            }
                                            var ratio = subGoalsList.contentX / (subGoalsList.contentWidth - subGoalsList.width);
                                            return Math.max(1, Math.min(maxX - 1, ratio * maxX));
                                        })
                                    }

                                    property real maxX: parent.width - width - 2  // Учитываем границы
                                    x: 1

                                    // Принудительное обновление при любых изменениях
                                    onXChanged: radius = 3
                                    onWidthChanged: radius = 3
                                    onHeightChanged: radius = 3

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

                // Заголовок секции с кнопкой добавления
                RowLayout {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 50

                    // Заголовок слева
                    Text {
                        text: AppViewModel.subGoalsListModel.length > 0 ? AppViewModel.selectedSubGoalName : "No SubGoals Available"
                        color: "#FFFFFF"
                        font.pointSize: 18
                        font.bold: true
                        Layout.fillWidth: true
                        Layout.alignment: Qt.AlignVCenter
                    }

                    // Кнопка добавления справа
                    Rectangle {
                        Layout.preferredWidth: 150
                        Layout.preferredHeight: 40
                        color: "#3A3A3A"
                        radius: 10
                        border.color: "#F3C44A"
                        border.width: 2

                        RowLayout {
                            anchors.centerIn: parent
                            spacing: 8

                            Text {
                                text: "Add Task"
                                color: "#FFFFFF"
                                font.pointSize: 12
                                font.bold: true
                            }
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
                }

                // Список задач

                Rectangle {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    color: "transparent"

                    // MouseArea для прокрутки колесиком мыши
                    MouseArea {
                        anchors.fill: parent
                        onWheel: {
                            // Прокрутка вертикального скроллбара колесиком мыши
                            var delta = wheel.angleDelta.y > 0 ? -30 : 30;
                            var newContentY = Math.max(0,
                                Math.min(taskListView.contentHeight - taskListView.height,
                                taskListView.contentY + delta));

                            // ИСПРАВЛЕНИЕ: Принудительно ограничиваем значение
                            if (taskListView.contentHeight > taskListView.height) {
                                taskListView.contentY = newContentY;
                            }
                        }
                        // Пропускаем клики через MouseArea к элементам ниже
                        propagateComposedEvents: true
                        z: -1
                    }

                    ListView {
                        id: taskListView
                        anchors.fill: parent
                        anchors.rightMargin: 15 // Место для скроллбара
                        model: AppViewModel.currentTasksListModel
                        spacing: 10
                        clip: true

                        delegate: Rectangle {
                            width: taskListView.width
                            height: 80
                            color: "#2D2D2D"
                            radius: 15
                            border.color: "#444444"
                            border.width: 1
                            opacity: modelData.completed ? 0.7 : 1.0

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
                                    color: modelData.completed ? "#66BB6A" : "#F3C44A"
                                    radius: 8

                                    Text {
                                        text: modelData.completed ? "✓" : "☐"
                                        anchors.centerIn: parent
                                        font.pointSize: 18
                                        color: "#1E1E1E"
                                        font.bold: true
                                    }

                                    MouseArea {
                                        anchors.fill: parent
                                        onClicked: {
                                            AppViewModel.completeTask(modelData.id)
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
                                        color: "#FFFFFF"
                                        font.pointSize: 14
                                        font.bold: true
                                        Layout.fillWidth: true
                                        wrapMode: Text.WordWrap
                                        textFormat: Text.RichText
                                        text: modelData.completed ? "<s>" + modelData.name + "</s>" : modelData.name
                                    }

                                    Text {
                                        text: modelData.completed ? "Completed" : "Active task"
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
                                        text: "✎"
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

                    // Кастомный вертикальный скроллбар
                    Rectangle {
                        id: customVerticalScrollBar
                        anchors.top: parent.top
                        anchors.bottom: parent.bottom
                        anchors.right: parent.right
                        width: 8
                        color: "#3A3A3A"
                        border.color: "#444444"
                        border.width: 1
                        radius: 6

                        visible: taskListView.contentHeight > taskListView.height

                        Component.onCompleted: {
                            radius = 6
                        }

                        Rectangle {
                            id: verticalScrollHandle
                            width: parent.width - 2
                            height: parent.height * 0.3  // Фиксированный размер
                            x: 1
                            radius: 5

                            Component.onCompleted: {
                                // Принудительно обновляем позицию при загрузке
                                y = Qt.binding(function() {
                                    if (taskListView.contentHeight <= taskListView.height) {
                                        return 1; // Если контент помещается, ползунок вверху
                                    }

                                    var ratio = taskListView.contentY / (taskListView.contentHeight - taskListView.height);
                                    var calculatedY = ratio * maxY;

                                    // ИСПРАВЛЕНИЕ: Принудительно ограничиваем позицию ползунка
                                    return Math.max(1, Math.min(maxY - 1, calculatedY));
                                })
                            }

                            property real maxY: parent.height - height
                            y: 1

                            gradient: Gradient {
                                GradientStop { position: 0.0; color: verticalScrollMouseArea.containsMouse ? "#FFD700" : "#F3C44A" }
                                GradientStop { position: 0.5; color: verticalScrollMouseArea.containsMouse ? "#FFF200" : "#E8B332" }
                                GradientStop { position: 1.0; color: verticalScrollMouseArea.containsMouse ? "#FFED4E" : "#D35400" }
                            }

                            border.color: verticalScrollMouseArea.containsMouse ? "#D4A017" : "#C0392B"
                            border.width: 1

                            MouseArea {
                                id: verticalScrollMouseArea
                                anchors.fill: parent
                                hoverEnabled: true
                                drag.target: parent
                                drag.axis: Drag.YAxis
                                drag.minimumY: 1
                                drag.maximumY: parent.maxY - 1

                                onPositionChanged: {
                                    if (drag.active && taskListView.contentHeight > taskListView.height) {
                                        var ratio = Math.max(0, Math.min(1, parent.y / parent.maxY));
                                        var newContentY = ratio * (taskListView.contentHeight - taskListView.height);

                                        // ИСПРАВЛЕНИЕ: Дополнительная проверка границ
                                        taskListView.contentY = Math.max(0,
                                            Math.min(taskListView.contentHeight - taskListView.height, newContentY));
                                    }
                                }
                            }
                        }
                    }
                }

            }
        }
    }

    // --- Reusable Dialogs ---

    // Dialog for confirming SubGoal deletion
    CustomDialog {
        id: confirmationDialog
        dialogWidth: 350
        property var subGoalToRemove: null

        content: Component {
            Text {
                text: "Are you sure you want to delete this sub-goal?"
                font.pointSize: 14
                color: "#FFFFFF"
                horizontalAlignment: Text.AlignHCenter
                Layout.fillWidth: true
                wrapMode: Text.WordWrap
            }
        }

        buttons: [
            {
                text: "Yes, Delete",
                color: "#E95B5B",
                onClicked: function() {
                    if (confirmationDialog.subGoalToRemove) {
                        AppViewModel.removeSubGoal(confirmationDialog.subGoalToRemove);
                    }
                }
            },
            {
                text: "Cancel"
            }
        ]
    }

    // Dialog for adding a new SubGoal
    CustomDialog {
        id: addSubGoalDialog
        dialogWidth: 400

        content: Component {
            TextField {
                id: subGoalNameField
                placeholderText: "Enter sub-goal name..."
                Layout.fillWidth: true
                Layout.preferredHeight: 45
                color: "#FFFFFF"
                font.pointSize: 12
                background: Rectangle {
                    color: "#3A3A3A"
                    radius: 8
                    border.color: "#F3C44A"
                    border.width: 1
                }
                padding: 10
                placeholderTextColor: "#AAAAAA"

                onAccepted: {
                    if (text.trim() !== "") {
                        AppViewModel.addSubGoal(text.trim());
                        text = "";
                        addSubGoalDialog.close();
                    }
                }
            }
        }

        buttons: [
            {
                text: "Add SubGoal",
                color: "#F3C44A",
                textColor: "#1E1E1E",
                onClicked: function() {
                    let nameField = addSubGoalDialog.contentItem.children[0].children[1].item;
                    if (nameField && nameField.text.trim() !== "") {
                        AppViewModel.addSubGoal(nameField.text.trim());
                        nameField.text = "";
                    }
                }
            },
            {
                text: "Cancel"
            }
        ]
    }

    // Dialog for editing a SubGoal
    CustomDialog {
        id: editSubGoalDialog
        dialogWidth: 400
        property var subGoalToEdit: null

        function openForEditing(itemData) {
            subGoalToEdit = itemData;
            open();
            // Set text after dialog is opened to ensure the component is loaded
            Qt.callLater(function() {
                let nameField = editSubGoalDialog.contentItem.children[0].children[1].item;
                if (nameField && itemData) {
                    nameField.text = itemData.name || "";
                    nameField.selectAll();
                    nameField.forceActiveFocus();
                }
            });
        }

        content: Component {
            TextField {
                id: editNameField
                text: editSubGoalDialog.subGoalToEdit ? (editSubGoalDialog.subGoalToEdit.name || "") : ""
                placeholderText: "Edit sub-goal name..."
                Layout.fillWidth: true
                Layout.preferredHeight: 45
                color: "#FFFFFF"
                font.pointSize: 12
                background: Rectangle {
                    color: "#3A3A3A"
                    radius: 8
                    border.color: "#F3C44A"
                    border.width: 1
                }
                padding: 10
                placeholderTextColor: "#AAAAAA"

                onAccepted: {
                    if (text.trim() !== "" && editSubGoalDialog.subGoalToEdit) {
                        AppViewModel.editSubGoal(editSubGoalDialog.subGoalToEdit.id, text.trim());
                        editSubGoalDialog.close();
                    }
                }
            }
        }

        buttons: [
            {
                text: "Save Changes",
                color: "#F3C44A",
                textColor: "#1E1E1E",
                onClicked: function() {
                    let nameField = editSubGoalDialog.contentItem.children[0].children[1].item;
                    if (nameField && nameField.text.trim() !== "" && editSubGoalDialog.subGoalToEdit) {
                        AppViewModel.editSubGoal(editSubGoalDialog.subGoalToEdit.id, nameField.text.trim());
                    }
                }
            },
            {
                text: "Cancel"
            }
        ]
    }

    // Dialog for confirming Task deletion
    CustomDialog {
        id: taskConfirmationDialog
        dialogWidth: 350
        property var taskToRemove: null

        content: Component {
            Text {
                text: "Are you sure you want to delete this task?"
                font.pointSize: 14
                color: "#FFFFFF"
                horizontalAlignment: Text.AlignHCenter
                Layout.fillWidth: true
                wrapMode: Text.WordWrap
            }
        }

        buttons: [
            {
                text: "Yes, Delete",
                color: "#E95B5B",
                onClicked: function() {
                    if (taskConfirmationDialog.taskToRemove) {
                        AppViewModel.removeTask(taskConfirmationDialog.taskToRemove);
                    }
                }
            },
            {
                text: "Cancel"
            }
        ]
    }

    // Dialog for adding a new Task
    CustomDialog {
        id: addTaskDialog
        dialogWidth: 400

        content: Component {
            TextField {
                id: taskNameField
                placeholderText: "Enter task name..."
                Layout.fillWidth: true
                Layout.preferredHeight: 45
                color: "#FFFFFF"
                font.pointSize: 12
                background: Rectangle {
                    color: "#3A3A3A"
                    radius: 8
                    border.color: "#F3C44A"
                    border.width: 1
                }
                padding: 10
                placeholderTextColor: "#AAAAAA"

                onAccepted: {
                    if (text.trim() !== "") {
                        AppViewModel.addTask(text.trim());
                        text = "";
                        addTaskDialog.close();
                    }
                }
            }
        }

        buttons: [
            {
                text: "Add Task",
                color: "#F3C44A",
                textColor: "#1E1E1E",
                onClicked: function() {
                    let nameField = addTaskDialog.contentItem.children[0].children[1].item;
                    if (nameField && nameField.text.trim() !== "") {
                        AppViewModel.addTask(nameField.text.trim());
                        nameField.text = "";
                    }
                }
            },
            {
                text: "Cancel"
            }
        ]
    }

    // Dialog for editing a Task
    CustomDialog {
        id: editTaskDialog
        dialogWidth: 400
        property var taskToEdit: null

        function openForEditing(itemData) {
            taskToEdit = itemData;
            open();
            // Set text after dialog is opened to ensure the component is loaded
            Qt.callLater(function() {
                let nameField = editTaskDialog.contentItem.children[0].children[1].item;
                if (nameField && itemData) {
                    nameField.text = itemData.name || "";
                    nameField.selectAll();
                    nameField.forceActiveFocus();
                }
            });
        }

        content: Component {
            TextField {
                id: editTaskNameField
                text: editTaskDialog.taskToEdit ? (editTaskDialog.taskToEdit.name || "") : ""
                placeholderText: "Edit task name..."
                Layout.fillWidth: true
                Layout.preferredHeight: 45
                color: "#FFFFFF"
                font.pointSize: 12
                background: Rectangle {
                    color: "#3A3A3A"
                    radius: 8
                    border.color: "#F3C44A"
                    border.width: 1
                }
                padding: 10
                placeholderTextColor: "#AAAAAA"

                onAccepted: {
                    if (text.trim() !== "" && editTaskDialog.taskToEdit) {
                        AppViewModel.editTask(editTaskDialog.taskToEdit.id, text.trim());
                        editTaskDialog.close();
                    }
                }
            }
        }

        buttons: [
            {
                text: "Save Changes",
                color: "#F3C44A",
                textColor: "#1E1E1E",
                onClicked: function() {
                    let nameField = editTaskDialog.contentItem.children[0].children[1].item;
                    if (nameField && nameField.text.trim() !== "" && editTaskDialog.taskToEdit) {
                        AppViewModel.editTask(editTaskDialog.taskToEdit.id, nameField.text.trim());
                    }
                }
            },
            {
                text: "Cancel"
            }
        ]
    }

    // Dialog for editing the main Goal
    CustomDialog {
            id: editGoalDialog
            dialogWidth: 450

            content: Component {
                ColumnLayout {
                    spacing: 15

                    Text {
                        text: "Main Goal Name:"
                        color: "#FFFFFF"
                        font.pointSize: 12
                        font.bold: true
                    }

                    TextField {
                        id: editGoalNameField
                        objectName: "goalNameField"
                        text: AppViewModel.currentGoalText
                        placeholderText: "Enter main goal name..."
                        Layout.fillWidth: true
                        Layout.preferredHeight: 45
                        color: "#FFFFFF"
                        font.pointSize: 12
                        background: Rectangle {
                            color: "#3A3A3A"
                            radius: 8
                            border.color: "#E95B5B"
                            border.width: 1
                        }
                        padding: 10
                        placeholderTextColor: "#AAAAAA"

                        onAccepted: {
                            // Сохраняем изменения при нажатии Enter
                            let descField = parent.children[3]; // editGoalDescriptionField
                            if (text.trim() !== "" && descField && descField.text.trim() !== "") {
                                AppViewModel.setMainGoal(text.trim(), descField.text.trim());
                                editGoalDialog.close();
                            }
                        }
                    }

                    Text {
                        text: "Main Goal Description (Target Date):"
                        color: "#FFFFFF"
                        font.pointSize: 12
                        font.bold: true
                    }

                    TextField {
                        id: editGoalDescriptionField
                        objectName: "goalDescField"
                        text: AppViewModel.currentGoalDescription
                        placeholderText: "Enter goal description or target date..."
                        Layout.fillWidth: true
                        Layout.preferredHeight: 45
                        color: "#FFFFFF"
                        font.pointSize: 12
                        background: Rectangle {
                            color: "#3A3A3A"
                            radius: 8
                            border.color: "#E95B5B"
                            border.width: 1
                        }
                        padding: 10
                        placeholderTextColor: "#AAAAAA"

                        onAccepted: {
                            // Сохраняем изменения при нажатии Enter
                            let nameField = parent.children[1]; // editGoalNameField
                            if (text.trim() !== "" && nameField && nameField.text.trim() !== "") {
                                AppViewModel.setMainGoal(nameField.text.trim(), text.trim());
                                editGoalDialog.close();
                            }
                        }
                    }
                }
            }

            buttons: [
                {
                    text: "Save Goal",
                    color: "#E95B5B",
                    onClicked: function() {
                        // Ищем поля по objectName
                        function findChildByObjectName(parent, objectName) {
                            if (parent.objectName === objectName) return parent;
                            if (parent.children) {
                                for (var i = 0; i < parent.children.length; i++) {
                                    var result = findChildByObjectName(parent.children[i], objectName);
                                    if (result) return result;
                                }
                            }
                            return null;
                        }

                        let contentRoot = editGoalDialog.contentItem;
                        let nameField = findChildByObjectName(contentRoot, "goalNameField");
                        let descField = findChildByObjectName(contentRoot, "goalDescField");

                        if (nameField && descField && nameField.text.trim() !== "") {
                            console.log("Saving goal:", nameField.text, descField.text); // Отладка
                            AppViewModel.setMainGoal(nameField.text.trim(), descField.text.trim());
                        } else {
                            console.log("Fields not found or empty"); // Отладка
                        }
                    }
                },
                {
                    text: "Cancel"
                }
            ]
    }

}

