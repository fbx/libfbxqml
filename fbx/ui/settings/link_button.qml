import QtQuick 2.0
import fbx.ui.control 1.0

Entry {
    id: self

    property string buttonText: "Appuyez sur OK"
    property string target

    signal clicked

    onClicked: if (target) push(target);

    Button {
        id: button

        focus: true

        text: enabled ? (buttonText + "   ") : "";
        implicitWidth: 250;
        __glow: false
        __bold: false
        __backgroundShown: enabled

        Keys.onRightPressed: clicked();

        onClicked: self.clicked()
    }

    property var ps: PlayerStatus {
        status: "play"
        parent: self
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        anchors.rightMargin: 15
        height: parent.height / 3
    }
}
