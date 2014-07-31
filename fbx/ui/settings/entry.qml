import QtQuick 2.0
import fbx.ui.base 1.0

FocusScope {
    id: self
    objectName: "fbx.ui.setting.Entry"

    property alias text: labelItem.text
    property string info: ""
    property bool enabled: true

    height: visible ? 56 : 0
    width: parent ? parent.width : 40

    default property alias controls: controlContainer.data
    property var control

    Behavior on height { NumberAnimation {} }

    children: [
        StandardAsset {
            id: back
            background: "333333"
            anchors.fill: container
            opacity: container.editing ? 1 : .4
        },

        Item {
            id: container

            opacity: self.enabled ? 1 : .3

            anchors.fill: parent
            anchors.margins: 2
            property bool editing: !!(control && control.editing)

            Text {
                id: labelItem

                anchors {
                    fill: parent
                    leftMargin: 10
                    rightMargin: placeholder.opacity ? placeholder.width : controlContainer.width
                }

                elide: Text.ElideRight
                font.pixelSize: container.height * .45
                font.bold: true
                color: "white"
                horizontalAlignment: Text.AlignLeft
                verticalAlignment: Text.AlignVCenter
            }

            Text {
                id: placeholder
                opacity: !self.activeFocus ? 1 : 0

                anchors {
                    top: container.top
                    right: container.right
                    bottom: container.bottom
                    rightMargin: 20
                }

                elide: Text.ElideLeft
                font.pixelSize: container.height * .45
                color: "grey"
                horizontalAlignment: Text.AlignRight
                verticalAlignment: Text.AlignVCenter
                text: control && control.displayText || ""
            }

            FocusScope {
                id: controlContainer
                opacity: 1 - placeholder.opacity

                focus: true

                anchors {
                    right: container.right
                    verticalCenter: container.verticalCenter
                    rightMargin: 1
                }

                width: childrenRect.width
                height: childrenRect.height

                onChildrenChanged: {
                    if (!children)
                        return;
                    children[0].focus = true;
                    self.control = children[0];
                }
            }
        }
    ]
}
