// CustomDialog.qml
import QtQuick
import QtQuick.Controls 2.15
import QtQuick.Layouts

Dialog {
    id: root

    // --- Public API ---
    // Title displayed in the dialog's header (optional)
    //property string customTitle: "Dialog"
    // Component to instantiate as the main content of the dialog
    property Component content: null
    // List of button configurations
    // Example: [{ text: "OK", color: "#F3C44A", textColor: "#1E1E1E", onClicked: function() { ... } }]
    property list<variant> buttons: []
    // Desired width for the dialog
    property int dialogWidth: 400

    // --- Configuration ---
    modal: true
    parent: Overlay.overlay
    anchors.centerIn: Overlay.overlay
    width: dialogWidth
    padding: 16

    // --- Internal Implementation ---

    // Focus management for keyboard input
    focus: true
    onOpened: {
        // Try to focus the first available input field in the content
        let contentItem = contentLoader.item;
        if (contentItem) {
            let textField = findFirstTextField(contentItem);
            if (textField) {
                textField.forceActiveFocus();
            }
        }
    }

    // Semi-transparent background overlay
    background: Rectangle {
        color: "#CC000000" // 80% transparent black
        radius: 10
        anchors.fill: parent
        anchors.margins: 5
    }

    // Main dialog panel
    contentItem: Rectangle {
        color: "#2D2D2D"
        radius: 10
        width: root.width
        // Height is determined by the content
        height: mainLayout.implicitHeight

        ColumnLayout {
            id: mainLayout
            width: parent.width
            anchors.margins: 20
            spacing: 20

            // 1. Title


            // 2. Dynamic Content
            Loader {
                id: contentLoader
                sourceComponent: root.content
                Layout.fillWidth: true
            }

            // 3. Buttons
            RowLayout {
                Layout.fillWidth: true
                spacing: 10
                visible: root.buttons.length > 0

                Repeater {
                    model: root.buttons
                    delegate: Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 40
                        // Use provided color or a default
                        color: modelData.color || "#3A3A3A"
                        radius: 8
                        // Initialize baseColor with the initial color, without binding
                        property color baseColor: modelData.color || "#3A3A3A"
                        property color hoverColor: Qt.lighter(baseColor, 1.2)

                        Text {
                            text: modelData.text || "Button"
                            anchors.centerIn: parent
                            // Use provided text color or a default
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
                                // Always close the dialog after a button click
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

    // Helper function to find the first text field to focus
    function findFirstTextField(item) {
        if (item && item instanceof TextField) {
            return item;
        }
        if (item && item.children) {
            for (var i = 0; i < item.children.length; ++i) {
                let result = findFirstTextField(item.children[i]);
                if (result) return result;
            }
        }
        return null;
    }
}
