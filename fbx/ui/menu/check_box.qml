import QtQuick 2.0
import fbx.ui.control 1.0

Entry {
    property alias exclusiveGroup: cb.exclusiveGroup
    property alias text: cb.text
    property alias value: cb.value
    property alias checked: cb.checked
    enabled: true

    signal clicked()

    CheckBox {
        focus: true
        id: cb
        enabled: parent.enabled
        __show_bg: false
        __bold: false
        anchors.fill: parent
        anchors.rightMargin: 16
        onClicked: parent.clicked()
    }
}
