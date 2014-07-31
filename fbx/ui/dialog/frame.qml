import QtQuick 2.0

FocusScope {
    id: self

    property alias title: header.text
    default property alias contents: body.data

    width: body.width + 33 + 33
    height: body.height + 23 + 23 + 40 + 30

    children: [
        BorderImage {
            anchors.fill: parent

            asynchronous: true;
            border { top: 65; bottom: 23; left: 23; right: 23 }
            source: "dialog_background.png"
        },

        Text {
            id: header

            x: 33
            y: 23
            width: parent.width - 46
            height: 40

            text: "Dialogue"

            font {
                pixelSize: height * .7
                bold: true
            }

            clip: true
        },

        FocusScope {
            id: body

            x: 33
            y: 75
            width: childrenRect.width
            height: childrenRect.height
            focus: true
        }
    ]
}
