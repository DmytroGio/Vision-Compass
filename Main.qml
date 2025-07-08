import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import com.visioncompass.data 1.0

ApplicationWindow{
    id: mainWindow
    visible: true
    width: 800
    height: 750
    minimumWidth: 800
    maximumWidth: 800
    minimumHeight: 750
    maximumHeight: 750
    title: "Vision Compass (QML)"

    ColumnLayout {
        anchors.fill: parent
        spacing: 0


        // Top Section
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
                    ctx.arc(width/ 2, 0, radius / 2, 0, Math.PI, false);
                    ctx.closePath();
                    ctx.fillStyle = "#F3C44A";
                    ctx.fill();
                }
            }

            // Red Circle (Goal) - simple version
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
                        id: doalDesctiptionText
                        text: AppViewModel.currentGoalDescription
                        font.pointSize: 12
                        color: "white"
                        horizontalAlignment: Text.AlignHCenter
                        wrapMode: Text.WordWrap
                        width: goalCircle.width * 0.8
                    }
                }
            }

            // SubGoals with modern design
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


                    // SubGoals section header
                    Text {
                        text: "Sub Goals"
                        color: "#1E1E1E"
                        font.pointSize: 14
                        font.bold: true
                        Layout.alignment: Qt.AlignLeft
                    }

                    // Horizontal scroll for SubGoals
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

                                // Top color stripe
                                Rectangle {
                                    width: 4
                                    anchors.top: parent.top
                                    anchors.topMargin: 5
                                    anchors.horizontalCenter: parent.horizontalCenter
                                    color: "#F3C44A"
                                    radius: 2
                                }

                                // Main Content of SubGoal
                                RowLayout {
                                    anchors.fill: parent
                                    anchors.margins: 12
                                    spacing: 10
                                }

                                // SubGoal Icon
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

                                // SubGoal Text
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

                                // Delete Button
                                Rectangle {
                                    width: 25
                                    height: 25
                                    color: "#E95B5B"
                                    radius: 12

                                    Text {
                                        text: "x"
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

                            // Hover effect
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

        // SubGoal Delete Confirmation Dialog

    }
}






















