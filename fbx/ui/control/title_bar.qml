import QtQuick 2.0

Item {
    id: self

    implicitHeight: 40
    implicitWidth: 200

    Image {
        anchors.fill: parent
        source: "../page/breadcrumb/background.png"
    }

    property string highlight: "last"
    property string text: ""
    property alias showClock: clock.visible

    Item {
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        anchors.left: parent.left

        width: self.text == "" ? 0 : Math.min(label.implicitWidth, 500) + 30

        BorderImage {
            anchors.left: label.left
            width: label.implicitWidth + 62
            anchors.leftMargin: -31
            border {
                left: 20
                right: 20
            }
            smooth: true
            source: "../page/breadcrumb/" + self.highlight + ".png"

            Behavior on width { NumberAnimation { duration: 100 } }
        }

        Text {
            id: label
            anchors.fill: parent
            anchors.rightMargin: 30
            anchors.leftMargin: 10
            verticalAlignment: Text.AlignVCenter

            text: self.text
            color: getColor(highlight)

            function getColor(hc)
            {
                if (hc == "last")
                    return "white";
                return "#333"
            }

            font {
                pixelSize: label.height / 2
                capitalization: Font.AllUppercase
                bold: true
            }
        }
    }

    Image {
        id: clock
        anchors.top: parent.top
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        width: visible ? 120 : 0

        source: "../page/breadcrumb/background.png"

        CurrentTime {
            opacity: 0.7

            anchors.centerIn: parent

            font.pixelSize: parent.height - 5
            font.bold: true

            color: "black"
        }
    }
}
