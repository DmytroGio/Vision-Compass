import QtQuick
import QtQuick.Controls 2.15
import QtQuick.Layouts

Dialog {
    id: root

    // --- PUBLIC API ---
    property Component content: null
    property list<variant> buttons: []
    property int dialogWidth: 400
    property bool isLargeDialog: false

    // --- DIALOG CONFIGURATION ---
    modal: true
    parent: Overlay.overlay
    anchors.centerIn: Overlay.overlay
    width: dialogWidth
    height: contentColumn.implicitHeight + 100 // Add fixed height for padding and buttons
    padding: 0
    focus: true

    // --- LOGIC ---
    onOpened: {
        // Use callLater to ensure the content item is fully created and ready.
        Qt.callLater(function() {
            if (contentLoader.item) {
                // Search for the first TextInput within the loaded content to set focus.
                function findTextInput(item) {
                    if (item && typeof item.forceActiveFocus === "function" && item.toString().indexOf("TextInput") !== -1) {
                        return item;
                    }
                    if (item && item.children) {
                        for (var i = 0; i < item.children.length; i++) {
                            var result = findTextInput(item.children[i]);
                            if (result) return result;
                        }
                    }
                    return null;
                }

                var textInput = findTextInput(contentLoader.item);
                if (textInput) {
                    textInput.forceActiveFocus();
                    if (textInput.selectAll) {
                        textInput.selectAll();
                    }
                }
            }
        });
    }

    // --- UI STRUCTURE ---

    // Semi-transparent background overlay when the dialog is modal.
    Overlay.modal: Rectangle {
        color: "#80000000"
    }

    // Custom background for the dialog window.
    background: Rectangle {
        color: "#2D2D2D"
        radius: 10
        border.color: "#444444"
        border.width: 1
    }

    contentItem: Item {
        width: root.width
        height: root.height

        ColumnLayout {
            id: contentColumn
            anchors.fill: parent
            anchors.leftMargin: 40
            anchors.rightMargin: 40
            anchors.bottomMargin: 40
            anchors.topMargin: root.isLargeDialog ? 40 : 30
            spacing: isLargeDialog ? 10 : 20

            // Dynamic Content Area
            Loader {
                id: contentLoader
                sourceComponent: root.content
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignHCenter
            }

            // Buttons Area
            RowLayout {
                Layout.fillWidth: true
                spacing: 15
                visible: root.buttons.length > 0

                Repeater {
                    model: root.buttons
                    delegate: Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 40
                        color: modelData.color || "#3A3A3A"
                        radius: 8
                        property color baseColor: modelData.color || "#3A3A3A"
                        property color hoverColor: Qt.lighter(baseColor, 1.2)

                        Text {
                            text: modelData.text || "Button"
                            anchors.centerIn: parent
                            color: modelData.textColor || "#FFFFFF"
                            font.pointSize: 12
                            font.bold: true
                        }

                        MouseArea {
                            anchors.fill: parent
                            hoverEnabled: true
                            onClicked: {
                                if (modelData.onClicked) {
                                    modelData.onClicked();
                                }
                                root.close();
                            }
                            onEntered: parent.color = parent.hoverColor
                            onExited: parent.color = parent.baseColor
                        }
                    }
                }
            }
        }
    }
}
