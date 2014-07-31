import QtQuick 2.0
import fbx.ui.base 1.0

FocusScope {
    id: self

    objectName: "fbx.ui.control.InputFrame"

    property string text: ""
    property bool solid: true
    property string bgColor: "cccccc"
    property alias color: promptText.color
    default property alias elements: row.children

    width: 285
    height: 45

    children: [
        StandardAsset {
            anchors.fill: parent
            anchors.margins: 2
            background: solid && self.activeFocus ? "ff0000" : self.bgColor
            border: self.activeFocus ? "ff0000" : "333333"
            degrade: self.activeFocus
            reflet: true
        },

        Text {
            id: promptText

            anchors.left: parent.left
            anchors.leftMargin: 10
            anchors.verticalCenter: parent.verticalCenter
            anchors.right: row.left

            font.pixelSize: 20
            color: "black"
            text: self.text ? (self.text + " :") : ""
        },

        FocusScope {
            id: row

            width: children && children[0].width || 0
            height: children && children[0].height || 0

            focus: true

            anchors.verticalCenter: parent.verticalCenter
            anchors.right: parent.right
            anchors.rightMargin: 10
        }
    ]
}
