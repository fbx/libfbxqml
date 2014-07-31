import QtQuick 2.0
import fbx.ui.control 1.0

DialogBase {
    id: self;

    property alias text: label.text
    property var label: label
    buttons: ["OK"]

    title: "Alerte"

    property var _sizer: Text {
        id: sizer
        opacity: 0
        font: label.font
        text: label.text
    }

    Text {
        id: label

        width: (sizer.width > 800) ? 800 : sizer.width

        font.pixelSize: 20

        color: "white"
        text: ""
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        wrapMode: Text.Wrap
    }
}
