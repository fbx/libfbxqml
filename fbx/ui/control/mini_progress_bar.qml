import QtQuick 2.0

Item {
    property alias value: pb.value;
    property alias preloadValue: pb.preloadValue;
    property alias border: pb.border;
    property alias minimumValue: pb.minimumValue;
    property alias maximumValue: pb.maximumValue;
    property alias animDuration: pb.animDuration;

    implicitHeight: 30
    implicitWidth: 300

    ProgressBar {
        id: pb
        opacity: parent.enabled ? 1 : .4;

        anchors.centerIn: parent

        width: parent.width / (parent.height / 20.)
        height: 20.
        scale: parent.height / 20.

        border: true
    }
}
