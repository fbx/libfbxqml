import QtQuick 2.0

FocusScope {
    id: widget

    /*** Public interface */

    implicitHeight: 40
    implicitWidth: 135

    property bool checked: true
    enabled: true

    focus: true;

    signal clicked();

    property string displayText: checked ? "Oui" : "Non";

    /*** Private */

    Image {
        smooth: true
        anchors.fill: parent
        fillMode: Image.PreserveAspectFit
        source: "switch/" + (checked ? "yes.png" : "no.png");

        Text {
            color: widget.checked ? "gray" : "white"
            text: "Non";
            visible: !widget.checked || ((widget.activeFocus || mouse.containsMouse) && widget.enabled)
            font.pixelSize: widget.height / 2.7
            font.bold: true
            font.capitalization: Font.AllUppercase
            anchors.verticalCenter: parent.verticalCenter
            anchors.right: parent.horizontalCenter;
            anchors.rightMargin: parent.height * .4
            horizontalAlignment: Text.AlignRight
        }

        Text {
            color: widget.checked ? "white" : "gray"
            text: "Oui";
            visible: widget.checked || ((widget.activeFocus || mouse.containsMouse) && widget.enabled)
            font.pixelSize: widget.height / 2.7
            font.bold: true
            font.capitalization: Font.AllUppercase
            anchors.verticalCenter: parent.verticalCenter
            anchors.left: parent.horizontalCenter;
            anchors.leftMargin: parent.height * .4
            horizontalAlignment: Text.AlignLeft
        }

        MouseArea {
            id: mouse
            anchors.fill: parent
            enabled: widget.enabled;
            hoverEnabled: widget.enabled;
            onPressed: widget.toggle();
        }
    }

    Keys.onReturnPressed: widget.toggle();
    Keys.onEnterPressed: widget.toggle();

    Keys.onPressed: {
        if (!widget.enabled)
            return;

        switch (event.key) {
        case Qt.Key_Right: {
            if (widget.checked)
                return;
            widget.checked = true;
            widget.clicked();
            event.accepted = true;
            return;
        }
        case Qt.Key_Left: {
            if (!widget.checked)
                return;
            widget.checked = false;
            widget.clicked();
            event.accepted = true;
            return;
        }
        }
    }

    function toggle() {
        if (!widget.enabled)
            return;

        widget.checked = !widget.checked;
        widget.clicked();
    }
}
