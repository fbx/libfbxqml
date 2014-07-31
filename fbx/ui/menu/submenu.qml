import QtQuick 2.0
import fbx.ui.control 1.0

Action {
    property var target
    text: target ? target.title : ""
    visible: !!target
    onClicked: push(target)
    rightMargin: 36
    close: false

    PlayerStatus {
        status: "play"
        anchors.right: parent.right
        anchors.rightMargin: 10
        anchors.verticalCenter: parent.verticalCenter
        height: 14
    }

    Keys.onPressed: {
        switch (event.key) {
        case Qt.Key_Right: {
            clicked();
            event.accepted = true;
        }
        }
    }
}
