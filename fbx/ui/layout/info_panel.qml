import QtQuick 2.0

FocusScope {
    id: widget

    anchors.right: parent.right
    anchors.bottom: parent.bottom
    anchors.left: parent.left
    height: 200
    property int limitOnTop: 0

    anchors.bottomMargin: (height + 8 + limitOnTop) * delta
    property bool shown: false
    property real delta: shown ? 0 : -1
    Behavior on delta { NumberAnimation { duration: 300; easing.type: Easing.InOutBack } }

    property alias background: bg.logo
    default property alias contents: container.data

    Background {
        id: bg
        background: "infopanel"
        logo: "info"
        logoRatio: .8
        anchors.topMargin: -8

        FocusScope {
            id: container
            width: parent.width
            height: parent.height + 8
            y: 8

            focus: true
        }
    }
}
