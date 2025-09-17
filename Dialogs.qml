import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import com.visioncompass 1.0

Item {
    id: dialogsRoot

    property alias confirmationDialog: confirmationDialog
    property alias addSubGoalDialog: addSubGoalDialog
    property alias editSubGoalDialog: editSubGoalDialog
    property alias taskConfirmationDialog: taskConfirmationDialog
    property alias addTaskDialog: addTaskDialog
    property alias editTaskDialog: editTaskDialog
    property alias editGoalDialog: editGoalDialog
    property alias dataManagementDialog: dataManagementDialog
    property alias clearDataConfirmDialog: clearDataConfirmDialog
    property alias infoDialog: infoDialog

    // Dialog for confirming SubGoal deletion
    CustomDialog {
        id: confirmationDialog
        dialogWidth: 350
        property var subGoalToRemove: null

        content: Component {
            ColumnLayout {
                spacing: 15

                Text {
                    text: "Delete SubGoal"
                    color: "#FFFFFF"
                    font.pointSize: 14
                    font.weight: Font.Normal
                    Layout.alignment: Qt.AlignHCenter
                }

                Text {
                    text: "This action cannot be undone."
                    font.pointSize: 11
                    color: "#AAAAAA"
                    horizontalAlignment: Text.AlignHCenter
                    Layout.fillWidth: true
                    wrapMode: Text.WordWrap
                }
            }
        }

        buttons: [
            {
                text: "Delete",
                color: "#2D2D2D",
                textColor: "#CCCCCC",
                onClicked: function() {
                    if (confirmationDialog.subGoalToRemove) {
                        AppViewModel.removeSubGoal(confirmationDialog.subGoalToRemove);
                    }
                }
            },
            {
                text: "Cancel",
                color: "#444444",
                textColor: "#FFFFFF"
            }
        ]
    }

    // Dialog for adding a new SubGoal
    CustomDialog {
        id: addSubGoalDialog
        dialogWidth: 550

        onOpened: {
            if (contentLoader.item) {
                contentLoader.item.forceActiveFocus()
            }
        }

        content: Component {
            ColumnLayout {
                spacing: 20

                Text {
                    text: "Add SubGoal"
                    color: "#FFFFFF"
                    font.pointSize: 14
                    font.weight: Font.Normal
                    Layout.alignment: Qt.AlignHCenter
                }

                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 40
                    color: "#323232"
                    radius: 6
                    border.color: "#555555"
                    border.width: 1

                    TextInput {
                        id: subGoalNameInput
                        anchors.fill: parent
                        anchors.margins: 12
                        anchors.rightMargin: 60 // Место для счетчика
                        color: "#FFFFFF"
                        font.pointSize: 11
                        verticalAlignment: TextInput.AlignVCenter
                        selectByMouse: true
                        clip: true
                        maximumLength: 45

                        onAccepted: {
                            if (text.trim() !== "" && text.length <= 45) {
                                AppViewModel.addSubGoal(text.trim());
                                text = "";
                                addSubGoalDialog.close();
                            }
                        }
                    }

                    Text {
                        text: "Enter sub-goal name..."
                        color: "#888888"
                        font.pointSize: 11
                        anchors.left: parent.left
                        anchors.leftMargin: 12
                        anchors.verticalCenter: parent.verticalCenter
                        visible: subGoalNameInput.text.length === 0
                    }

                    Text {
                        text: subGoalNameInput.length + "/45"
                        color: subGoalNameInput.length >= 45 ? "#E95B5B" : "#AAAAAA"
                        font.pointSize: 9
                        anchors.right: parent.right
                        anchors.rightMargin: 12
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }
            }
        }

        buttons: [
            {
                text: "Add",
                color: "#444444",
                textColor: "#FFFFFF",
                onClicked: function() {
                    if (addSubGoalDialog.contentItem && addSubGoalDialog.contentItem.children.length > 0) {
                        let contentLoader = addSubGoalDialog.contentItem.children[0].children[0];
                        if (contentLoader && contentLoader.item) {
                            let textInput = contentLoader.item.children[1].children[0];
                            if (textInput && textInput.text && textInput.text.trim() !== "" && textInput.text.length <= 45) {
                                AppViewModel.addSubGoal(textInput.text.trim());
                                textInput.text = "";
                                addSubGoalDialog.close();
                            }
                        }
                    }
                }
            },
            {
                text: "Cancel",
                color: "#2D2D2D",
                textColor: "#AAAAAA"
            }
        ]
    }

    // Dialog for editing a SubGoal
    CustomDialog {
        id: editSubGoalDialog
        dialogWidth: 550
        property var subGoalToEdit: null

        function openForEditing(itemData) {
            subGoalToEdit = itemData;
            open();
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
                spacing: 20

                Text {
                    text: "Edit SubGoal"
                    color: "#FFFFFF"
                    font.pointSize: 14
                    font.weight: Font.Normal
                    Layout.alignment: Qt.AlignHCenter
                }

                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 40
                    color: "#323232"
                    radius: 6
                    border.color: "#555555"
                    border.width: 1

                    TextInput {
                        id: editSubGoalNameInput
                        anchors.fill: parent
                        anchors.margins: 12
                        anchors.rightMargin: 60
                        color: "#FFFFFF"
                        font.pointSize: 11
                        verticalAlignment: TextInput.AlignVCenter
                        selectByMouse: true
                        clip: true
                        text: editSubGoalDialog.subGoalToEdit ? (editSubGoalDialog.subGoalToEdit.name || "") : ""
                        maximumLength: 45

                        onAccepted: {
                            if (text.trim() !== "" && editSubGoalDialog.subGoalToEdit && text.length <= 45) {
                                AppViewModel.editSubGoal(editSubGoalDialog.subGoalToEdit.id, text.trim());
                                editSubGoalDialog.close();
                            }
                        }
                    }

                    Text {
                        text: "Enter sub-goal name..."
                        color: "#888888"
                        font.pointSize: 11
                        anchors.left: parent.left
                        anchors.leftMargin: 12
                        anchors.verticalCenter: parent.verticalCenter
                        visible: editSubGoalNameInput.text.length === 0
                    }

                    Text {
                        text: editSubGoalNameInput.length + "/45"
                        color: editSubGoalNameInput.length >= 45 ? "#E95B5B" : "#AAAAAA"
                        font.pointSize: 9
                        anchors.right: parent.right
                        anchors.rightMargin: 12
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }
            }
        }

        buttons: [
            {
                text: "Save",
                color: "#444444",
                textColor: "#FFFFFF",
                onClicked: function() {
                    if (editSubGoalDialog.contentItem && editSubGoalDialog.contentItem.children.length > 0) {
                        let contentLoader = editSubGoalDialog.contentItem.children[0].children[0];
                        if (contentLoader && contentLoader.item) {
                            let textInput = contentLoader.item.children[1].children[0];
                            if (textInput && textInput.text && textInput.text.trim() !== "" && editSubGoalDialog.subGoalToEdit && textInput.text.length <= 45) {
                                AppViewModel.editSubGoal(editSubGoalDialog.subGoalToEdit.id, textInput.text.trim());
                                editSubGoalDialog.close();
                            }
                        }
                    }
                }
            },
            {
                text: "Cancel",
                color: "#2D2D2D",
                textColor: "#AAAAAA"
            }
        ]
    }

    // Dialog for confirming Task deletion
    CustomDialog {
        id: taskConfirmationDialog
        dialogWidth: 350
        property var taskToRemove: null

        content: Component {
            ColumnLayout {
                spacing: 15

                Text {
                    text: "Delete Task"
                    color: "#FFFFFF"
                    font.pointSize: 14
                    font.weight: Font.Normal
                    Layout.alignment: Qt.AlignHCenter
                }

                Text {
                    text: "This action cannot be undone."
                    font.pointSize: 11
                    color: "#AAAAAA"
                    horizontalAlignment: Text.AlignHCenter
                    Layout.fillWidth: true
                    wrapMode: Text.WordWrap
                }
            }
        }

        buttons: [
            {
                text: "Delete",
                color: "#2D2D2D",
                textColor: "#CCCCCC",
                onClicked: function() {
                    if (taskConfirmationDialog.taskToRemove) {
                        AppViewModel.removeTask(taskConfirmationDialog.taskToRemove);
                    }
                }
            },
            {
                text: "Cancel",
                color: "#444444",
                textColor: "#FFFFFF"
            }
        ]
    }

    // Dialog for adding a new Task
    CustomDialog {
        id: addTaskDialog
        dialogWidth: 550

        content: Component {
            ColumnLayout {
                spacing: 20

                Text {
                    text: "Add Task"
                    color: "#FFFFFF"
                    font.pointSize: 14
                    font.weight: Font.Normal
                    Layout.alignment: Qt.AlignHCenter
                }

                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 40
                    color: "#323232"
                    radius: 6
                    border.color: "#555555"
                    border.width: 1

                    TextInput {
                        id: taskNameInput
                        anchors.fill: parent
                        anchors.margins: 12
                        anchors.rightMargin: 60
                        color: "#FFFFFF"
                        font.pointSize: 11
                        verticalAlignment: TextInput.AlignVCenter
                        selectByMouse: true
                        clip: true
                        maximumLength: 75

                        onAccepted: {
                            if (text.trim() !== "" && text.length <= 75) {
                                AppViewModel.addTask(text.trim());
                                text = "";
                                addTaskDialog.close();
                            }
                        }
                    }

                    Text {
                        text: "Enter task name..."
                        color: "#888888"
                        font.pointSize: 11
                        anchors.left: parent.left
                        anchors.leftMargin: 12
                        anchors.verticalCenter: parent.verticalCenter
                        visible: taskNameInput.text.length === 0
                    }

                    Text {
                        text: taskNameInput.length + "/75"
                        color: taskNameInput.length >= 75 ? "#E95B5B" : "#AAAAAA"
                        font.pointSize: 9
                        anchors.right: parent.right
                        anchors.rightMargin: 12
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }
            }
        }

        buttons: [
            {
                text: "Add",
                color: "#444444",
                textColor: "#FFFFFF",
                onClicked: function() {
                    if (addTaskDialog.contentItem && addTaskDialog.contentItem.children.length > 0) {
                        let contentLoader = addTaskDialog.contentItem.children[0].children[0];
                        if (contentLoader && contentLoader.item) {
                            let textInput = contentLoader.item.children[1].children[0];
                            if (textInput && textInput.text && textInput.text.trim() !== "" && textInput.text.length <= 75) {
                                AppViewModel.addTask(textInput.text.trim());
                                textInput.text = "";
                                addTaskDialog.close();
                            }
                        }
                    }
                }
            },
            {
                text: "Cancel",
                color: "#2D2D2D",
                textColor: "#AAAAAA"
            }
        ]
    }

    // Dialog for editing a Task
    CustomDialog {
        id: editTaskDialog
        dialogWidth: 550
        property var taskToEdit: null

        function openForEditing(itemData) {
            taskToEdit = itemData;
            open();
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
                spacing: 20

                Text {
                    text: "Edit Task"
                    color: "#FFFFFF"
                    font.pointSize: 14
                    font.weight: Font.Normal
                    Layout.alignment: Qt.AlignHCenter
                }

                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 40
                    color: "#323232"
                    radius: 6
                    border.color: "#555555"
                    border.width: 1

                    TextInput {
                        id: editTaskNameInput
                        anchors.fill: parent
                        anchors.margins: 12
                        anchors.rightMargin: 60
                        color: "#FFFFFF"
                        font.pointSize: 11
                        verticalAlignment: TextInput.AlignVCenter
                        selectByMouse: true
                        clip: true
                        text: editTaskDialog.taskToEdit ? (editTaskDialog.taskToEdit.name || "") : ""
                        maximumLength: 75

                        onAccepted: {
                            if (text.trim() !== "" && editTaskDialog.taskToEdit && text.length <= 75) {
                                AppViewModel.editTask(editTaskDialog.taskToEdit.id, text.trim());
                                editTaskDialog.close();
                            }
                        }
                    }

                    Text {
                        text: "Enter task name..."
                        color: "#888888"
                        font.pointSize: 11
                        anchors.left: parent.left
                        anchors.leftMargin: 12
                        anchors.verticalCenter: parent.verticalCenter
                        visible: editTaskNameInput.text.length === 0
                    }

                    Text {
                        text: editTaskNameInput.length + "/75"
                        color: editTaskNameInput.length >= 75 ? "#E95B5B" : "#AAAAAA"
                        font.pointSize: 9
                        anchors.right: parent.right
                        anchors.rightMargin: 12
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }
            }
        }

        buttons: [
            {
                text: "Save",
                color: "#444444",
                textColor: "#FFFFFF",
                onClicked: function() {
                    if (editTaskDialog.contentItem && editTaskDialog.contentItem.children.length > 0) {
                        let contentLoader = editTaskDialog.contentItem.children[0].children[0];
                        if (contentLoader && contentLoader.item) {
                            let textInput = contentLoader.item.children[1].children[0];
                            if (textInput && textInput.text && textInput.text.trim() !== "" && editTaskDialog.taskToEdit && textInput.text.length <= 75) {
                                AppViewModel.editTask(editTaskDialog.taskToEdit.id, textInput.text.trim());
                                editTaskDialog.close();
                            }
                        }
                    }
                }
            },
            {
                text: "Cancel",
                color: "#2D2D2D",
                textColor: "#AAAAAA"
            }
        ]
    }

    // Dialog for editing the main Goal
    CustomDialog {
        id: editGoalDialog
        dialogWidth: 550

        content: Component {
            ColumnLayout {
                spacing: 20

                Text {
                    text: "Edit Main Goal"
                    color: "#FFFFFF"
                    font.pointSize: 14
                    font.weight: Font.Normal
                    Layout.alignment: Qt.AlignHCenter
                }

                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 40
                    color: "#323232"
                    radius: 6
                    border.color: "#555555"
                    border.width: 1

                    TextInput {
                        id: editGoalNameInput
                        objectName: "goalNameInput"
                        anchors.fill: parent
                        anchors.margins: 12
                        anchors.rightMargin: 60
                        color: "#FFFFFF"
                        font.pointSize: 11
                        verticalAlignment: TextInput.AlignVCenter
                        selectByMouse: true
                        clip: true
                        text: AppViewModel.currentGoalText
                        maximumLength: 45

                        onAccepted: {
                            if (text.trim() !== "" && editGoalDescriptionInput.text.trim() !== "" && text.length <= 45 && editGoalDescriptionInput.text.length <= 135) {
                                AppViewModel.setMainGoal(text.trim(), editGoalDescriptionInput.text.trim());
                                editGoalDialog.close();
                            }
                        }

                        Keys.onTabPressed: {
                            editGoalDescriptionInput.forceActiveFocus();
                            editGoalDescriptionInput.selectAll();
                        }
                    }

                    Text {
                        text: "Enter main goal name..."
                        color: "#888888"
                        font.pointSize: 11
                        anchors.left: parent.left
                        anchors.leftMargin: 12
                        anchors.verticalCenter: parent.verticalCenter
                        visible: editGoalNameInput.text.length === 0
                    }

                    Text {
                        text: editGoalNameInput.length + "/45"
                        color: editGoalNameInput.length >= 45 ? "#E95B5B" : "#AAAAAA"
                        font.pointSize: 9
                        anchors.right: parent.right
                        anchors.rightMargin: 12
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }

                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 40
                    color: "#323232"
                    radius: 6
                    border.color: "#555555"
                    border.width: 1

                    TextInput {
                        id: editGoalDescriptionInput
                        objectName: "goalDescInput"
                        anchors.fill: parent
                        anchors.margins: 12
                        anchors.rightMargin: 70
                        color: "#FFFFFF"
                        font.pointSize: 11
                        verticalAlignment: TextInput.AlignVCenter
                        selectByMouse: true
                        clip: true
                        text: AppViewModel.currentGoalDescription
                        maximumLength: 135

                        onAccepted: {
                            if (text.trim() !== "" && editGoalNameInput.text.trim() !== "" && text.length <= 135 && editGoalNameInput.text.length <= 45) {
                                AppViewModel.setMainGoal(editGoalNameInput.text.trim(), text.trim());
                                editGoalDialog.close();
                            }
                        }

                        Keys.onTabPressed: {
                            editGoalNameInput.forceActiveFocus();
                            editGoalNameInput.selectAll();
                        }
                    }

                    Text {
                        text: "Enter description or target date..."
                        color: "#888888"
                        font.pointSize: 11
                        anchors.left: parent.left
                        anchors.leftMargin: 12
                        anchors.verticalCenter: parent.verticalCenter
                        visible: editGoalDescriptionInput.text.length === 0
                    }

                    Text {
                        text: editGoalDescriptionInput.length + "/135"
                        color: editGoalDescriptionInput.length >= 135 ? "#E95B5B" : "#AAAAAA"
                        font.pointSize: 9
                        anchors.right: parent.right
                        anchors.rightMargin: 12
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }
            }
        }

        buttons: [
            {
                text: "Save",
                color: "#444444",
                textColor: "#FFFFFF",
                onClicked: function() {
                    let contentItem = editGoalDialog.contentItem;
                    let layout = contentItem.children[0];
                    let loader = layout.children[0];
                    let contentLayout = loader.item;

                    let nameRect = contentLayout.children[1];
                    let descRect = contentLayout.children[2];

                    let nameField = nameRect.children[0];
                    let descField = descRect.children[0];

                    if (nameField && descField && nameField.text.trim() !== "" && descField.text.trim() !== "" && nameField.text.length <= 45 && descField.text.length <= 135) {
                        AppViewModel.setMainGoal(nameField.text, descField.text);
                        editGoalDialog.close();
                    }
                }
            },
            {
                text: "Cancel",
                color: "#2D2D2D",
                textColor: "#AAAAAA"
            }
        ]
    }

    // Data Management Dialog
    CustomDialog {
        id: dataManagementDialog
        dialogWidth: 420
        isLargeDialog: true

        content: Component {
            ColumnLayout {
                spacing: 25

                Text {
                    text: "Data"
                    color: "#FFFFFF"
                    font.pointSize: 16
                    font.weight: Font.Normal
                    Layout.alignment: Qt.AlignHCenter
                }

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 15
                    Layout.bottomMargin: 15

                    // Save Section
                    Rectangle {
                        Layout.fillWidth: true
                        height: 60
                        color: "#323232"
                        radius: 8
                        border.color: "#444444"
                        border.width: 1

                        RowLayout {
                            anchors.fill: parent
                            anchors.margins: 18
                            spacing: 0

                            Rectangle {
                                width: 6
                                height: 6
                                color: "#BBBBBB"
                                radius: 3
                                Layout.alignment: Qt.AlignVCenter
                            }

                            ColumnLayout {
                                Layout.fillWidth: true
                                Layout.alignment: Qt.AlignVCenter
                                Layout.leftMargin: 15
                                spacing: 2

                                Text {
                                    text: "Create backup file"
                                    color: "#AAAAAA"
                                    font.pointSize: 10
                                    Layout.alignment: Qt.AlignHCenter
                                }
                            }

                            Rectangle {
                                Layout.preferredWidth: 60
                                Layout.preferredHeight: 28
                                Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
                                color: "#444444"
                                radius: 4

                                Text {
                                    text: "Save"
                                    anchors.centerIn: parent
                                    color: "#FFFFFF"
                                    font.pointSize: 10
                                }

                                MouseArea {
                                    anchors.fill: parent
                                    onClicked: {
                                        dataManagementDialog.close()
                                        mainWindow.exportData()
                                    }
                                    hoverEnabled: true
                                    onEntered: parent.color = "#555555"
                                    onExited: parent.color = "#444444"
                                }
                            }
                        }
                    }

                    // Load Section
                    Rectangle {
                        Layout.fillWidth: true
                        height: 60
                        color: "#323232"
                        radius: 8
                        border.color: "#444444"
                        border.width: 1

                        RowLayout {
                            anchors.fill: parent
                            anchors.margins: 18
                            spacing: 0

                            Rectangle {
                                width: 6
                                height: 6
                                color: "#BBBBBB"
                                radius: 3
                                Layout.alignment: Qt.AlignVCenter
                            }

                            ColumnLayout {
                                Layout.fillWidth: true
                                Layout.alignment: Qt.AlignVCenter
                                Layout.leftMargin: 15
                                spacing: 2

                                Text {
                                    text: "Restore from backup file"
                                    color: "#AAAAAA"
                                    font.pointSize: 10
                                    Layout.alignment: Qt.AlignHCenter
                                }
                            }

                            Rectangle {
                                Layout.preferredWidth: 60
                                Layout.preferredHeight: 28
                                Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
                                color: "#444444"
                                radius: 4

                                Text {
                                    text: "Load"
                                    anchors.centerIn: parent
                                    color: "#FFFFFF"
                                    font.pointSize: 10
                                }

                                MouseArea {
                                    anchors.fill: parent
                                    onClicked: {
                                        dataManagementDialog.close()
                                        mainWindow.importData()
                                    }
                                    hoverEnabled: true
                                    onEntered: parent.color = "#555555"
                                    onExited: parent.color = "#444444"
                                }
                            }
                        }
                    }

                    // Clear Data Section
                    Rectangle {
                        Layout.fillWidth: true
                        height: 60
                        color: "#323232"
                        radius: 8
                        border.color: "#444444"
                        border.width: 1

                        RowLayout {
                            anchors.fill: parent
                            anchors.margins: 18
                            spacing: 0

                            Rectangle {
                                width: 6
                                height: 6
                                color: "#BBBBBB"
                                radius: 3
                                Layout.alignment: Qt.AlignVCenter
                            }

                            ColumnLayout {
                                Layout.fillWidth: true
                                Layout.alignment: Qt.AlignVCenter
                                Layout.leftMargin: 15
                                spacing: 2

                                Text {
                                    text: "Clear all data (irreversible)"
                                    color: "#AAAAAA"
                                    font.pointSize: 10
                                    Layout.alignment: Qt.AlignHCenter
                                }
                            }

                            Rectangle {
                                Layout.preferredWidth: 60
                                Layout.preferredHeight: 28
                                Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
                                color: "#2D2D2D"
                                radius: 4
                                border.color: "#555555"
                                border.width: 1

                                Text {
                                    text: "Reset"
                                    anchors.centerIn: parent
                                    color: "#CCCCCC"
                                    font.pointSize: 10
                                }

                                MouseArea {
                                    anchors.fill: parent
                                    onClicked: {
                                        clearDataConfirmDialog.open()
                                    }
                                    hoverEnabled: true
                                    onEntered: {
                                        parent.color = "#3A3A3A"
                                        parent.border.color = "#666666"
                                    }
                                    onExited: {
                                        parent.color = "#2D2D2D"
                                        parent.border.color = "#555555"
                                    }
                                }
                            }
                        }
                    }
                }

                // Open Folder Button
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 40 // Такая же высота как кнопка Close
                    color: "#383838"
                    radius: 10

                    Text {
                        text: "📁"
                        anchors.centerIn: parent
                        color: "#FFFFFF"
                        font.pointSize: 14
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            Qt.openUrlExternally("file:///" + AppViewModel.getDefaultDataPath())
                        }
                        hoverEnabled: true
                        onEntered: {
                            parent.color = "#484848"
                        }
                        onExited: {
                            parent.color = "#383838"
                        }
                    }
                }

            }
        }

        buttons: [
            {
                text: "Close",
                color: "#444444",
                textColor: "#FFFFFF"
            }
        ]
    }

    // Clear Data Confirmation Dialog
    CustomDialog {
        id: clearDataConfirmDialog
        dialogWidth: 380

        content: Component {
            ColumnLayout {
                spacing: 20

                Text {
                    text: "Reset All Data"
                    color: "#FFFFFF"
                    font.pointSize: 14
                    font.weight: Font.Normal
                    Layout.alignment: Qt.AlignHCenter
                }

                Text {
                    text: "This will permanently delete all your goals, sub-goals, and tasks."
                    color: "#FFFFFF"
                    font.pointSize: 11
                    Layout.fillWidth: true
                    wrapMode: Text.WordWrap
                    horizontalAlignment: Text.AlignHCenter
                }

                Text {
                    text: "This action cannot be undone."
                    color: "#AAAAAA"
                    font.pointSize: 10
                    Layout.fillWidth: true
                    horizontalAlignment: Text.AlignHCenter
                }
            }
        }

        buttons: [
            {
                text: "Reset",
                color: "#2D2D2D",
                textColor: "#CCCCCC",
                onClicked: function() {
                    AppViewModel.clearAllData();
                    dataManagementDialog.close();
                }
            },
            {
                text: "Cancel",
                color: "#444444",
                textColor: "#FFFFFF"
            }
        ]
    }

    // Info Dialog
    CustomDialog {
        id: infoDialog
        dialogWidth: 480
        isLargeDialog: true

        content: Component {
            ColumnLayout {
                spacing: 30

                Text {
                    text: "Vision Compass"
                    color: "#FFFFFF"
                    font.pointSize: 16
                    font.weight: Font.Normal
                    Layout.alignment: Qt.AlignHCenter
                }

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 18
                    Layout.bottomMargin: 30

                    // Main Goal Section
                    Rectangle {
                        Layout.fillWidth: true
                        height: 70
                        color: "#323232"
                        radius: 8
                        border.color: "#E95B5B"
                        border.width: 1

                        RowLayout {
                            anchors.fill: parent
                            anchors.margins: 18
                            spacing: 18

                            Rectangle {
                                width: 8
                                height: 8
                                color: "#CCCCCC"
                                radius: 4
                                Layout.alignment: Qt.AlignVCenter
                            }

                            ColumnLayout {
                                Layout.fillWidth: true
                                Layout.alignment: Qt.AlignVCenter
                                spacing: 3

                                Text {
                                    text: "Main Goal"
                                    color: "#FFFFFF"
                                    font.pointSize: 11
                                    font.weight: Font.Medium
                                }

                                Text {
                                    text: "Your primary objective (1-10+ years)"
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
                        color: "#323232"
                        radius: 8
                        border.color: "#F3C44A"
                        border.width: 1

                        RowLayout {
                            anchors.fill: parent
                            anchors.margins: 18
                            spacing: 18

                            Rectangle {
                                width: 8
                                height: 8
                                color: "#CCCCCC"
                                radius: 4
                                Layout.alignment: Qt.AlignVCenter
                            }

                            ColumnLayout {
                                Layout.fillWidth: true
                                Layout.alignment: Qt.AlignVCenter
                                spacing: 3

                                Text {
                                    text: "SubGoals"
                                    color: "#FFFFFF"
                                    font.pointSize: 11
                                    font.weight: Font.Medium
                                }

                                Text {
                                    text: "Major milestones (3 months - 1 year)"
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
                        color: "#323232"
                        radius: 8
                        border.color: "#707070"
                        border.width: 1

                        RowLayout {
                            anchors.fill: parent
                            anchors.margins: 18
                            spacing: 18

                            Rectangle {
                                width: 8
                                height: 8
                                color: "#CCCCCC"
                                radius: 4
                                Layout.alignment: Qt.AlignVCenter
                            }

                            ColumnLayout {
                                Layout.fillWidth: true
                                Layout.alignment: Qt.AlignVCenter
                                spacing: 3

                                Text {
                                    text: "Tasks"
                                    color: "#FFFFFF"
                                    font.pointSize: 11
                                    font.weight: Font.Medium
                                }

                                Text {
                                    text: "Actionable steps (1 day - 3 months)"
                                    color: "#AAAAAA"
                                    font.pointSize: 10
                                    wrapMode: Text.WordWrap
                                    Layout.fillWidth: true
                                }
                            }
                        }
                    }
                }

                Rectangle {
                    Layout.fillWidth: true
                    height: 40
                    color: "#F3C44A"
                    radius: 6

                    Text {
                        text: "Shortcuts"
                        anchors.centerIn: parent
                        color: "#2D2D2D"
                        font.pointSize: 11
                        font.bold: true
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            infoDialog.close()
                            mainWindow.showShortcuts()
                        }
                        hoverEnabled: true
                        onEntered: parent.color = "#F5D96B"
                        onExited: parent.color = "#F3C44A"
                    }
                }
            }
        }

        buttons: [
            {
                text: "Close",
                color: "#444444",
                textColor: "#FFFFFF"
            }
        ]
    }
}
