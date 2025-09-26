import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtQuick.Window
import QtQuick.Effects
import com.visioncompass 1.0


ApplicationWindow {
    id: mainWindow
    objectName: "mainWindow"

    // Window Properties
    visible: true
    width: 1000
    height: 900
    minimumWidth: 600
    minimumHeight: 500
    title: "Vision Compass"

    // Custom Properties for State Preservation
    property bool preserveTaskScrollPosition: false
    property real savedTaskScrollY: 0
    property bool preserveSubGoalScrollPosition: false
    property real savedSubGoalScrollX: 0

    property bool allCurrentTasksCompleted: {
        if (!AppViewModel.currentTasksListModel || AppViewModel.currentTasksListModel.length === 0) {
            return false;
        }
        for (let i = 0; i < AppViewModel.currentTasksListModel.length; i++) {
            if (!AppViewModel.currentTasksListModel[i].completed) {
                return false;
            }
        }
        return true;
    }

    // Non-visual Components
    Animations { id: appAnimations
        bigCircle: bigCircle
        bigCircleEffect: bigCircleEffect
        goalCircle: goalCircle
        goalCircleEffect: goalCircleEffect
        taskListView: taskListView
        subGoalsList: subGoalsList
    }
    Dialogs { id: dialogs }
    FileManager { id: fileManager }

    // --- LOGIC AND STATE MANAGEMENT ---

    Component.onCompleted: {
        AppViewModel.loadData()
        Qt.callLater(function() {
            scrollToSelectedItem()
            Qt.callLater(function() {
                selectFirstTaskIfNeeded(false)
            })
        })
    }

    Connections {
        target: AppViewModel
        function onSelectedSubGoalIdChanged() {
            Qt.callLater(function() {
                // Scrolling is needed when changing SubGoal, as it's a navigation action
                selectFirstTaskIfNeeded(true);
                // Check if there are tasks and if all are completed
                if (AppViewModel.currentTasksListModel && AppViewModel.currentTasksListModel.length > 0) {
                    var allCompleted = true;
                    for (var i = 0; i < AppViewModel.currentTasksListModel.length; i++) {
                        if (!AppViewModel.currentTasksListModel[i].completed) {
                            allCompleted = false;
                            break;
                        }
                    }
                    // Start animation if all tasks are completed
                    if (allCompleted) {
                        appAnimations.startUnifiedPulseAnimation();
                    }
                }
            });
        }
    }

    Connections {
        target: AppViewModel
        function onSubGoalsListModelChanged() {
            // If we saved the position, restore it
            if (preserveSubGoalScrollPosition && subGoalsList) {
                Qt.callLater(function() {
                    subGoalsList.contentX = savedSubGoalScrollX
                    preserveSubGoalScrollPosition = false
                })
            }
        }
    }

    Connections {
        target: AppViewModel
        function onCurrentTasksListModelChanged() {
            // If we saved the position, restore it
            if (preserveTaskScrollPosition && taskListView) {
                Qt.callLater(function() {
                    taskListView.contentY = savedTaskScrollY
                    preserveTaskScrollPosition = false
                })
            }
            // Check the task state with a short delay for correct updates
            Qt.callLater(function() {
                if (allCurrentTasksCompleted && AppViewModel.currentTasksListModel && AppViewModel.currentTasksListModel.length > 0) {
                    appAnimations.unifiedPulseAnimation.start();
                }
            });
        }
    }

    Connections {
        target: fileManager
        function onExportCompleted(success, message, actualPath) {
            if (success) {
                statusMessage.show("Export successful: " + actualPath, "#66BB6A")
            } else {
                statusMessage.show("Export failed: " + message, "#E95B5B")
            }
        }

        function onImportCompleted(success, message, jsonData) {
            if (success) {
                AppViewModel.loadDataFromJson(jsonData)
                statusMessage.show("Import successful!", "#66BB6A")
            } else {
                statusMessage.show("Import failed: " + message, "#E95B5B")
            }
        }
    }

    // --- JAVASCRIPT FUNCTIONS ---

    function saveSubGoalScrollPosition() {
        if (subGoalsList) {
            savedSubGoalScrollX = subGoalsList.contentX
            preserveSubGoalScrollPosition = true
        }
    }

    function saveTaskScrollPosition() {
        if (taskListView) {
            savedTaskScrollY = taskListView.contentY
            preserveTaskScrollPosition = true
        }
    }

    function scrollToSelectedItem() {
        if (!AppViewModel.selectedSubGoalId || !AppViewModel.subGoalsListModel) return;
        var selectedIndex = -1;
        for (var i = 0; i < AppViewModel.subGoalsListModel.length; i++) {
            if (AppViewModel.subGoalsListModel[i].id === AppViewModel.selectedSubGoalId) {
                selectedIndex = i;
                break;
            }
        }

        if (selectedIndex === -1) return;
        var itemWidth = 180;
        var itemSpacing = 15;
        var itemPosition = selectedIndex * (itemWidth + itemSpacing);
        var viewportWidth = subGoalsList.width;

        // Calculate the optimal position to center the item
        var targetContentX = itemPosition - (viewportWidth - itemWidth) / 2;
        // Limit the position to the content boundaries
        var maxContentX = Math.max(0, subGoalsList.contentWidth - viewportWidth);
        targetContentX = Math.max(0, Math.min(maxContentX, targetContentX));

        // Direct assignment for an immediate effect, then animate for smoothness
        subGoalsList.contentX = targetContentX;
        appAnimations.scrollAnimation.to = targetContentX;
        appAnimations.scrollAnimation.start();
    }

    function selectSubGoalByIndex(index) {
        if (AppViewModel.subGoalsListModel && AppViewModel.subGoalsListModel.length > index) {
            var subGoalId = AppViewModel.subGoalsListModel[index].id;
            AppViewModel.selectSubGoal(subGoalId);

            // Direct centering after selection
            Qt.callLater(function() {
                var itemWidth = 180;
                var itemSpacing = 15;
                var itemPosition = index * (itemWidth + itemSpacing);
                var viewportWidth = subGoalsList.width;
                var targetContentX = itemPosition - (viewportWidth - itemWidth) / 2;
                var maxContentX = Math.max(0, subGoalsList.contentWidth - viewportWidth);
                targetContentX = Math.max(0, Math.min(maxContentX, targetContentX));
                subGoalsList.contentX = targetContentX;
            });
        }
    }

    function selectFirstTaskIfNeeded(shouldScroll = true) {
        if (taskListView) {
            taskListView.savedContentY = taskListView.contentY
        }
        if (AppViewModel.currentTasksListModel && AppViewModel.currentTasksListModel.length > 0) {
            AppViewModel.selectTask(AppViewModel.currentTasksListModel[0].id);
            if (shouldScroll) {
                Qt.callLater(() => scrollToSelectedTask(0));
            }
        } else {
            AppViewModel.selectTask(0);
        }
    }

    function selectTaskByDirection(direction) {
        if (!AppViewModel.currentTasksListModel || AppViewModel.currentTasksListModel.length === 0) {
            return;
        }
        var currentIndex = -1;
        for (var i = 0; i < AppViewModel.currentTasksListModel.length; i++) {
            if (AppViewModel.currentTasksListModel[i].id === AppViewModel.selectedTaskId) {
                currentIndex = i;
                break;
            }
        }

        var newIndex = currentIndex;
        if (direction === "down") {
            newIndex = (currentIndex + 1) % AppViewModel.currentTasksListModel.length;
        } else if (direction === "up") {
            newIndex = currentIndex <= 0 ? AppViewModel.currentTasksListModel.length - 1 : currentIndex - 1;
        }

        if (newIndex >= 0 && newIndex < AppViewModel.currentTasksListModel.length) {
            AppViewModel.selectTask(AppViewModel.currentTasksListModel[newIndex].id);
            scrollToSelectedTask(newIndex);
        }
    }

    function scrollToSelectedTask(taskIndex) {
        if (!taskListView || taskIndex < 0) return;
        var taskHeight = 60; // Approximate height of one task with margins
        var taskPosition = taskIndex * taskHeight;
        var viewportHeight = taskListView.height;
        var targetContentY = taskPosition - (viewportHeight - taskHeight) / 2;
        var maxContentY = Math.max(0, taskListView.contentHeight - viewportHeight);
        targetContentY = Math.max(0, Math.min(maxContentY, targetContentY));

        appAnimations.taskScrollAnimation.to = targetContentY;
        appAnimations.taskScrollAnimation.start();
    }

    function preserveScrollPosition(action, wasTaskCompleted = false) {
        var currentY = taskListView.contentY
        var selectedTaskId = AppViewModel.selectedTaskId
        taskListView.blockModelUpdate = true
        action()
        if (!wasTaskCompleted) {
            if (allCurrentTasksCompleted && AppViewModel.currentTasksListModel && AppViewModel.currentTasksListModel.length > 0) {
                appAnimations.startUnifiedPulseAnimation()
            } else {
                appAnimations.startBigCircleOnlyAnimation()
            }
        }
        Qt.callLater(function() {
            if (allCurrentTasksCompleted && AppViewModel.currentTasksListModel && AppViewModel.currentTasksListModel.length > 0) {
                //goalCirclePulseAnimation.start();
            }
            taskListView.contentY = currentY
            if (selectedTaskId > 0) {
                AppViewModel.selectTask(selectedTaskId)
            }
            taskListView.blockModelUpdate = false
        });
    }

    function exportData() {
        var jsonData = AppViewModel.getCurrentDataAsJson()
        fileManager.exportToFile("", jsonData)
    }

    function importData() {
        var filePath = AppViewModel.getDefaultImportPath()
        fileManager.importFromFile(filePath)
    }

    function showShortcuts() {
        shortcutsOverlay.showShortcuts()
    }

    // --- SHORTCUTS ---

    Shortcut { sequence: "1"; onActivated: selectSubGoalByIndex(0) }
    Shortcut { sequence: "2"; onActivated: selectSubGoalByIndex(1) }
    Shortcut { sequence: "3"; onActivated: selectSubGoalByIndex(2) }
    Shortcut { sequence: "4"; onActivated: selectSubGoalByIndex(3) }
    Shortcut { sequence: "5"; onActivated: selectSubGoalByIndex(4) }
    Shortcut { sequence: "6"; onActivated: selectSubGoalByIndex(5) }
    Shortcut { sequence: "7"; onActivated: selectSubGoalByIndex(6) }
    Shortcut { sequence: "8"; onActivated: selectSubGoalByIndex(7) }
    Shortcut { sequence: "9"; onActivated: selectSubGoalByIndex(8) }
    Shortcut { sequence: "Shift+T"; onActivated: dialogs.addTaskDialog.open() }
    Shortcut { sequence: "X"; onActivated: {
            if (AppViewModel.selectedTaskId > 0) {
                var wasCompleted = false
                for (var i = 0; i < AppViewModel.currentTasksListModel.length; i++) {
                    if (AppViewModel.currentTasksListModel[i].id === AppViewModel.selectedTaskId) {
                        wasCompleted = AppViewModel.currentTasksListModel[i].completed
                        break
                    }
                }
                preserveScrollPosition(function() {
                    AppViewModel.completeTask(AppViewModel.selectedTaskId)
                }, wasCompleted)
            }
        }
    }
    Shortcut { sequence: "I"; onActivated: dialogs.infoDialog.open() }
    Shortcut { sequence: "D"; onActivated: dialogs.dataManagementDialog.open() }
    Shortcut { sequence: "G"; onActivated: dialogs.editGoalDialog.openForEditing() }
    Shortcut { sequence: "Ctrl+S"; onActivated: exportData() }
    Shortcut { sequence: "Shift+S"; onActivated: dialogs.addSubGoalDialog.open() }
    Shortcut { sequence: "Down"; onActivated: selectTaskByDirection("down") }
    Shortcut { sequence: "Up"; onActivated: selectTaskByDirection("up") }
    Shortcut { sequence: "Tab"; onActivated: selectTaskByDirection("down") }
    Shortcut { sequence: "Shift+Tab"; onActivated: selectTaskByDirection("up") }
    Shortcut { sequence: "F"; onActivated: {
            var wasFullscreen = mainWindow.visibility === Window.FullScreen
            mainWindow.visible = false
            Qt.callLater(function() {
                if (wasFullscreen) {
                    mainWindow.visibility = Window.Windowed
                } else {
                    mainWindow.visibility = Window.FullScreen
                }
                mainWindow.visible = true
            })
        }
    }
    Shortcut { sequence: "Ctrl+Q"; onActivated: Qt.quit() }


    // --- VISUAL TREE ---

    ColumnLayout {
        anchors.fill: parent
        spacing: 0

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

        MultiEffect {
            id: bigCircleEffect
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

        // --- Top Section (Goal and SubGoals) ---
        Item {
            id: topSection
            Layout.fillWidth: true
            Layout.preferredHeight: 450

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
                        width: goalCircle.width * 0.8
                        font.pointSize: 20
                        font.bold: true
                        color: "white"
                        horizontalAlignment: Text.AlignHCenter
                        wrapMode: Text.WordWrap
                    }
                    Text {
                        id: goalDescriptionText
                        text: AppViewModel.currentGoalDescription
                        width: goalCircle.width * 0.8
                        font.pointSize: 12
                        color: "white"
                        horizontalAlignment: Text.AlignHCenter
                        wrapMode: Text.WordWrap
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    property bool isInsideCircle: {
                        var centerX = width / 2
                        var centerY = height / 2
                        var radius = Math.min(width, height) / 2
                        var dx = mouseX - centerX
                        var dy = mouseY - centerY
                        return (dx * dx + dy * dy) <= (radius * radius)
                    }
                    onClicked: {
                        if (isInsideCircle) {
                            dialogs.editGoalDialog.openForEditing()
                        }
                    }
                    onPositionChanged: {
                        if (isInsideCircle && !parent.color.toString().includes("#3F2F2F")) {
                            parent.color = "#3F2F2F"
                        } else if (!isInsideCircle && !parent.color.toString().includes("#282828")) {
                            parent.color = "#282828"
                        }
                    }
                    onExited: parent.color = "#282828"
                }
            }

            MultiEffect {
                id: goalCircleEffect
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

            Rectangle {
                id: subGoalsContainer
                height: 160
                color: "transparent"
                anchors.bottom: parent.bottom
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.margins: 20

                ColumnLayout {
                    anchors.fill: parent
                    spacing: 10

                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 120
                        color: "transparent"

                        Item {
                            id: centeredContainer
                            width: Math.min(parent.width, 5 * (180 + 15) - 15) // Max 5 slots
                            height: parent.height
                            anchors.horizontalCenter: parent.horizontalCenter

                            ScrollView {
                                id: subGoalsScrollView
                                anchors.fill: parent
                                anchors.bottomMargin: -10
                                clip: true
                                ScrollBar.vertical.policy: ScrollBar.AlwaysOff
                                ScrollBar.horizontal.policy: ScrollBar.AlwaysOff

                                MouseArea {
                                    anchors.fill: parent
                                    z: -1
                                    propagateComposedEvents: true
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
                                }

                                ListView {
                                    id: subGoalsList
                                    orientation: ListView.Horizontal
                                    anchors.fill: parent
                                    model: AppViewModel.subGoalsListModel
                                    spacing: 15
                                    clip: true
                                    leftMargin: 5
                                    rightMargin: 5
                                    property real savedContentX: 0
                                    property bool blockModelUpdate: false

                                    Component.onCompleted: {
                                        contentX = 0
                                        Qt.callLater(function() {
                                            if (AppViewModel.selectedSubGoalId > 0) {
                                                scrollToSelectedItem()
                                            }
                                        })
                                    }

                                    onModelChanged: {
                                        if (blockModelUpdate) return
                                    }

                                    delegate: Item {
                                        width: 180
                                        height: 110
                                        property bool isSelected: modelData.id === AppViewModel.selectedSubGoalId
                                        property bool allTasksCompleted: {
                                            let completionStatus = AppViewModel.subGoalCompletionStatus;
                                            for (let i = 0; i < completionStatus.length; i++) {
                                                if (completionStatus[i].subGoalId === modelData.id) {
                                                    return completionStatus[i].hasAnyTasks && completionStatus[i].allTasksCompleted;
                                                }
                                            }
                                            return false;
                                        }
                                        property bool isHovered: mainMouseArea.containsMouse || editButton.isButtonHovered || deleteButton.isButtonHovered

                                        MouseArea {
                                            id: mainMouseArea
                                            anchors.fill: parent
                                            hoverEnabled: true
                                            onClicked: { AppViewModel.selectSubGoal(modelData.id); }
                                        }

                                        Row {
                                            anchors.top: subGoalRect.top
                                            anchors.right: subGoalRect.right
                                            anchors.topMargin: -25
                                            anchors.rightMargin: 5
                                            spacing: 5
                                            visible: isHovered
                                            z: 15

                                            Rectangle {
                                                id: editButton
                                                width: 20; height: 20
                                                radius: 10; color: "#404040"
                                                property bool isButtonHovered: editMouseArea.containsMouse
                                                Text { text: "✎"; anchors.centerIn: parent; font.pointSize: 9; color: "#FFFFFF"; font.bold: true }
                                                MouseArea {
                                                    id: editMouseArea
                                                    anchors.fill: parent; hoverEnabled: true
                                                    onClicked: { dialogs.editSubGoalDialog.openForEditing(modelData); }
                                                    onEntered: parent.color = "#555555"
                                                    onExited: parent.color = "#404040"
                                                }
                                            }
                                            Rectangle {
                                                id: deleteButton
                                                width: 20; height: 20
                                                radius: 10; color: "#404040"
                                                visible: AppViewModel.subGoalsListModel.length > 1
                                                property bool isButtonHovered: deleteMouseArea.containsMouse
                                                Text { text: "✕"; anchors.centerIn: parent; font.pointSize: 9; color: "#FFFFFF"; font.bold: true }
                                                MouseArea {
                                                    id: deleteMouseArea
                                                    anchors.fill: parent; hoverEnabled: true
                                                    onClicked: {
                                                        dialogs.confirmationDialog.open();
                                                        dialogs.confirmationDialog.subGoalToRemove = modelData;
                                                    }
                                                    onEntered: parent.color = "#555555"
                                                    onExited: parent.color = "#404040"
                                                }
                                            }
                                        }

                                        Rectangle {
                                            id: subGoalRect
                                            width: 180; height: 80
                                            radius: 15; border.width: 0
                                            anchors.bottom: parent.bottom
                                            anchors.horizontalCenter: parent.horizontalCenter

                                            color: isSelected ? "transparent" : (isHovered ? "#4A4A43" : "#323232")

                                            Rectangle {
                                                anchors.fill: parent
                                                radius: parent.radius
                                                visible: isSelected
                                                gradient: Gradient {
                                                    GradientStop { position: 0.0; color: "#5B5B49" }
                                                    GradientStop { position: 1.0; color: "#323232" }
                                                }
                                            }
                                            Text {
                                                text: (index + 1).toString()
                                                anchors.bottom: parent.bottom; anchors.right: parent.right
                                                anchors.bottomMargin: 5; anchors.rightMargin: 12
                                                font.pointSize: 9; font.bold: true
                                                color: "#FFFFFF"; visible: index < 9; z: 10
                                            }
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
                                                        color: "#FFFFFF"; font.pointSize: 10; font.bold: true
                                                        Layout.fillWidth: true; Layout.alignment: Qt.AlignCenter
                                                        horizontalAlignment: Text.AlignHCenter
                                                        wrapMode: Text.WordWrap
                                                        maximumLineCount: 2
                                                        elide: Text.ElideRight
                                                    }
                                                }
                                            }
                                        }
                                        MultiEffect {
                                            source: subGoalRect
                                            anchors.fill: subGoalRect
                                            shadowEnabled: true; shadowOpacity: 0.5
                                            shadowColor: allTasksCompleted ? "#E95B5B" : "#000000"
                                            shadowVerticalOffset: 2
                                            shadowBlur: 0.5
                                            z: -1
                                        }
                                    }
                                }
                                Rectangle {
                                    id: customScrollBar
                                    anchors.left: parent.left
                                    anchors.right: parent.right
                                    anchors.bottom: parent.bottom
                                    height: 6; color: "transparent"; radius: 2
                                    visible: subGoalsList.contentWidth > subGoalsList.width

                                    MouseArea {
                                        anchors.fill: parent; hoverEnabled: true
                                        onWheel: {
                                            if (subGoalsList.contentWidth > subGoalsList.width) {
                                                var delta = wheel.angleDelta.y > 0 ? -30 : 30;
                                                subGoalsList.contentX = Math.max(0, Math.min(subGoalsList.contentWidth - subGoalsList.width, subGoalsList.contentX + delta));
                                            }
                                        }
                                        onClicked: {
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
                                            if (subGoalsList.contentWidth <= subGoalsList.width) return parent.width;
                                            var ratio = subGoalsList.width / subGoalsList.contentWidth;
                                            return Math.max(20, parent.width * ratio);
                                        }
                                        y: 0; radius: 2
                                        property real maxX: parent.width - width
                                        x: 0

                                        Component.onCompleted: {
                                            x = Qt.binding(function() {
                                                if (subGoalsList.contentWidth <= subGoalsList.width) return 0;
                                                var ratio = subGoalsList.contentX / (subGoalsList.contentWidth - subGoalsList.width);
                                                return Math.max(0, Math.min(maxX, ratio * maxX));
                                            })
                                        }

                                        color: scrollMouseArea.pressed ? "#888888" : (scrollMouseArea.containsMouse ? "#AAAAAA" : "#666666")
                                        opacity: scrollMouseArea.pressed ? 1.0 : (scrollMouseArea.containsMouse ? 0.8 : 0.5)

                                        Behavior on opacity { NumberAnimation { duration: 200 } }
                                        Behavior on color { ColorAnimation { duration: 200 } }

                                        MouseArea {
                                            id: scrollMouseArea
                                            anchors.fill: parent; hoverEnabled: true
                                            drag.target: parent; drag.axis: Drag.XAxis
                                            drag.minimumX: 0; drag.maximumX: parent.maxX
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
            }

            Item {
                id: addSubGoalButtonTop
                width: 50; height: 50
                x: parent.width / 2 + 210; y: 180
                Rectangle {
                    id: mainButton
                    anchors.fill: parent; color: "#383838"; radius: 25
                    Text { text: "+"; anchors.centerIn: parent; anchors.verticalCenterOffset: -2; font.pointSize: 18; font.bold: true; color: "#F3C44A" }
                }
                MultiEffect {
                    source: mainButton; anchors.fill: mainButton; z: -1
                    shadowEnabled: true; shadowOpacity: 0.5; shadowColor: "#000000"
                    shadowVerticalOffset: 3; shadowBlur: 0.8
                }
                MouseArea {
                    anchors.fill: parent; hoverEnabled: true
                    onClicked: { dialogs.addSubGoalDialog.open() }
                    onEntered: mainButton.color = "#4A4A43"
                    onExited: mainButton.color = "#383838"
                }
            }

            Item {
                id: dataMenuButton
                width: 50; height: 50
                x: parent.width / 2 - 310; y: 180
                Rectangle {
                    id: dataButton
                    anchors.fill: parent; radius: 25
                    color: dataMouseArea.containsMouse ? "#4A4A43" : "#383838"
                    Behavior on color { ColorAnimation { duration: 150 } }
                    Image {
                        id: saveIcon
                        source: "icons/Save_Icon.svg"
                        width: 24; height: 24; anchors.centerIn: parent
                        fillMode: Image.PreserveAspectFit; sourceSize: Qt.size(24, 24)
                        layer.enabled: true
                        layer.effect: MultiEffect {
                            brightness: dataMouseArea.containsMouse ? 0.3 : 0.0
                            saturation: dataMouseArea.containsMouse ? 1.2 : 1.0
                        }
                    }
                }
                MultiEffect {
                    source: dataButton; anchors.fill: dataButton; z: -1
                    shadowEnabled: true; shadowOpacity: 0.5; shadowColor: "#000000"
                    shadowVerticalOffset: 3; shadowBlur: 0.8
                }
                MouseArea {
                    id: dataMouseArea
                    anchors.fill: parent; hoverEnabled: true
                    onClicked: { dialogs.dataManagementDialog.open() }
                }
            }

            Item {
                id: infoButton
                width: 50; height: 50
                x: parent.width / 2 - 230; y: 180
                Rectangle {
                    id: infoButtonRect
                    anchors.fill: parent; color: "#383838"; radius: 25
                    Image {
                        id: infoIcon
                        source: "icons/Info_Icon.svg"
                        width: 24; height: 24; anchors.centerIn: parent
                        fillMode: Image.PreserveAspectFit; sourceSize: Qt.size(24, 24)
                        layer.enabled: true
                        layer.effect: MultiEffect {
                            brightness: infoMouseArea.containsMouse ? 0.3 : 0.0
                            saturation: infoMouseArea.containsMouse ? 1.2 : 1.0
                        }
                    }
                }
                MultiEffect {
                    source: infoButtonRect; anchors.fill: infoButtonRect; z: -1
                    shadowEnabled: true; shadowOpacity: 0.5; shadowColor: "#000000"
                    shadowVerticalOffset: 3; shadowBlur: 0.8
                }
                MouseArea {
                    id: infoMouseArea
                    anchors.fill: parent; hoverEnabled: true
                    onClicked: { dialogs.infoDialog.open() }
                    onEntered: { infoButtonRect.color = "#4A4A43" }
                    onExited: { infoButtonRect.color = "#383838" }
                }
            }
        }

        // --- Bottom Section (Tasks) ---
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

                Item {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 60

                    Rectangle {
                        id: addTaskButton
                        width: 50; height: 50
                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.horizontalCenterOffset: 235
                        anchors.top: parent.top; anchors.topMargin: 5
                        color: "#383838"; radius: 25
                        Text { text: "+"; anchors.centerIn: parent; anchors.verticalCenterOffset: -2; font.pointSize: 18; font.bold: true; color: "#FFFFFF" }
                        MouseArea {
                            anchors.fill: parent; hoverEnabled: true
                            onClicked: { dialogs.addTaskDialog.open() }
                            onEntered: parent.color = "#4A4A43"
                            onExited: parent.color = "#383838"
                        }
                    }
                    MultiEffect {
                        source: addTaskButton; anchors.fill: addTaskButton; z: -1
                        shadowEnabled: true; shadowOpacity: 0.5; shadowColor: "#000000"
                        shadowVerticalOffset: 3; shadowBlur: 0.8
                    }
                }

                Rectangle {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    color: "transparent"

                    MouseArea {
                        anchors.fill: parent
                        z: -1; propagateComposedEvents: true
                        onWheel: {
                            var delta = wheel.angleDelta.y > 0 ? -30 : 30;
                            var newContentY = Math.max(0, Math.min(taskListView.contentHeight - taskListView.height, taskListView.contentY + delta));
                            if (taskListView.contentHeight > taskListView.height) {
                                taskListView.contentY = newContentY;
                            }
                        }
                    }

                    ListView {
                        id: taskListView
                        anchors.fill: parent; anchors.rightMargin: 15
                        model: AppViewModel.currentTasksListModel
                        spacing: 10; clip: true
                        property real savedContentY: 0
                        property bool blockModelUpdate: false
                        onModelChanged: { if (blockModelUpdate) return }
                        onContentYChanged: { savedContentY = contentY }

                        delegate: Rectangle {
                            id: taskItem
                            width: 600; height: Math.max(50, taskContent.implicitHeight + 16)
                            anchors.horizontalCenter: parent ? parent.horizontalCenter : undefined
                            radius: 12; border.color: "#444444"; border.width: 1
                            opacity: 1.0
                            property bool isSelected: modelData.id === AppViewModel.selectedTaskId
                            property bool isHovered: mainTaskMouseArea.containsMouse || editTaskButton.isButtonHovered || deleteTaskButton.isButtonHovered
                            color: isSelected ? "#404040" : (isHovered ? "#353535" : "#2D2D2D")

                            MouseArea {
                                id: mainTaskMouseArea
                                anchors.fill: parent
                                onClicked: { AppViewModel.selectTask(modelData.id) }
                            }
                            HoverHandler {
                                id: taskHoverHandler
                                onHoveredChanged: {
                                    taskItem.isHovered = Qt.binding(function() {
                                        return taskHoverHandler.hovered || editTaskButton.isButtonHovered || deleteTaskButton.isButtonHovered
                                    })
                                }
                            }

                            RowLayout {
                                id: taskContent
                                anchors.fill: parent; anchors.margins: 8; spacing: 10
                                Rectangle {
                                    width: 30; height: 30
                                    color: modelData.completed ? "#2D2D2D" : "#383838"
                                    radius: 8; border.width: modelData.completed ? 0 : 1
                                    border.color: modelData.completed ? "#F3C44A" : "#707070"
                                    property bool isSelected: modelData.id === AppViewModel.selectedTaskId
                                    Rectangle {
                                        anchors.fill: parent; radius: parent.radius
                                        color: modelData.completed ? "#F3C44A" : "transparent"
                                        visible: modelData.completed
                                    }
                                    MouseArea {
                                        anchors.fill: parent; hoverEnabled: true
                                        z: 100; propagateComposedEvents: true
                                        onClicked: {
                                            AppViewModel.selectTask(modelData.id)
                                            var wasCompleted = modelData.completed
                                            preserveScrollPosition(function() {
                                                AppViewModel.completeTask(modelData.id)
                                            }, wasCompleted)
                                        }
                                    }
                                }

                                ColumnLayout {
                                    Layout.fillWidth: true; spacing: 2
                                    Text {
                                        color: "#FFFFFF"; font.pointSize: 10
                                        Layout.fillWidth: true; wrapMode: Text.WordWrap
                                        textFormat: Text.RichText
                                        text: modelData.completed ? "<s>" + modelData.name + "</s>" : modelData.name
                                        MouseArea { anchors.fill: parent; enabled: false }
                                    }
                                }

                                Item {
                                    id: editTaskButton
                                    width: 25; height: 25; visible: isHovered
                                    property bool isButtonHovered: editTaskMouseArea.containsMouse
                                    Text { text: "✎"; anchors.centerIn: parent; font.pointSize: 12; color: "#CCCCCC"; font.bold: true }
                                    MouseArea {
                                        id: editTaskMouseArea
                                        anchors.centerIn: parent; width: 20; height: 20; hoverEnabled: true
                                        onClicked: { preserveScrollPosition(() => dialogs.editTaskDialog.openForEditing(modelData)) }
                                        onEntered: parent.children[0].color = "#FFFFFF"
                                        onExited: parent.children[0].color = "#CCCCCC"
                                    }
                                }
                                Item {
                                    id: deleteTaskButton
                                    width: 25; height: 25; visible: isHovered
                                    property bool isButtonHovered: deleteTaskMouseArea.containsMouse
                                    Text { text: "✕"; anchors.centerIn: parent; font.pointSize: 12; color: "#CCCCCC"; font.bold: true }
                                    MouseArea {
                                        id: deleteTaskMouseArea
                                        anchors.centerIn: parent; width: 20; height: 20; hoverEnabled: true
                                        onClicked: { preserveScrollPosition(() => {
                                                dialogs.taskConfirmationDialog.open()
                                                dialogs.taskConfirmationDialog.taskToRemove = modelData
                                            })
                                        }
                                        onEntered: parent.children[0].color = "#FFFFFF"
                                        onExited: parent.children[0].color = "#CCCCCC"
                                    }
                                }
                            }
                        }
                    }

                    Rectangle {
                        id: customVerticalScrollBar
                        anchors.top: parent.top; anchors.right: parent.right
                        width: 6; height: Math.min(parent.height, mainWindow.height - topSection.height - 120)
                        color: "transparent"; radius: 3
                        visible: taskListView.contentHeight > taskListView.height

                        Rectangle {
                            id: verticalScrollHandle
                            width: parent.width; radius: 3
                            height: {
                                if (taskListView.contentHeight <= taskListView.height) return parent.height;
                                var ratio = taskListView.height / taskListView.contentHeight;
                                return Math.max(20, parent.height * ratio);
                            }
                            x: 0; y: 0; property real maxY: parent.height - height

                            Component.onCompleted: {
                                y = Qt.binding(function() {
                                    if (taskListView.contentHeight <= taskListView.height) return 0;
                                    var ratio = taskListView.contentY / (taskListView.contentHeight - taskListView.height);
                                    var calculatedY = ratio * maxY;
                                    return Math.max(0, Math.min(maxY, calculatedY));
                                })
                            }

                            color: verticalScrollMouseArea.pressed ? "#888888" : (verticalScrollMouseArea.containsMouse ? "#AAAAAA" : "#666666")
                            opacity: verticalScrollMouseArea.pressed ? 1.0 : (verticalScrollMouseArea.containsMouse ? 0.8 : 0.5)

                            Behavior on opacity { NumberAnimation { duration: 200 } }
                            Behavior on color { ColorAnimation { duration: 200 } }

                            MouseArea {
                                id: verticalScrollMouseArea
                                anchors.fill: parent; hoverEnabled: true
                                drag.target: parent; drag.axis: Drag.YAxis
                                drag.minimumY: 0; drag.maximumY: parent.maxY
                                onPositionChanged: {
                                    if (drag.active && taskListView.contentHeight > taskListView.height) {
                                        var ratio = Math.max(0, Math.min(1, parent.y / parent.maxY));
                                        var newContentY = ratio * (taskListView.contentHeight - taskListView.height);
                                        taskListView.contentY = Math.max(0, Math.min(taskListView.contentHeight - taskListView.height, newContentY));
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    // --- OVERLAYS AND POPUPS ---

    Rectangle {
        id: statusMessage
        width: Math.min(parent.width - 40, 400); height: 60
        anchors.top: parent.top; anchors.horizontalCenter: parent.horizontalCenter
        anchors.topMargin: 20
        color: "#2D2D2D"; radius: 10; border.width: 2
        visible: false; z: 1000
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
            text: statusMessage.messageText; color: statusMessage.messageColor
            font.pointSize: 11; font.bold: true; wrapMode: Text.WordWrap
            width: parent.width - 20; horizontalAlignment: Text.AlignHCenter
        }

        Timer { id: hideTimer; interval: 4000; onTriggered: statusMessage.visible = false }
        MouseArea { anchors.fill: parent; onClicked: statusMessage.visible = false }
    }

    Rectangle {
        id: shortcutsOverlay
        anchors.fill: parent
        color: "transparent"; visible: false; opacity: 0.0; z: 2000

        function showShortcuts() {
            visible = true; opacity = 1.0; fadeOutTimer.start()
        }

        Behavior on opacity { NumberAnimation { duration: 1500; easing.type: Easing.OutCubic } }
        Timer { id: fadeOutTimer; interval: 7000; onTriggered: { shortcutsOverlay.opacity = 0.0 } }
        onOpacityChanged: { if (opacity <= 0.0 && visible) { Qt.callLater(() => shortcutsOverlay.visible = false) } }

        Rectangle {
            x: goalCircle.x + goalCircle.width / 2 - width / 2; y: goalCircle.y + goalCircle.height - 70
            width: 45; height: 30; color: "#2D2D2D"; border.color: "#F3C44A"; border.width: 1; radius: 4; opacity: shortcutsOverlay.opacity
            Text { text: "G"; anchors.centerIn: parent; color: "#F3C44A"; font.pointSize: 12 }
        }
        Rectangle {
            x: subGoalsContainer.x + subGoalsContainer.width / 2 - width / 2; y: subGoalsContainer.y + 25
            width: 50; height: 30; color: "#2D2D2D"; border.color: "#F3C44A"; border.width: 1; radius: 4; opacity: shortcutsOverlay.opacity
            Text { text: "1-9"; anchors.centerIn: parent; color: "#F3C44A"; font.pointSize: 12 }
        }
        Rectangle {
            x: addSubGoalButtonTop.x + addSubGoalButtonTop.width / 2 - width / 2; y: addSubGoalButtonTop.y - height
            width: 70; height: 30; color: "#2D2D2D"; border.color: "#F3C44A"; border.width: 1; radius: 4; opacity: shortcutsOverlay.opacity
            Text { text: "Shift+S"; anchors.centerIn: parent; color: "#F3C44A"; font.pointSize: 11 }
        }
        Rectangle {
            x: addTaskButton.x + addTaskButton.width / 2 - width / 4; y: addTaskButton.y + 460
            width: 70; height: 30; color: "#2D2D2D"; border.color: "#F3C44A"; border.width: 1; radius: 4; opacity: shortcutsOverlay.opacity
            Text { text: "Shift+T"; anchors.centerIn: parent; color: "#F3C44A"; font.pointSize: 11 }
        }
        Rectangle {
            x: dataMenuButton.x + dataMenuButton.width / 2 - width / 2; y: dataMenuButton.y - height
            width: 30; height: 30; color: "#2D2D2D"; border.color: "#F3C44A"; border.width: 1; radius: 4; opacity: shortcutsOverlay.opacity
            Text { text: "D"; anchors.centerIn: parent; color: "#F3C44A"; font.pointSize: 12 }
        }
        Rectangle {
            x: infoButton.x + infoButton.width / 2 - width / 2; y: infoButton.y - height
            width: 30; height: 30; color: "#2D2D2D"; border.color: "#F3C44A"; border.width: 0.5; radius: 4; opacity: shortcutsOverlay.opacity
            Text { text: "I"; anchors.centerIn: parent; color: "#F3C44A"; font.pointSize: 12 }
        }
        Rectangle {
            x: parent.width / 2 - 300; y: bottomSection.y + 30
            width: 150; height: 30; color: "#2D2D2D"; border.color: "#F3C44A"; border.width: 1; radius: 4; opacity: shortcutsOverlay.opacity
            Text { text: "X - done/undone"; anchors.centerIn: parent; color: "#F3C44A"; font.pointSize: 11 }
        }
        Rectangle {
            x: parent.width / 2 - width / 2; y: bottomSection.y + 30
            width: 220; height: 30; color: "#2D2D2D"; border.color: "#F3C44A"; border.width: 1; radius: 4; opacity: shortcutsOverlay.opacity
            Text { text: "Tab Shift+Tab / ↑ ↓ - Navigate"; anchors.centerIn: parent; color: "#F3C44A"; font.pointSize: 11 }
        }
        Rectangle {
            x: parent.width / 2 - 450; y: 50
            width: 150; height: 30; color: "#2D2D2D"; border.color: "#F3C44A"; border.width: 1; radius: 4; opacity: shortcutsOverlay.opacity
            Text { text: "Ctrl+S - Save"; anchors.centerIn: parent; color: "#F3C44A"; font.pointSize: 11 }
        }
        Rectangle {
            x: parent.width / 2 - 450; y: 90
            width: 150; height: 30; color: "#2D2D2D"; border.color: "#F3C44A"; border.width: 1; radius: 4; opacity: shortcutsOverlay.opacity
            Text { text: "F - Fullscreen"; anchors.centerIn: parent; color: "#F3C44A"; font.pointSize: 11 }
        }
        Rectangle {
            x: parent.width / 2 + 300; y: 50
            width: 150; height: 30; color: "#2D2D2D"; border.color: "#F3C44A"; border.width: 1; radius: 4; opacity: shortcutsOverlay.opacity
            Text { text: "Ctrl+Q - Quit"; anchors.centerIn: parent; color: "#F3C44A"; font.pointSize: 11 }
        }
    }

    Rectangle {
        id: splashScreen
        anchors.fill: parent; color: "#282828"
        visible: showSplashScreen; opacity: showSplashScreen ? 1.0 : 0.0; z: 10000

        Item {
            id: splashContainer
            anchors.centerIn: parent; width: 300; height: 300
            property real globalScale: 1.0; scale: globalScale
            SequentialAnimation on globalScale {
                running: splashScreen.visible && splashScreen.opacity > 0; loops: 1
                PauseAnimation { duration: 1500 }
                NumberAnimation { from: 1.0; to: 1.8; duration: 800; easing.type: Easing.OutCubic }
            }
            Rectangle {
                id: outerCircle
                width: 300; height: 300; radius: width / 2; color: "transparent"
                border.color: "#F3C44A"; border.width: 4; anchors.centerIn: parent; opacity: 0.6
                SequentialAnimation on scale {
                    running: splashScreen.visible && splashScreen.opacity > 0; loops: Animation.Infinite
                    NumberAnimation { from: 1.0; to: 1.15; duration: 800; easing.type: Easing.OutCubic }
                    NumberAnimation { from: 1.15; to: 1.0; duration: 800; easing.type: Easing.InCubic }
                }
                SequentialAnimation on opacity {
                    running: splashScreen.visible && splashScreen.opacity > 0; loops: Animation.Infinite
                    NumberAnimation { from: 0.6; to: 0.9; duration: 800; easing.type: Easing.OutCubic }
                    NumberAnimation { from: 0.9; to: 0.6; duration: 800; easing.type: Easing.InCubic }
                }
            }
            MultiEffect {
                id: outerCircleEffect
                source: outerCircle; anchors.fill: outerCircle; z: -1
                shadowEnabled: true; shadowOpacity: 0.8; shadowColor: "#F3C44A"
                shadowHorizontalOffset: 0; shadowVerticalOffset: 0; shadowBlur: 15.0
                property real blurAmount: 0.0; blurEnabled: true; blur: blurAmount
                SequentialAnimation on blurAmount {
                    running: splashScreen.visible && splashScreen.opacity > 0; loops: 1
                    PauseAnimation { duration: 1200 }
                    NumberAnimation { from: 0.0; to: 1.0; duration: 1100; easing.type: Easing.OutCubic }
                }
            }
            Rectangle {
                id: innerCircle
                width: 200; height: 200; radius: width / 2; color: "transparent"
                border.color: "#E95B5B"; border.width: 3; anchors.centerIn: parent; opacity: 0.5
                SequentialAnimation on scale {
                    running: splashScreen.visible && splashScreen.opacity > 0; loops: Animation.Infinite
                    PauseAnimation { duration: 400 }
                    NumberAnimation { from: 1.0; to: 1.2; duration: 800; easing.type: Easing.OutCubic }
                    NumberAnimation { from: 1.2; to: 1.0; duration: 800; easing.type: Easing.InCubic }
                }
                SequentialAnimation on opacity {
                    running: splashScreen.visible && splashScreen.opacity > 0; loops: Animation.Infinite
                    PauseAnimation { duration: 400 }
                    NumberAnimation { from: 0.5; to: 0.8; duration: 800; easing.type: Easing.OutCubic }
                    NumberAnimation { from: 0.8; to: 0.5; duration: 800; easing.type: Easing.InCubic }
                }
            }
            MultiEffect {
                id: innerCircleEffect
                source: innerCircle; anchors.fill: innerCircle; z: -1
                shadowEnabled: true; shadowOpacity: 0.7; shadowColor: "#E95B5B"
                shadowHorizontalOffset: 0; shadowVerticalOffset: 0; shadowBlur: 12.0
                property real blurAmount: 0.0; blurEnabled: true; blur: blurAmount
                SequentialAnimation on blurAmount {
                    running: splashScreen.visible && splashScreen.opacity > 0; loops: 1
                    PauseAnimation { duration: 1400 }
                    NumberAnimation { from: 0.0; to: 1.0; duration: 900; easing.type: Easing.OutCubic }
                }
            }
        }
        Behavior on opacity {
            NumberAnimation {
                duration: 500; easing.type: Easing.OutCubic
                onFinished: { if (splashScreen.opacity === 0) { showSplashScreen = false } }
            }
        }
        Timer {
            id: splashTimer; interval: 2000; running: true; repeat: false
            onTriggered: { splashScreen.opacity = 0.0 }
        }
    }
}
