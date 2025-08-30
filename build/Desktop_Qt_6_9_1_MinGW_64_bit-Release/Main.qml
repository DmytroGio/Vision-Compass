import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtQuick.Window
import QtQuick.Effects
//import Qt.labs.platform 1.1 as Platform
import com.visioncompass 1.0


ApplicationWindow {
    id: mainWindow
    visible: true
    width: 1000
    height: 900

    minimumWidth: 600
    minimumHeight: 500

    title: "Vision Compass"

    //flags: Qt.FramelessWindowHint

    // Load data when the application starts
    Component.onCompleted: {
        AppViewModel.loadData()
        Qt.callLater(function() {
            scrollToSelectedItem()
        })
    }

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

        // Прямое назначение без анимации для немедленного эффекта
        subGoalsList.contentX = targetContentX;

        // Затем запускаем анимацию для плавности
        scrollAnimation.to = targetContentX;
        scrollAnimation.start();
    }

    function selectSubGoalByIndex(index) {
        if (AppViewModel.subGoalsListModel && AppViewModel.subGoalsListModel.length > index) {
            var subGoalId = AppViewModel.subGoalsListModel[index].id;
            AppViewModel.selectSubGoal(subGoalId);

            // Прямое центрирование после выбора
            Qt.callLater(function() {
                // Вычисляем позицию элемента
                var itemWidth = 180; // Ширина элемента
                var itemSpacing = 15; // Расстояние между элементами
                var itemPosition = index * (itemWidth + itemSpacing);
                var viewportWidth = subGoalsList.width;

                // Вычисляем оптимальную позицию для центрирования элемента
                var targetContentX = itemPosition - (viewportWidth - itemWidth) / 2;

                // Ограничиваем позицию границами контента
                var maxContentX = Math.max(0, subGoalsList.contentWidth - viewportWidth);
                targetContentX = Math.max(0, Math.min(maxContentX, targetContentX));

                // Устанавливаем позицию скролла
                subGoalsList.contentX = targetContentX;
            });
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

        // Единый фон для всего приложения
        Rectangle {
            anchors.fill: parent
            color: "#282828"
            z: -1
        }

        Canvas {
            id: bigCircle
            anchors.fill: parent
            z: 0
            onPaint: {
                var ctx = getContext("2d");
                ctx.clearRect(0, 0, width, height);
                var radius = 800;
                ctx.beginPath();
                ctx.arc(width / 2, 0, radius / 2, 0, Math.PI, false);
                ctx.closePath();
                ctx.fillStyle = "#282828";
                ctx.fill();
            }
        }

        // Тень для большого круга
        MultiEffect {
            source: bigCircle
            anchors.fill: bigCircle
            shadowEnabled: true
            shadowOpacity: 0.4
            shadowColor: "#F5BF2C"
            shadowHorizontalOffset: 0
            shadowVerticalOffset: 5
            shadowBlur: 2.0
            z: -1
        }

        // --- Top Section (half of big circle) ---
        Item {
            id: topSection
            Layout.fillWidth: true
            Layout.preferredHeight: 450


            // Red circle (Goal)
            Rectangle {
                id: goalCircle
                width: 400
                height: 400
                radius: width / 2
                color: "#282828"
                anchors.horizontalCenter: parent.horizontalCenter
                y: -height / 3

                Column {
                    anchors.centerIn: parent
                    anchors.verticalCenterOffset: 20
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

                    // Проверяем, находится ли курсор внутри круга
                    property bool isInsideCircle: {
                        var centerX = width / 2
                        var centerY = height / 2
                        var radius = Math.min(width, height) / 2
                        var dx = mouseX - centerX
                        var dy = mouseY - centerY
                        return (dx * dx + dy * dy) <= (radius * radius)
                    }

                    onPositionChanged: {
                        if (isInsideCircle && !parent.color.toString().includes("#3A3A3A")) {
                            parent.color = "#3A3A3A"
                        } else if (!isInsideCircle && !parent.color.toString().includes("#282828")) {
                            parent.color = "#282828"
                        }
                    }

                    onExited: parent.color = "#282828"
                }
            }

            // Тень для красного круга
            MultiEffect {
                source: goalCircle
                anchors.fill: goalCircle
                shadowEnabled: true
                shadowOpacity: 0.5
                shadowColor: "#E95B5B"
                shadowHorizontalOffset: 0
                shadowVerticalOffset: 5
                shadowBlur: 1.5
                z: -1
            }
            // Отображение SubGoals с использованием современного дизайна
            Rectangle {
                id: subGoalsContainer
                anchors.bottom: parent.bottom
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.margins: 20
                height: 160
                color: "transparent"

                ColumnLayout {
                    anchors.fill: parent
                    spacing: 10



                    // Контейнер для горизонтального скролла SubGoals
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 120
                        color: "transparent"

                        // Центрированный контейнер с ограниченной шириной
                        Item {
                            id: centeredContainer
                            width: Math.min(parent.width, 5 * (180 + 15) - 15) // Максимум 5 слотов (180px + 15px spacing, минус последний spacing)
                            height: parent.height
                            anchors.horizontalCenter: parent.horizontalCenter

                            ScrollView {
                                id: subGoalsScrollView
                                anchors.fill: parent
                                anchors.bottomMargin: -10  // Место для скроллбара

                                clip: true

                                // Отключаем вертикальный скроллбар
                                ScrollBar.vertical.policy: ScrollBar.AlwaysOff

                                // Включаем горизонтальный скроллбар?? - это работает
                                ScrollBar.horizontal.policy: ScrollBar.AlwaysOff

                                // MouseArea для прокрутки колесиком мыши
                                MouseArea {
                                    anchors.fill: parent
                                    onWheel: {
                                        if (customScrollBar.visible &&
                                            wheel.y >= customScrollBar.y &&
                                            wheel.y <= (customScrollBar.y + customScrollBar.height)) {
                                            return;
                                        }

                                        var delta = wheel.angleDelta.y > 0 ? -30 : 30;
                                        subGoalsList.contentX = Math.max(0,
                                            Math.min(subGoalsList.contentWidth - subGoalsList.width,
                                            subGoalsList.contentX + delta));
                                    }

                                    onPressed: {
                                        if (customScrollBar.visible &&
                                            mouse.y >= customScrollBar.y &&
                                            mouse.y <= (customScrollBar.y + customScrollBar.height)) {
                                            mouse.accepted = false;
                                        }
                                    }

                                    propagateComposedEvents: true
                                    z: -1
                                }

                                ListView {
                                    id: subGoalsList
                                    orientation: ListView.Horizontal
                                    anchors.fill: parent

                                    model: AppViewModel.subGoalsListModel
                                    spacing: 15
                                    clip: true

                                    // Отступы от краев
                                    leftMargin: 5
                                    rightMargin: 5

                                    // Сохранение позиции скролла
                                    property real savedContentX: 0

                                    Component.onCompleted: {
                                        // Принудительно устанавливаем начальную позицию
                                        contentX = 0
                                        // Если есть выбранный SubGoal, центрируем его
                                        Qt.callLater(function() {
                                            if (AppViewModel.selectedSubGoalId > 0) {
                                                scrollToSelectedItem()
                                            }
                                        })
                                    }

                                    onModelChanged: {
                                        // Восстанавливаем позицию после обновления модели
                                        if (savedContentX > 0 && contentWidth > width) {
                                            contentX = Math.min(savedContentX, contentWidth - width);
                                        }
                                    }

                                    delegate: Item {
                                        width: 180
                                        height: 110

                                        property bool isSelected: modelData.id === AppViewModel.selectedSubGoalId

                                        property bool allTasksCompleted: {
                                            let completionStatus = AppViewModel.subGoalCompletionStatus;
                                            for (let i = 0; i < completionStatus.length; i++) {
                                                if (completionStatus[i].subGoalId === modelData.id) {
                                                    return completionStatus[i].allTasksCompleted && completionStatus[i].hasAnyTasks;
                                                }
                                            }
                                            return false;
                                        }

                                        // Объединяем зоны наведения
                                        property bool isHovered: mainMouseArea.containsMouse || editButton.isButtonHovered || deleteButton.isButtonHovered

                                        // Главная зона наведения
                                        MouseArea {
                                            id: mainMouseArea
                                            anchors.fill: parent
                                            hoverEnabled: true
                                            onClicked: {
                                                AppViewModel.selectSubGoal(modelData.id);
                                            }
                                        }

                                        // Кнопки справа сверху от ячейки
                                        Row {
                                            anchors.top: subGoalRect.top
                                            anchors.right: subGoalRect.right
                                            anchors.topMargin: -25
                                            anchors.rightMargin: 5
                                            spacing: 5
                                            visible: isHovered
                                            z: 15

                                            // Кнопка редактирования
                                            Rectangle {
                                                id: editButton
                                                width: 20
                                                height: 20
                                                radius: 10
                                                color: "#404040"  // Более тёмный фон

                                                property bool isButtonHovered: editMouseArea.containsMouse

                                                Text {
                                                    text: "✎"
                                                    anchors.centerIn: parent
                                                    font.pointSize: 9
                                                    color: "#FFFFFF"
                                                    font.bold: true
                                                }

                                                MouseArea {
                                                    id: editMouseArea
                                                    anchors.fill: parent
                                                    hoverEnabled: true
                                                    onClicked: {
                                                        editSubGoalDialog.openForEditing(modelData);
                                                    }
                                                    onEntered: parent.color = "#555555"  // Тёмный hover
                                                    onExited: parent.color = "#404040"
                                                }
                                            }

                                            // Кнопка удаления
                                            Rectangle {
                                                id: deleteButton
                                                width: 20
                                                height: 20
                                                radius: 10
                                                color: "#404040"  // Более тёмный фон
                                                visible: AppViewModel.subGoalsListModel.length > 1

                                                property bool isButtonHovered: deleteMouseArea.containsMouse

                                                Text {
                                                    text: "✕"
                                                    anchors.centerIn: parent
                                                    font.pointSize: 9
                                                    color: "#FFFFFF"
                                                    font.bold: true
                                                }

                                                MouseArea {
                                                    id: deleteMouseArea
                                                    anchors.fill: parent
                                                    hoverEnabled: true
                                                    onClicked: {
                                                        confirmationDialog.open();
                                                        confirmationDialog.subGoalToRemove = modelData;
                                                    }
                                                    onEntered: parent.color = "#555555"  // Тёмный hover
                                                    onExited: parent.color = "#404040"
                                                }
                                            }
                                        }

                                        // Основная ячейка subgoal
                                        Rectangle {
                                            id: subGoalRect
                                            anchors.bottom: parent.bottom
                                            anchors.horizontalCenter: parent.horizontalCenter
                                            width: 180
                                            height: 80
                                            radius: 15
                                            border.width: 0

                                            // Базовый цвет для subgoals
                                            color: {
                                                if (isSelected) {
                                                    return "transparent"; // Будет использоваться градиент
                                                } else if (isHovered) {
                                                    return "#3D3D39";
                                                } else {
                                                    return "#323232";
                                                }
                                            }

                                            // Градиент для выбранной subgoal (и выполненной, и невыполненной)
                                            Rectangle {
                                                anchors.fill: parent
                                                radius: parent.radius
                                                visible: isSelected
                                                gradient: Gradient {
                                                    GradientStop {
                                                        position: 0.0
                                                        color: "#5B5B49"
                                                    }
                                                    GradientStop {
                                                        position: 1.0
                                                        color: "#323232"
                                                    }
                                                }
                                            }

                                            // Нумерация шортката
                                            Text {
                                                text: (index + 1).toString()
                                                anchors.bottom: parent.bottom
                                                anchors.right: parent.right
                                                anchors.bottomMargin: 5
                                                anchors.rightMargin: 12
                                                font.pointSize: 9
                                                font.bold: true
                                                color: "#FFFFFF"
                                                visible: index < 9
                                                z: 10
                                            }

                                            // Основное содержимое SubGoal
                                            RowLayout {
                                                anchors.fill: parent
                                                anchors.margins: 12
                                                spacing: 10

                                                ColumnLayout {
                                                    Layout.fillWidth: true
                                                    Layout.fillHeight: true
                                                    spacing: 2

                                                    Text {
                                                        text: modelData.name || "Unnamed SubGoal"
                                                        color: "#FFFFFF"
                                                        font.pointSize: 10
                                                        font.bold: true
                                                        Layout.fillWidth: true
                                                        Layout.alignment: Qt.AlignCenter
                                                        horizontalAlignment: Text.AlignHCenter
                                                        wrapMode: Text.WordWrap
                                                        maximumLineCount: 2
                                                        elide: Text.ElideRight
                                                    }
                                                }
                                            }
                                        }

                                        // Эффект тени для subgoal
                                        MultiEffect {
                                            source: subGoalRect
                                            anchors.fill: subGoalRect
                                            shadowEnabled: true
                                            shadowOpacity: 0.6
                                            shadowColor: allTasksCompleted ? "#E95B5B" : "#000000"
                                            //shadowHorizontalOffset: 3
                                            shadowVerticalOffset: 3
                                            shadowBlur: allTasksCompleted ? 1.2 : 0.8
                                            z: -1
                                        }
                                    }
                                }
                                // Минималистичный горизонтальный скроллбар
                                Rectangle {
                                    id: customScrollBar
                                    anchors.left: parent.left
                                    anchors.right: parent.right
                                    anchors.bottom: parent.bottom
                                    height: 6
                                    color: "transparent"
                                    radius: 2

                                    visible: subGoalsList.contentWidth > subGoalsList.width

                                    // MouseArea для всей зоны скроллбара
                                    MouseArea {
                                        anchors.fill: parent
                                        hoverEnabled: true
                                        onWheel: {
                                            if (subGoalsList.contentWidth > subGoalsList.width) {
                                                var delta = wheel.angleDelta.y > 0 ? -30 : 30;
                                                subGoalsList.contentX = Math.max(0,
                                                    Math.min(subGoalsList.contentWidth - subGoalsList.width,
                                                    subGoalsList.contentX + delta));
                                            }
                                        }

                                        onClicked: {
                                            // Клик по зоне скроллбара для перемещения ползунка
                                            if (subGoalsList.contentWidth > subGoalsList.width) {
                                                var ratio = mouse.x / width;
                                                subGoalsList.contentX = ratio * (subGoalsList.contentWidth - subGoalsList.width);
                                            }
                                        }
                                    }

                                    Rectangle {
                                        id: scrollHandle
                                        height: parent.height
                                        width: {
                                            if (subGoalsList.contentWidth <= subGoalsList.width) {
                                                return parent.width;
                                            }
                                            var ratio = subGoalsList.width / subGoalsList.contentWidth;
                                            var minWidth = 20;
                                            return Math.max(minWidth, parent.width * ratio);
                                        }
                                        y: 0
                                        radius: 2

                                        Component.onCompleted: {
                                            x = Qt.binding(function() {
                                                if (subGoalsList.contentWidth <= subGoalsList.width) {
                                                    return 0;
                                                }
                                                var ratio = subGoalsList.contentX / (subGoalsList.contentWidth - subGoalsList.width);
                                                return Math.max(0, Math.min(maxX, ratio * maxX));
                                            })
                                        }

                                        property real maxX: parent.width - width
                                        x: 0

                                        color: scrollMouseArea.pressed ? "#888888" : (scrollMouseArea.containsMouse ? "#AAAAAA" : "#666666")
                                        opacity: scrollMouseArea.pressed ? 1.0 : (scrollMouseArea.containsMouse ? 0.8 : 0.5)

                                        Behavior on opacity {
                                            NumberAnimation { duration: 200 }
                                        }

                                        Behavior on color {
                                            ColorAnimation { duration: 200 }
                                        }

                                        MouseArea {
                                            id: scrollMouseArea
                                            anchors.fill: parent
                                            hoverEnabled: true
                                            drag.target: parent
                                            drag.axis: Drag.XAxis
                                            drag.minimumX: 0
                                            drag.maximumX: parent.maxX

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
                }   }
            }

            // Кнопка добавления SubGoal (справа сверху на желтой области)
            Item {
                id: addSubGoalButtonTop
                width: 50
                height: 50
                x: parent.width / 2 + 210
                y: 180

                Rectangle {
                    id: mainButton
                    anchors.fill: parent
                    color: "#383838"
                    radius: 25

                    Text {
                        text: "+"
                        anchors.centerIn: parent
                        anchors.verticalCenterOffset: -2
                        font.pointSize: 18
                        font.bold: true
                        color: "#F3C44A"
                    }
                }

                MultiEffect {
                    source: mainButton
                    anchors.fill: mainButton
                    shadowEnabled: true
                    shadowOpacity: 0.5
                    shadowColor: "#000000"
                    //shadowHorizontalOffset: 3
                    shadowVerticalOffset: 3
                    shadowBlur: 0.8
                    z: -1
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        addSubGoalDialog.open()
                    }
                    hoverEnabled: true
                    onEntered: mainButton.color = "#525252"
                    onExited: mainButton.color = "#383838"
                }
            }
            // Data Management Menu Button
            Item {
                id: dataMenuButton
                width: 50
                height: 50
                x: parent.width / 2 - 310
                y: 180

                Rectangle {
                    id: dataButton
                    anchors.fill: parent
                    color: "#383838"
                    radius: 25

                    Text {
                        text: "⇓"
                        anchors.centerIn: parent
                        font.pointSize: 14
                        color: "#FFFFFF"
                    }
                }

                MultiEffect {
                    source: dataButton
                    anchors.fill: dataButton
                    shadowEnabled: true
                    shadowOpacity: 0.5
                    shadowColor: "#000000"
                    //shadowHorizontalOffset: 3
                    shadowVerticalOffset: 3
                    shadowBlur: 0.8
                    z: -1
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        dataManagementDialog.open()
                    }
                    hoverEnabled: true
                    onEntered: dataButton.color = "#525252"
                    onExited: dataButton.color = "#383838"
                }
            }
            // Info Button
            Item {
                id: infoButton
                width: 50
                height: 50
                x: parent.width / 2 - 230
                y: 180

                Rectangle {
                    id: infoButtonRect
                    anchors.fill: parent
                    color: "#383838"
                    radius: 25

                    Text {
                        text: "i"
                        anchors.centerIn: parent
                        font.pointSize: 15
                        font.bold: true
                        color: "#F2F2F2"
                        font.italic: true
                    }
                }

                MultiEffect {
                    source: infoButtonRect
                    anchors.fill: infoButtonRect
                    shadowEnabled: true
                    shadowOpacity: 0.5
                    shadowColor: "#000000"
                    //shadowHorizontalOffset: 3
                    shadowVerticalOffset: 3
                    shadowBlur: 0.8
                    z: -1
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        infoDialog.open()
                    }
                    hoverEnabled: true
                    onEntered: infoButtonRect.color = "#525252"
                    onExited: infoButtonRect.color = "#383838"
                }
            }
        }

        // --- Нижняя секция (Задачи) ---
        Rectangle {
            id: bottomSection
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.minimumHeight: 500
            Layout.maximumHeight: mainWindow.height - topSection.height - 40
            color: "transparent"

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 20
                spacing: 15

                // Заголовок секции с кнопкой добавления
                Item {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 50

                    // Контейнер с шириной слотов задач (600px)
                    Item {
                        width: 600
                        height: parent.height
                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.horizontalCenterOffset: -7

                        RowLayout {
                            anchors.fill: parent
                            spacing: 20

                            // Заголовок слева
                            Text {
                                text: AppViewModel.subGoalsListModel.length > 0 ? AppViewModel.selectedSubGoalName : "No SubGoals Available"
                                color: "#FFFFFF"
                                font.pointSize: 18
                                font.bold: true
                                Layout.fillWidth: true
                                Layout.alignment: Qt.AlignVCenter
                            }

                            // Кнопка справа
                            Rectangle {
                                Layout.preferredWidth: 150
                                Layout.preferredHeight: 40
                                color: "#3A3A3A"
                                radius: 10
                                border.color: "#666666"
                                border.width: 1

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

                        // Сохранение позиции скролла
                        property real savedContentY: 0

                        onModelChanged: {
                            // Восстанавливаем позицию после обновления модели
                            if (savedContentY > 0 && contentHeight > height) {
                                contentY = Math.min(savedContentY, contentHeight - height);
                            }
                        }

                        delegate: Rectangle {
                            id: taskItem
                            width: 600
                            height: Math.max(50, taskContent.implicitHeight + 16)
                            anchors.horizontalCenter: parent.horizontalCenter
                            color: "#2D2D2D"
                            radius: 12
                            border.color: "#444444"
                            border.width: 1
                            opacity: modelData.completed ? 0.7 : 1.0

                            property bool isTaskHovered: false

                            // Основное содержимое задачи
                            RowLayout {
                                id: taskContent
                                anchors.fill: parent
                                anchors.margins: 8
                                spacing: 10

                                // Иконка задачи
                                Rectangle {
                                    width: 30
                                    height: 30
                                    color: modelData.completed ? "#2D2D2D" : "#383838"
                                    radius: 8
                                    border.color: modelData.completed ? "#F3C44A" : "#707070"
                                    border.width: modelData.completed ? 0 : 1

                                    Rectangle {
                                        anchors.fill: parent
                                        radius: parent.radius
                                        color: modelData.completed ? "#F3C44A" : "transparent"
                                        visible: modelData.completed
                                    }

                                    MouseArea {
                                        anchors.fill: parent
                                        onClicked: {
                                            taskListView.savedContentY = taskListView.contentY;
                                            AppViewModel.completeTask(modelData.id);
                                        }
                                        hoverEnabled: true
                                        onEntered: {
                                            if (modelData.completed) {
                                                parent.children[0].color = "#F5D665"
                                            } else {
                                                parent.border.color = "#AAAAAA"
                                            }
                                        }
                                        onExited: {
                                            if (modelData.completed) {
                                                parent.children[0].color = "#F3C44A"
                                            } else {
                                                parent.border.color = "#707070"
                                            }
                                        }
                                    }
                                }

                                // Текст задачи
                                ColumnLayout {
                                    Layout.fillWidth: true
                                    spacing: 2

                                    Text {
                                        color: "#FFFFFF"
                                        font.pointSize: 10
                                        //font.bold: true
                                        Layout.fillWidth: true
                                        wrapMode: Text.WordWrap
                                        textFormat: Text.RichText
                                        text: modelData.completed ? "<s>" + modelData.name + "</s>" : modelData.name
                                    }
                                }

                                // Кнопка редактирования задачи
                                Item {
                                    width: 25
                                    height: 25
                                    visible: taskItem.isTaskHovered

                                    Text {
                                        text: "✎"
                                        anchors.centerIn: parent
                                        font.pointSize: 12
                                        color: "#CCCCCC"
                                        font.bold: true
                                    }

                                    MouseArea {
                                        anchors.centerIn: parent
                                        width: 20
                                        height: 20
                                        onClicked: {
                                            editTaskDialog.openForEditing(modelData)
                                        }
                                        hoverEnabled: true
                                        onEntered: parent.children[0].color = "#FFFFFF"
                                        onExited: parent.children[0].color = "#CCCCCC"
                                    }
                                }

                                // Кнопка удаления
                                Item {
                                    width: 25
                                    height: 25
                                    visible: taskItem.isTaskHovered

                                    Text {
                                        text: "✕"
                                        anchors.centerIn: parent
                                        font.pointSize: 12
                                        color: "#CCCCCC"
                                        font.bold: true
                                    }

                                    MouseArea {
                                        anchors.centerIn: parent
                                        width: 20
                                        height: 20
                                        onClicked: {
                                            taskConfirmationDialog.open()
                                            taskConfirmationDialog.taskToRemove = modelData
                                        }
                                        hoverEnabled: true
                                        onEntered: parent.children[0].color = "#FFFFFF"
                                        onExited: parent.children[0].color = "#CCCCCC"
                                    }
                                }
                            }

                            // ГЛАВНАЯ MouseArea для всей ячейки - размещаем поверх всего
                            MouseArea {
                                anchors.fill: parent
                                hoverEnabled: true
                                z: 100  // Поверх всех элементов

                                onEntered: {
                                    taskItem.color = "#353535"
                                    taskItem.isTaskHovered = true
                                }
                                onExited: {
                                    taskItem.color = "#2D2D2D"
                                    taskItem.isTaskHovered = false
                                }

                                // Пропускаем клики к дочерним элементам
                                onPressed: mouse.accepted = false
                            }
                        }
                    }

                    // Минималистичный вертикальный скроллбар
                    Rectangle {
                        id: customVerticalScrollBar
                        anchors.top: parent.top
                        anchors.right: parent.right
                        width: 6
                        height: Math.min(parent.height, mainWindow.height - topSection.height - 120)
                        color: "transparent"
                        radius: 3

                        visible: taskListView.contentHeight > taskListView.height

                        Rectangle {
                            id: verticalScrollHandle
                            width: parent.width
                            // Адаптивная высота
                            height: {
                                if (taskListView.contentHeight <= taskListView.height) {
                                    return parent.height;
                                }
                                var ratio = taskListView.height / taskListView.contentHeight;
                                var minHeight = 20;
                                return Math.max(minHeight, parent.height * ratio);
                            }
                            x: 0
                            radius: 3

                            Component.onCompleted: {
                                y = Qt.binding(function() {
                                    if (taskListView.contentHeight <= taskListView.height) {
                                        return 0;
                                    }

                                    var ratio = taskListView.contentY / (taskListView.contentHeight - taskListView.height);
                                    var calculatedY = ratio * maxY;

                                    return Math.max(0, Math.min(maxY, calculatedY));
                                })
                            }

                            property real maxY: parent.height - height
                            y: 0

                            color: verticalScrollMouseArea.pressed ? "#888888" : (verticalScrollMouseArea.containsMouse ? "#AAAAAA" : "#666666")
                            opacity: verticalScrollMouseArea.pressed ? 1.0 : (verticalScrollMouseArea.containsMouse ? 0.8 : 0.5)

                            Behavior on opacity {
                                NumberAnimation { duration: 200 }
                            }

                            Behavior on color {
                                ColorAnimation { duration: 200 }
                            }

                            MouseArea {
                                id: verticalScrollMouseArea
                                anchors.fill: parent
                                hoverEnabled: true
                                drag.target: parent
                                drag.axis: Drag.YAxis
                                drag.minimumY: 0
                                drag.maximumY: parent.maxY

                                onPositionChanged: {
                                    if (drag.active && taskListView.contentHeight > taskListView.height) {
                                        var ratio = Math.max(0, Math.min(1, parent.y / parent.maxY));
                                        var newContentY = ratio * (taskListView.contentHeight - taskListView.height);

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

        onOpened: {
            if (contentLoader.item) {
                contentLoader.item.forceActiveFocus()
            }
        }

        content: Component {
            ColumnLayout {
                spacing: 15

                Text {
                    text: "Add New SubGoal"
                    color: "#F3C44A"
                    font.pointSize: 16
                    font.bold: true
                    Layout.alignment: Qt.AlignHCenter
                }

                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 45
                    color: "#3A3A3A"
                    radius: 8
                    border.color: "#F3C44A"
                    border.width: 1

                    TextInput {
                        id: subGoalNameInput
                        anchors.fill: parent
                        anchors.margins: 10
                        color: "#FFFFFF"
                        font.pointSize: 12
                        verticalAlignment: TextInput.AlignVCenter
                        selectByMouse: true
                        clip: true

                        onAccepted: {
                            if (text.trim() !== "") {
                                AppViewModel.addSubGoal(text.trim());
                                text = "";
                                addSubGoalDialog.close();
                            }
                        }
                    }

                    Text {
                        text: "Enter sub-goal name..."
                        color: "#AAAAAA"
                        font.pointSize: 12
                        anchors.left: parent.left
                        anchors.leftMargin: 10
                        anchors.verticalCenter: parent.verticalCenter
                        visible: subGoalNameInput.text.length === 0
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
                    let inputField = addSubGoalDialog.contentItem.children[0].children[1].item.children[1].children[1];
                    if (inputField && inputField.text.trim() !== "") {
                        AppViewModel.addSubGoal(inputField.text.trim());
                        inputField.text = "";
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
                    let nameField = editSubGoalDialog.contentItem.children[0].children[1].item.children[1];
                    if (nameField && itemData) {
                        nameField.text = itemData.name || "";
                        nameField.selectAll();
                        nameField.forceActiveFocus();
                    }
                });
            }

            content: Component {
                ColumnLayout {
                    spacing: 15

                    Text {
                        text: "Edit SubGoal"
                        color: "#F3C44A"
                        font.pointSize: 16
                        font.bold: true
                        Layout.alignment: Qt.AlignHCenter
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 45
                        color: "#3A3A3A"
                        radius: 8
                        border.color: "#F3C44A"
                        border.width: 1

                        TextInput {
                            id: editSubGoalNameInput
                            anchors.fill: parent
                            anchors.margins: 10
                            color: "#FFFFFF"
                            font.pointSize: 12
                            verticalAlignment: TextInput.AlignVCenter
                            selectByMouse: true
                            clip: true
                            text: editSubGoalDialog.subGoalToEdit ? (editSubGoalDialog.subGoalToEdit.name || "") : ""

                            onAccepted: {
                                if (text.trim() !== "" && editSubGoalDialog.subGoalToEdit) {
                                    AppViewModel.editSubGoal(editSubGoalDialog.subGoalToEdit.id, text.trim());
                                    editSubGoalDialog.close();
                                }
                            }
                        }

                        Text {
                            text: "Edit sub-goal name..."
                            color: "#AAAAAA"
                            font.pointSize: 12
                            anchors.left: parent.left
                            anchors.leftMargin: 10
                            anchors.verticalCenter: parent.verticalCenter
                            visible: editSubGoalNameInput.text.length === 0
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
                        let inputField = editSubGoalDialog.contentItem.children[0].children[1].item.children[1].children[1];
                        if (inputField && inputField.text.trim() !== "" && editSubGoalDialog.subGoalToEdit) {
                            AppViewModel.editSubGoal(editSubGoalDialog.subGoalToEdit.id, inputField.text.trim());
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
                ColumnLayout {
                    spacing: 15

                    Text {
                        text: "Add New Task"
                        color: "#F3C44A"
                        font.pointSize: 16
                        font.bold: true
                        Layout.alignment: Qt.AlignHCenter
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 45
                        color: "#3A3A3A"
                        radius: 8
                        border.color: "#F3C44A"
                        border.width: 1

                        TextInput {
                            id: taskNameInput
                            anchors.fill: parent
                            anchors.margins: 10
                            color: "#FFFFFF"
                            font.pointSize: 12
                            verticalAlignment: TextInput.AlignVCenter
                            selectByMouse: true
                            clip: true

                            onAccepted: {
                                if (text.trim() !== "") {
                                    AppViewModel.addTask(text.trim());
                                    text = "";
                                    addTaskDialog.close();
                                }
                            }
                        }

                        Text {
                            text: "Enter task name..."
                            color: "#AAAAAA"
                            font.pointSize: 12
                            anchors.left: parent.left
                            anchors.leftMargin: 10
                            anchors.verticalCenter: parent.verticalCenter
                            visible: taskNameInput.text.length === 0
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
                        let inputField = addTaskDialog.contentItem.children[0].children[1].item.children[1].children[1];
                        if (inputField && inputField.text.trim() !== "") {
                            AppViewModel.addTask(inputField.text.trim());
                            inputField.text = "";
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
                    let nameField = editTaskDialog.contentItem.children[0].children[1].item.children[1];
                    if (nameField && itemData) {
                        nameField.text = itemData.name || "";
                        nameField.selectAll();
                        nameField.forceActiveFocus();
                    }
                });
            }

            content: Component {
                ColumnLayout {
                    spacing: 15

                    Text {
                        text: "Edit Task"
                        color: "#F3C44A"
                        font.pointSize: 16
                        font.bold: true
                        Layout.alignment: Qt.AlignHCenter
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 45
                        color: "#3A3A3A"
                        radius: 8
                        border.color: "#F3C44A"
                        border.width: 1

                        TextInput {
                            id: editTaskNameInput
                            anchors.fill: parent
                            anchors.margins: 10
                            color: "#FFFFFF"
                            font.pointSize: 12
                            verticalAlignment: TextInput.AlignVCenter
                            selectByMouse: true
                            clip: true
                            text: editTaskDialog.taskToEdit ? (editTaskDialog.taskToEdit.name || "") : ""

                            onAccepted: {
                                if (text.trim() !== "" && editTaskDialog.taskToEdit) {
                                    AppViewModel.editTask(editTaskDialog.taskToEdit.id, text.trim());
                                    editTaskDialog.close();
                                }
                            }
                        }

                        Text {
                            text: "Edit task name..."
                            color: "#AAAAAA"
                            font.pointSize: 12
                            anchors.left: parent.left
                            anchors.leftMargin: 10
                            anchors.verticalCenter: parent.verticalCenter
                            visible: editTaskNameInput.text.length === 0
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
                        let inputField = editTaskDialog.contentItem.children[0].children[1].item.children[1].children[1];
                        if (inputField && inputField.text.trim() !== "" && editTaskDialog.taskToEdit) {
                            AppViewModel.editTask(editTaskDialog.taskToEdit.id, inputField.text.trim());
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
                        text: "Edit Main Goal"
                        color: "#E95B5B"
                        font.pointSize: 16
                        font.bold: true
                        Layout.alignment: Qt.AlignHCenter
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 45
                        color: "#3A3A3A"
                        radius: 8
                        border.color: "#E95B5B"
                        border.width: 1

                        TextInput {
                            id: editGoalNameInput
                            anchors.fill: parent
                            anchors.margins: 10
                            color: "#FFFFFF"
                            font.pointSize: 12
                            verticalAlignment: TextInput.AlignVCenter
                            selectByMouse: true
                            clip: true
                            text: AppViewModel.currentGoalText
                        }

                        Text {
                            text: "Enter main goal name..."
                            color: "#AAAAAA"
                            font.pointSize: 12
                            anchors.left: parent.left
                            anchors.leftMargin: 10
                            anchors.verticalCenter: parent.verticalCenter
                            visible: editGoalNameInput.text.length === 0
                        }
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 45
                        color: "#3A3A3A"
                        radius: 8
                        border.color: "#E95B5B"
                        border.width: 1

                        TextInput {
                            id: editGoalDescriptionInput
                            anchors.fill: parent
                            anchors.margins: 10
                            color: "#FFFFFF"
                            font.pointSize: 12
                            verticalAlignment: TextInput.AlignVCenter
                            selectByMouse: true
                            clip: true
                            text: AppViewModel.currentGoalDescription

                            onAccepted: {
                                let nameField = parent.parent.children[1].children[1];
                                if (text.trim() !== "" && nameField && nameField.text.trim() !== "") {
                                    AppViewModel.setMainGoal(nameField.text.trim(), text.trim());
                                    editGoalDialog.close();
                                }
                            }
                        }

                        Text {
                            text: "Enter goal description or target date..."
                            color: "#AAAAAA"
                            font.pointSize: 12
                            anchors.left: parent.left
                            anchors.leftMargin: 10
                            anchors.verticalCenter: parent.verticalCenter
                            visible: editGoalDescriptionInput.text.length === 0
                        }
                    }
                }
            }

            buttons: [
                {
                    text: "Save Goal",
                    color: "#E95B5B",
                    onClicked: function() {
                        let nameField = editGoalDialog.contentItem.children[0].children[1].item.children[1].children[1];
                        let descField = editGoalDialog.contentItem.children[0].children[1].item.children[2].children[1];

                        if (nameField && descField && nameField.text.trim() !== "") {
                            AppViewModel.setMainGoal(nameField.text.trim(), descField.text.trim());
                        }
                    }
                },
                {
                    text: "Cancel"
                }
            ]
        }

    FileManager {
        id: fileManager

        onExportCompleted: function(success, message, actualPath) {
            if (success) {
                // Показать успешное сообщение
                statusMessage.show("Export successful: " + actualPath, "#66BB6A")
            } else {
                // Показать ошибку
                statusMessage.show("Export failed: " + message, "#E95B5B")
            }
        }

        onImportCompleted: function(success, message, jsonData) {
            if (success) {
                AppViewModel.loadDataFromJson(jsonData)
                statusMessage.show("Import successful!", "#66BB6A")
            } else {
                statusMessage.show("Import failed: " + message, "#E95B5B")
            }
        }
    }

    function exportData() {
        var jsonData = AppViewModel.getCurrentDataAsJson()
        // Передаем пустую строку, чтобы fileManager сам создал путь в VisionCompass_Backups
        fileManager.exportToFile("", jsonData)
    }

    function importData() {
        // Для импорта используем простой путь - пользователь может указать файл
        var defaultPath = AppViewModel.getDefaultImportPath() + "/VisionCompass_backup.json"
        fileManager.importFromFile(defaultPath)
    }

    // Компонент для показа статус сообщений
    Rectangle {
        id: statusMessage
        visible: false
        anchors.top: parent.top
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.topMargin: 20
        width: Math.min(parent.width - 40, 400)
        height: 60
        color: "#2D2D2D"
        radius: 10
        border.width: 2
        z: 1000

        property string messageText: ""
        property color messageColor: "#66BB6A"

        function show(text, color) {
            messageText = text
            messageColor = color
            border.color = color
            visible = true
            hideTimer.restart()
        }

        Text {
            anchors.centerIn: parent
            text: statusMessage.messageText
            color: statusMessage.messageColor
            font.pointSize: 11
            font.bold: true
            wrapMode: Text.WordWrap
            width: parent.width - 20
            horizontalAlignment: Text.AlignHCenter
        }

        Timer {
            id: hideTimer
            interval: 4000
            onTriggered: statusMessage.visible = false
        }

        MouseArea {
            anchors.fill: parent
            onClicked: statusMessage.visible = false
        }
    }

    // Data Management Dialog
    CustomDialog {
        id: dataManagementDialog
        dialogWidth: 450

        content: Component {
            ColumnLayout {
                spacing: 20

                Text {
                    text: "Data Management"
                    color: "#F3C44A"
                    font.pointSize: 16
                    font.bold: true
                    Layout.alignment: Qt.AlignHCenter
                }

                // Export Section
                Rectangle {
                    Layout.fillWidth: true
                    height: 60
                    color: "#2D2D2D"
                    radius: 10
                    border.color: "#444444"
                    border.width: 1

                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: 15
                        spacing: 15

                        Text {
                            text: "📤"
                            font.pointSize: 20
                            color: "#66BB6A"
                        }

                        ColumnLayout {
                            Layout.preferredWidth: 280
                            spacing: 2

                            Text {
                                text: "Export Data"
                                color: "#FFFFFF"
                                font.pointSize: 12
                                font.bold: true
                            }

                            Text {
                                text: "Save your data to a backup file"
                                color: "#AAAAAA"
                                font.pointSize: 10
                                wrapMode: Text.WordWrap
                                Layout.fillWidth: true
                            }
                        }

                        Rectangle {
                            Layout.preferredWidth: 80
                            Layout.preferredHeight: 30
                            color: "#66BB6A"
                            radius: 15

                            Text {
                                text: "Export"
                                anchors.centerIn: parent
                                color: "#1E1E1E"
                                font.pointSize: 10
                                font.bold: true
                            }

                            MouseArea {
                                anchors.fill: parent
                                onClicked: {
                                    dataManagementDialog.close()
                                    exportData()
                                }
                                hoverEnabled: true
                                onEntered: parent.color = "#76CC7A"
                                onExited: parent.color = "#66BB6A"
                            }
                        }
                    }
                }

                // Import Section
                Rectangle {
                    Layout.fillWidth: true
                    height: 60
                    color: "#2D2D2D"
                    radius: 10
                    border.color: "#444444"
                    border.width: 1

                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: 15
                        spacing: 15

                        Text {
                            text: "📥"
                            font.pointSize: 20
                            color: "#42A5F5"
                        }

                        ColumnLayout {
                            Layout.preferredWidth: 280
                            spacing: 2

                            Text {
                                text: "Import Data"
                                color: "#FFFFFF"
                                font.pointSize: 12
                                font.bold: true
                            }

                            Text {
                                text: "Load data from a backup file"
                                color: "#AAAAAA"
                                font.pointSize: 10
                                wrapMode: Text.WordWrap
                                Layout.fillWidth: true
                            }
                        }

                        Rectangle {
                            Layout.preferredWidth: 80
                            Layout.preferredHeight: 30
                            color: "#42A5F5"
                            radius: 15

                            Text {
                                text: "Import"
                                anchors.centerIn: parent
                                color: "#1E1E1E"
                                font.pointSize: 10
                                font.bold: true
                            }

                            MouseArea {
                                anchors.fill: parent
                                onClicked: {
                                    dataManagementDialog.close()
                                    importData()
                                }
                                hoverEnabled: true
                                onEntered: parent.color = "#52B5FF"
                                onExited: parent.color = "#42A5F5"
                            }
                        }
                    }
                }

                // Clear Data Section - ОСТАЕТСЯ БЕЗ ИЗМЕНЕНИЙ
                Rectangle {
                    Layout.fillWidth: true
                    height: 60
                    color: "#2D2D2D"
                    radius: 10
                    border.color: "#444444"
                    border.width: 1

                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: 15
                        spacing: 15

                        Text {
                            text: "🗑"
                            font.pointSize: 20
                            color: "#E95B5B"
                        }

                        ColumnLayout {
                            Layout.preferredWidth: 280
                            spacing: 2

                            Text {
                                text: "Clear All Data"
                                color: "#FFFFFF"
                                font.pointSize: 12
                                font.bold: true
                            }

                            Text {
                                text: "Reset to default state (irreversible)"
                                color: "#AAAAAA"
                                font.pointSize: 10
                                wrapMode: Text.WordWrap
                                Layout.fillWidth: true
                            }
                        }

                        Rectangle {
                            Layout.preferredWidth: 80
                            Layout.preferredHeight: 30
                            color: "#E95B5B"
                            radius: 15

                            Text {
                                text: "Clear"
                                anchors.centerIn: parent
                                color: "#FFFFFF"
                                font.pointSize: 10
                                font.bold: true
                            }

                            MouseArea {
                                anchors.fill: parent
                                onClicked: {
                                    clearDataConfirmDialog.open()
                                }
                                hoverEnabled: true
                                onEntered: parent.color = "#F76B6B"
                                onExited: parent.color = "#E95B5B"
                            }
                        }
                    }
                }
            }
        }

        buttons: [
            {
                text: "Close"
            }
        ]
    }

    // Clear Data Confirmation Dialog
    CustomDialog {
        id: clearDataConfirmDialog
        dialogWidth: 400

        content: Component {
            ColumnLayout {
                spacing: 15

                Text {
                    text: "⚠️ Clear All Data"
                    color: "#E95B5B"
                    font.pointSize: 16
                    font.bold: true
                    Layout.alignment: Qt.AlignHCenter
                }

                Text {
                    text: "This action will permanently delete all your goals, sub-goals, and tasks. This cannot be undone."
                    color: "#FFFFFF"
                    font.pointSize: 12
                    Layout.fillWidth: true
                    wrapMode: Text.WordWrap
                    horizontalAlignment: Text.AlignHCenter
                }

                Text {
                    text: "Are you absolutely sure you want to continue?"
                    color: "#F3C44A"
                    font.pointSize: 12
                    font.bold: true
                    Layout.fillWidth: true
                    horizontalAlignment: Text.AlignHCenter
                }
            }
        }

        buttons: [
            {
                text: "Yes, Clear All Data",
                color: "#E95B5B",
                onClicked: function() {
                    AppViewModel.clearAllData();
                    dataManagementDialog.close();
                }
            },
            {
                text: "Cancel",
                color: "#3A3A3A"
            }
        ]
    }

    // Info Dialog
    CustomDialog {
        id: infoDialog
        dialogWidth: 500

        content: Component {
            ColumnLayout {
                spacing: 20

                Text {
                    text: "Vision Compass - Quick Guide"
                    color: "#F3C44A"
                    font.pointSize: 18
                    font.bold: true
                    Layout.alignment: Qt.AlignHCenter
                }

                // Main Goal Section
                Rectangle {
                    Layout.fillWidth: true
                    height: 70
                    color: "#2D2D2D"
                    radius: 10
                    border.color: "#E95B5B"
                    border.width: 2

                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: 15
                        spacing: 15

                        Rectangle {
                            width: 30
                            height: 30
                            color: "#E95B5B"
                            radius: 15
                            Layout.alignment: Qt.AlignVCenter

                            Text {
                                text: "🎯"
                                anchors.centerIn: parent
                                font.pointSize: 14
                            }
                        }

                        ColumnLayout {
                            Layout.fillWidth: true
                            Layout.alignment: Qt.AlignVCenter
                            Layout.topMargin: -5
                            spacing: 2

                            Text {
                                text: "Main Goal (1 year to 10+ years)"
                                color: "#FFFFFF"
                                font.pointSize: 12
                                font.bold: true
                            }

                            Text {
                                text: "Your main goal, as a guide for life"
                                color: "#AAAAAA"
                                font.pointSize: 10
                                wrapMode: Text.WordWrap
                                Layout.fillWidth: true
                            }
                        }
                    }
                }

                // SubGoals Section
                Rectangle {
                    Layout.fillWidth: true
                    height: 70
                    color: "#2D2D2D"
                    radius: 10
                    border.color: "#F3C44A"
                    border.width: 2

                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: 15
                        spacing: 15

                        Rectangle {
                            width: 30
                            height: 30
                            color: "#F3C44A"
                            radius: 15
                            Layout.alignment: Qt.AlignVCenter

                            Text {
                                text: "📋"
                                anchors.centerIn: parent
                                font.pointSize: 14
                            }
                        }

                        ColumnLayout {
                            Layout.fillWidth: true
                            Layout.alignment: Qt.AlignVCenter
                            Layout.topMargin: -5
                            spacing: 2

                            Text {
                                text: "Subgoals (3 months to 1 year)"
                                color: "#FFFFFF"
                                font.pointSize: 12
                                font.bold: true
                            }

                            Text {
                                text: "Major directions/blocks leading to the main goal"
                                color: "#AAAAAA"
                                font.pointSize: 10
                                wrapMode: Text.WordWrap
                                Layout.fillWidth: true
                            }
                        }
                    }
                }

                // Tasks Section
                Rectangle {
                    Layout.fillWidth: true
                    height: 70
                    color: "#2D2D2D"
                    radius: 10
                    border.color: "#66BB6A"
                    border.width: 2

                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: 15
                        spacing: 15

                        Rectangle {
                            width: 30
                            height: 30
                            color: "#66BB6A"
                            radius: 15
                            Layout.alignment: Qt.AlignVCenter

                            Text {
                                text: "✓"
                                anchors.centerIn: parent
                                font.pointSize: 14
                                color: "#1E1E1E"
                                font.bold: true
                            }
                        }

                        ColumnLayout {
                            Layout.fillWidth: true
                            Layout.alignment: Qt.AlignVCenter
                            Layout.topMargin: -5
                            spacing: 2

                            Text {
                                text: "Tasks (1 day to 3 months)"
                                color: "#FFFFFF"
                                font.pointSize: 12
                                font.bold: true
                            }

                            Text {
                                text: "Components of subgoals that we must accomplish"
                                color: "#AAAAAA"
                                font.pointSize: 10
                                wrapMode: Text.WordWrap
                                Layout.fillWidth: true
                            }
                        }
                    }
                }

                Text {
                    text: "💡 Use keyboard shortcuts 1-9 to quickly select subgoals!"
                    color: "#F3C44A"
                    font.pointSize: 11
                    font.bold: true
                    Layout.alignment: Qt.AlignHCenter
                    Layout.topMargin: 10
                }
            }
        }

        buttons: [
            {
                text: "Got it!",
                color: "#F3C44A",
                textColor: "#1E1E1E"
            }
        ]
    }
}

