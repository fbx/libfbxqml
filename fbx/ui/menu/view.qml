import QtQuick 2.0
import fbx.ui.control 1.0
import fbx.ui.controller 1.0
import "view.js" as Priv

FocusScope {
    id: menu
    objectName: "fbx.ui.menu.View"

    property var returnFocusTo
    property var root

    anchors.top: parent.top
    anchors.bottom: parent.bottom
    anchors.left: parent.left
    width: 300

    anchors.leftMargin: (width + 100) * delta
    property real delta: activeFocus ? 0 : -1
    Behavior on delta { NumberAnimation { duration: 300; easing.type: Easing.InOutBack } }

    onDeltaChanged: {
        if (delta == -1)
            Priv.rewind();
    }

    function close()
    {
        returnFocusTo.focus = true;
    }

    function push(id)
    {
        Priv.push(id);
    }

    function pop()
    {
        return Priv.pop();
    }

    BorderImage {
        id: bg
        source: "background.png"
        anchors.leftMargin: -150
        anchors.rightMargin: -30
        anchors.fill: parent
        border { left: 31; right: 31; top: 0; bottom: 0 }
    }

    Rectangle {
        id: bgHeader
        color: "white"
        height: 40
        anchors {
            top: parent.top
            left: parent.left
            right: parent.right
        }
    }

    Text {
        id: titleLabel
        anchors.verticalCenter: bgHeader.verticalCenter
        anchors.left: parent.left
        anchors.leftMargin: 8
        anchors.right: parent.right
        anchors.rightMargin: 8
        font.pixelSize: bgHeader.height * 0.7
        font.capitalization: Font.AllUppercase
        font.bold: true
        color: "black"
        elide: Text.ElideRight
        text: tm.currentItem ? tm.currentItem.title : ""
    }

    Component.onCompleted: Priv.init()
    onRootChanged: Priv.resetRoot()

    TransitionManager {
        id: tm
        anchors {
            top: titleLabel.bottom
            topMargin: 12
            left: parent.left
            right: parent.right
            bottom: parent.bottom
            bottomMargin: 5
        }
        focus: true
        clip: true

        onDidSwitchItems: if (previousItem) previousItem.menu = null;
    }

    Keys.onPressed: {
        switch (event.key) {
        case Qt.Key_Left:
            event.accepted = true;
            Priv.pop();
            break;

        case Qt.Key_Escape:
        case Qt.Key_Back: {
            event.accepted = true;
            if (!Priv.pop())
                menu.close();
            break;
        }

        case Qt.Key_Menu:
        case Qt.Key_F2: {
            event.accepted = true;
            close();
        }
        }
    }

    function open(returnTo)
    {
        if (!returnTo && !returnFocusTo) {
            console.log("This will loose focus, please set a way back");
            return;
        }
        if (returnTo)
            returnFocusTo = returnTo;

        menu.focus = true;
    }
}
