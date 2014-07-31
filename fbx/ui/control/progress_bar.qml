import QtQuick 2.0
import fbx.ui.base 1.0

Item {
    id: widget

    /*** Public interface */

    property int value: 0;
    property int minimumValue: 0;
    property int maximumValue: 100;
    property alias animDuration: main.animDuration

    property int preloadValue: 0;
    property bool border: false;

    property int margin: 6;

    implicitWidth: 300
    implicitHeight: 40

    /*** Private */

    function reset(value)
    {
        widget.value = value;
    }

    function mkRatio(x)
    {
        return (x - minimumValue + 0.) / (maximumValue - minimumValue);
    }

    StandardAsset {
        anchors.margins: widget.margin;
        anchors.fill: parent;
        background: "666666";
        reflet: true
    }

    ClippedBar {
        anchors.margins: widget.margin;
        anchors.fill: parent;
        color: "009900";
        ratio: mkRatio(preloadValue);
        reflet: true
     }

    ClippedBar {
        id: main;

        anchors.margins: widget.margin;
        anchors.fill: parent;
        color: "CC0000";
        ratio: mkRatio(value);
        reflet: true
    }

    StandardAsset {
        visible: widget.border;
        anchors.margins: widget.margin;
        anchors.fill: parent;
        border: "FFFFFF";
    }
}
