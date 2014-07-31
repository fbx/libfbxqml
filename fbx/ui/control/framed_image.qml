import QtQuick 2.0

FocusScope {
    id: self

    property alias label: labelText.text

    function mkRatio(h, n, d)
    {
        return (h - border * 2) * n / d + border * 2;
    }

    property int border: 10

    property alias source: img.source
    property alias progress: img.progress
    property alias color: bg.color
    property alias radius: bg.radius

    implicitWidth: bg.width
    implicitHeight: bg.height

    Rectangle {
        id: bg

        color: "black"
        radius: self.border

        anchors.centerIn: parent
        width: Math.min(
            self.width,
            mkRatio(parent.height, img.sourceSize.width, img.sourceSize.height))
        height: Math.min(
            self.height,
            mkRatio(parent.width, img.sourceSize.height, img.sourceSize.width)
            + labelText.height)
    }

    Loading {
        anchors.centerIn: img
        opacity: 1 - img.progress
        width: self.width / 4
        height: self.height / 4
    }

    Image {
        id: img

        anchors.centerIn: parent
        anchors.verticalCenterOffset: - labelText.height / 2

        width: parent.width - self.border * 2
        height: parent.height - self.border * 2 - labelText.height
        opacity: progress
        smooth: true

        asynchronous: true
        fillMode: Image.PreserveAspectFit
    }

    Text {
        id: labelText
        color: "white"
        anchors.bottom: bg.bottom
        anchors.bottomMargin: 4
        anchors.horizontalCenter: img.horizontalCenter
        horizontalAlignment: Text.AlignHCenter

        font.pixelSize: 18
        font.bold: true
        elide: Text.ElideRight

        width: img.paintedWidth
        height: text ? 20 : 0
    }
}
