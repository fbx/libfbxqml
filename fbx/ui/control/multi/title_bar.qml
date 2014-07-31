import QtQuick 2.3

FocusScope {
    id: self

    implicitHeight: 53
    implicitWidth: 400

    property alias appIcon: icon.source
    property alias title: label.text

    Rectangle {
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        width: height + 20 + 32 + 20
        color: "white"
    }

    FocusScope {
        id : iconPart
        focus: true
        height: parent.height
        width: height + 20
        Image {
            id: icon
            anchors.horizontalCenter: parent.horizontalCenter
            height: parent.height
            width: height
        }
    }

    Item {
        id: item
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        anchors.left: iconPart.right
        anchors.right: parent.right
        height: parent.height
        width: 320

        BorderImage {
            border.left: 12
            height: parent.height
            width: parent.width
            source: "../../page/multi/breadcrumb/delegate.png"
        }
        Text {
            id: label
            anchors.fill: parent;
            anchors.rightMargin: 10;
            anchors.leftMargin: 24;
            elide: Text.ElideMiddle
            color: "black"
            verticalAlignment: Text.AlignVCenter
            font.pixelSize: 20
        }
    }
}
