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

        // --- Top Section (half of a large circle) ---
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

            // Red circle (Goal) - simplified version
            Rectangle {
                id: goalCircle
                width: topSection.height * 1 // Approximate size
                height: width
                radius: width / 2
                color: "#E95B5B" // Red color
                anchors.horizontalCenter: parent.horizontalCenter
                y: -height / 3 // Shift upwards to "clip"

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

            // Display SubGoals using Repeater
            Row {
                id: subGoalRow
                anchors.bottom: parent.bottom
                anchors.horizontalCenter: parent.horizontalCenter
                spacing: 20
                padding: 10

                Repeater {
                    model: AppViewModel.subGoalsListModel // Use data model

                    delegate: Rectangle {
                        width: 100
                        height: 50
                        radius: 10
                        color: "#F3C44A" // Yellow color
                        border.color: "gray"

                        Text {
                            text: modelData.name // Display SubGoal name
                            anchors.centerIn: parent
                            font.pointSize: 14
                            color: "black"
                        }

                        // SubGoal delete button (optional)
                        Button {
                            id: removeSubGoalButton
                            text: "X"
                            anchors.right: parent.right
                            anchors.top: parent.top
                            anchors.margins: 5
                            onClicked: {
                                // Show delete confirmation dialog
                                confirmationDialog.open()
                                confirmationDialog.subGoalToRemove = modelData
                            }
                        }
                    }
                }
            }

            // SubGoal delete confirmation dialog
            Dialog {
                id: confirmationDialog
                modal: true
                title: "Delete Confirmation"
                width: 300
                height: 150

                ColumnLayout {
                    anchors.fill: parent
                    spacing: 10
                    //padding: 10

                    Text {
                        text: "Are you sure you want to delete this sub-goal?"
                        font.pointSize: 14
                        color: "#373737"
                        horizontalAlignment: Text.AlignHCenter
                    }

                    RowLayout {
                        spacing: 10
                        Button {
                            text: "Yes"
                            onClicked: {
                                // Remove SubGoal from model
                                AppViewModel.removeSubGoal(confirmationDialog.subGoalToRemove)
                                confirmationDialog.close()
                            }
                        }
                        Button {
                            text: "No"
                            onClicked: {
                                confirmationDialog.close()
                            }
                        }
                    }
                }
            }

            // Add SubGoal dialog
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

            // Add SubGoal button (top right on yellow area)
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

        // --- Bottom Section (Tasks) ---
        Rectangle {
            id: bottomSection
            Layout.fillWidth: true
            Layout.fillHeight: true // Occupies remaining space
            color: "#282828" // Dark background for tasks

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 10

                Text {
                    text: "Sub-objective task list:"
                    color: "#373737"
                    font.pointSize: 12
                    Layout.alignment: Qt.AlignLeft
                }

                // ListView for tasks will be here
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

                // Add Task button (bottom center)
                Button {
                    id: addTaskButtonBottom
                    text: "+"
                    Layout.preferredWidth: 60
                    Layout.preferredHeight: 60
                    Layout.alignment: Qt.AlignHCenter
                    font.pointSize: 24
                    // onClicked: // Logic will be added later
                }
            }
        }
    }
}
