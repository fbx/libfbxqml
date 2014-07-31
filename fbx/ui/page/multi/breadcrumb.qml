import QtQuick 2.3

FocusScope {
    id: self;

    property Item stack
    property alias appIcon: icon.source

    implicitHeight: 53

    Rectangle {
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        width: height + 20 + 32 + 20
        color: "white"
    }

    FocusScope {
        id : iconPart
        height: parent.height
        width: height + 20
        Image {
            id: icon
            anchors.horizontalCenter: parent.horizontalCenter
            height: parent.height
            width: height
        }
    }

    FocusScope {
        id: button
        focus: true
        anchors.left: iconPart.right
        height: parent.height
        width: 32
        Image {
            anchors.fill: parent
            function getSource() {
                var str = "breadcrumb/"
                if (listView.currentIndex == 0)
                    str += "none_"
                str += button.activeFocus ? "focused.png" : "blur.png"
                return str
            }
            source: getSource()
        }
        Keys.onReturnPressed: {
            self.stack.pop();
        }
        MouseArea {
            id: mouseArea
            anchors.fill: parent;
            onClicked: self.stack.pop();
            enabled: true
        }
    }

    ListView {
        id: listView
        delegate: itemDelegate
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        anchors.left: button.right
        anchors.right: parent.right
        property int cellWidth: 330
        orientation: ListView.Horizontal
        model: self.stack.titleList
        cacheBuffer: 10000
        signal vanish(int idx)
        onCountChanged: {
            currentIndex = count - 1;
            if (count > 1) {
                vanish(count - 2)
            }
        }
        highlightMoveDuration: 100

        function userSelected(index)
        {
            self.stack.popTo(index);
        }
    }

    Component {
        id: itemDelegate
        Item {
            id: itemDelegateC
            property int duration: 200
            property string pageTitle: model.title || " "
            visible: pageTitle != ""
            property int extendedWidth: ListView.view.cellWidth
            property bool isFocused: ListView.view.currentIndex == model.index
            height: parent.height
            width: 12

            Connections {
                target: listView
                onVanish: {
                    if (model.index != idx) return
                    vanishAnim.restart();
                }
            }
            onIsFocusedChanged: {
                if (isFocused) itemContent.width = extendedWidth
            }

            Component.onCompleted: {
                appearAnim.restart()
            }

            ParallelAnimation {
                id: appearAnim
                PropertyAnimation{target: itemContent; property:"x"; from: extendedWidth; to: 0; duration: itemDelegateC.duration}
                PropertyAnimation{target: itemContent; property:"opacity"; to: 1; duration: 50}
            }

            SequentialAnimation {
                id: vanishAnim
                PauseAnimation { duration: 40 }
                PropertyAnimation{target: itemContent; property:"width"; to: 32; duration: itemDelegateC.duration}
            }



            Item {
                id: itemContent
                opacity: 0
                width: extendedWidth
                height: parent.height
                Item {
                    id: containerForBg
                    clip: true
                    anchors.fill: parent
                    BorderImage {
                        border.left: 12
                        height: parent.height
                        width: itemDelegateC.extendedWidth
                        source: "breadcrumb/delegate.png"
                    }
                }

                Rectangle {
                    x: 4
                    height: 3
                    width: 3
                    color: "#AAAAAA"
                    anchors.verticalCenter: parent.verticalCenter
                    visible: model.index != 0
                }

                Text {
                    id: label
                    anchors.verticalCenter: parent.verticalCenter
                    x: 24
                    width: parent.width - 24 - 10
                    elide: Text.ElideRight
                    color: "black"
                    text: pageTitle
                    verticalAlignment: Text.AlignVCenter
                    font.pixelSize: 20
                }
            }
        }
    }
}
