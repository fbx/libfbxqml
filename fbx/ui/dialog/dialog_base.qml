import QtQuick 2.0
import fbx.ui.control 1.0

Frame {
    id: self

    objectName: "fbx.ui.dialog.DialogBase"
    property var buttons: ["OK"]
    property bool hasControls: false
    property bool focusControls: hasControls
    property int defaultButton: 0
    property bool modal: false

    property int tries: 0

    signal buttonSelected(int button);

    anchors.centerIn: parent

    function focusRow() {
        buttonRow.focus = true;
    }

    default property alias container: body.data

    opacity: 0
    Behavior on opacity { NumberAnimation { duration: 100 } }

    Column {
        spacing: 10
        height: body.height + spacing + buttonRow.height
        width: Math.max(body.width, buttonRow.width)

        FocusScope {
            id: body

            anchors.horizontalCenter: parent.horizontalCenter
            width: childrenRect.width
            height: childrenRect.height

            KeyNavigation.down: buttonRow
        }

        ListView {
            id: buttonRow
            focus: true
            model: self.buttons

            anchors.horizontalCenter: parent.horizontalCenter

            width: (oneWidth + spacing) * count - spacing
            height: 40

            property int oneWidth: 180

            interactive: false
            onActiveFocusChanged: {
                if (!activeFocus)
                    currentIndex = self.defaultButton;
            }

            currentIndex: self.defaultButton

            orientation: ListView.Horizontal
            onCurrentItemChanged: if (currentItem) currentItem.focus = true;

            delegate: Button {
                height: buttonRow.height
                width: buttonRow.oneWidth

                text: modelData
                onClicked: self.buttonSelected(index)
            }

            Keys.onPressed: {
                switch (event.key) {
                case Qt.Key_Up:
                    if (hasControls)
                        body.focus = true;
                    break;
                case Qt.Key_Left:
                    if (currentIndex > 0) {
                        event.accepted = true;
                        currentIndex--;
                    }
                    break;
                case Qt.Key_Right:
                    if (currentIndex + 1 < count) {
                        event.accepted = true;
                        currentIndex++;
                    }
                    break;
                }
            }
        }
    }

    Keys.onPressed: {
        switch (event.key) {
        case Qt.Key_Menu: {
            event.accepted = true;
            break;
        }
        case Qt.Key_Back:
        case Qt.Key_Escape: {
            event.accepted = true;
            if (!modal)
                self.buttonSelected(-1);
            break;
        }
        }
    }

    Component.onCompleted: {
        opacity = 1;
        if (focusControls)
            body.focus = true;
        else
            buttonRow.focus = true;
    }
}
