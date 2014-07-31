import QtQuick 2.0

Rectangle {
    id: widget

    property string background: ""
    property string blurColor: blur ? background : ""
    property bool degrade: false
    property bool reflet: false
    property bool input: false
    property bool blur: false
    property string border: ""

    color: widget.background ? "#" + widget.background : "transparent"
    radius: 10
    smooth: true

    BorderImage {
        visible: widget.degrade
        border { top: 15; right: 15; bottom: 15; left: 15; }
        anchors {
            fill: parent
            margins: -5
        }
        asynchronous: true
        source: "std/fx_degrade.png"
    }

    BorderImage {
        visible: widget.reflet
        border { top: 15; right: 15; bottom: 15; left: 15; }
        anchors {
            fill: parent
            margins: -5
        }
        asynchronous: true
        source: "std/fx_reflet.png"
    }

    BorderImage {
        visible: widget.input
        border { top: 15; right: 15; bottom: 15; left: 15; }
        anchors {
            fill: parent
            margins: -5
        }
        asynchronous: true
        source: "std/fx_shadow_input.png"
    }

    BorderImage {
        visible: widget.blur
        border { top: 15; right: 15; bottom: 15; left: 15; }
        anchors {
            fill: parent
            margins: -5
        }
        asynchronous: true
        source: widget.blur ? ("std/blur_" + widget.blurColor + ".png") : ""
    }

    Rectangle {
        visible: widget.border != ""
        anchors {
            fill: parent
        }
        color: "transparent"
        border.color: widget.border ? "#" + widget.border : "transparent"
        border.width: 2
        radius: 10
        smooth: true
    }

}
