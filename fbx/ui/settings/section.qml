import QtQuick 2.0

Spacer {
    property alias text: label.text
    height: 60

    Text {
        id: label
        font.pixelSize: parent.height - 30
        color: "#888888"
        font.bold: true

        anchors.left: parent.left
        anchors.leftMargin: 20
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 10
    }
}
