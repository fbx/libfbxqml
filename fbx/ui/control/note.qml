import QtQuick 2.3

Row {
    id: self
    property real value: 0;
    property string text: "Note"
    property string color: "#999999"
    property bool writeNote: true
    width: itemText.width + height * stars.maximumValue + numeric.width
    height: 20

    opacity: (value == 0) ? 0 : 1

    Behavior on opacity {NumberAnimation { duration: 150 }}

    spacing: 2

    Text {
        id: itemText

        anchors.verticalCenter: parent.verticalCenter

        font.pixelSize: 18
        font.bold:true
        color: self.color
        text: self.text + " : "
    }

    Stars {
        id: stars

        width: self.width - itemText.width - numeric.width - 4
        height: parent.height

        maximumValue: 5
        value: self.value
    }

    Text {
        id: numeric

        anchors.verticalCenter: parent.verticalCenter
        font.pixelSize: 18
        font.bold: true
        color: self.color
        text: writeNote ? ("(" + self.value + ")") : ""
    }
}
