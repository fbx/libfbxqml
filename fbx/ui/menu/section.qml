import QtQuick 2.0

Entry {
    property alias text: textItem.text
    height: 40

    Text {
        id: textItem
        color: "grey"
        font.bold: true
        font.pixelSize: parent.height * 0.6
        font.capitalization: Font.AllUppercase
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.rightMargin: 8
        elide: Text.ElideRight
    }
}
