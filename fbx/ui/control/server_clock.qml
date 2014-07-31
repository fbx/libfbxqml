import QtQuick 2.0
import fbx.data 1.0

Rectangle {
    id: clock
    color: "#80000000"
    clip: true

    Time {
        id: timer
        format: "hhmm"
        onTimeChanged: {
            hd.item.next = time.charAt(0);
            hu.item.next = time.charAt(1);
            md.item.next = time.charAt(2);
            mu.item.next = time.charAt(3);
        }
    }

    Loader {
        id: hd
        sourceComponent: letter
        width: parent.width * .475
        height: parent.height * .475
        anchors.bottom: parent.verticalCenter
        anchors.right: parent.horizontalCenter

        onLoaded: {
            item.outX = -1;
            item.inY = -1;
        }
    }

    Loader {
        id: hu
        sourceComponent: letter
        width: parent.width * .475
        height: parent.height * .475
        anchors.bottom: parent.verticalCenter
        anchors.left: parent.horizontalCenter

        onLoaded: {
            item.outX = 1;
            item.inY = -1;
        }
    }

    Loader {
        id: md
        sourceComponent: letter
        width: parent.width * .475
        height: parent.height * .475
        anchors.top: parent.verticalCenter
        anchors.right: parent.horizontalCenter

        onLoaded: {
            item.outX = -1;
            item.inY = 1;
        }
    }

    Loader {
        id: mu
        sourceComponent: letter
        width: parent.width * .475
        height: parent.height * .475
        anchors.top: parent.verticalCenter
        anchors.left: parent.horizontalCenter

        onLoaded: {
            item.outX = 1;
            item.inY = 1;
        }
    }

    Component {
        id: letter


        Item {
            id: item
            anchors.fill: parent

            Image {
                id: t

                x: parent.offsetX * parent.width
                y: parent.offsetY * parent.height
                width: parent.width * .9
                height: parent.height * .9
                property string text: "0"
                source: "clock/" + text + ((item.outX > 0 && text == "1") ? "_c" : "") + ".png"
            }

            property string next: ""
            onNextChanged: {
                if (t.text)
                    animation.restart();
                else
                    t.text = next;
            }

            property real offsetX: 0
            property real offsetY: 0

            property real outX: 0
            property real outY: 0

            property real inX: 0
            property real inY: 0

            SequentialAnimation {
                id: animation

                ParallelAnimation {
                    PropertyAnimation {
                        target: item
                        property: "offsetX"
                        to: item.outX
                        duration: 1000
                    }
                    PropertyAnimation {
                        target: item
                        property: "offsetY"
                        to: item.outY
                        duration: 1000
                    }
                }

                ScriptAction {
                    script: {
                        item.offsetX = item.inX
                        item.offsetY = item.inY
                        t.text = item.next
                    }
                }

                ParallelAnimation {
                    PropertyAnimation {
                        target: item
                        property: "offsetX"
                        to: 0
                        duration: 1000
                    }
                    PropertyAnimation {
                        target: item
                        property: "offsetY"
                        to: 0
                        duration: 1000
                    }
                }
            }
        }
    }
}
