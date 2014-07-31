import QtQuick 2.0

Item {
    objectName: "fbx.application.UiScaler"

    anchors.centerIn: parent

    property int uiHeight: 720

    width: parent.width / (parent.height / uiHeight)
    height: uiHeight
    scale: parent.height / uiHeight
}
