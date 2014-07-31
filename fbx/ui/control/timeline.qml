import QtQuick 2.0

ProgressBar {
    id: widget;

    /*** Public API */

    property alias status: playerStatus.status;
    property string endTimeLabel: "";
    property string currentTimeLabel: "";
    property string nameLabel: "";

    // Inherited from ProgressBar:
    //   min, max, value, reset(), preloadValue

    /*** Private */

    Item {
        id: inner;
        anchors.fill: parent;
        anchors.margins: parent.margin;

        PlayerStatus {
            id: playerStatus;

            anchors.left: parent.left;
            anchors.leftMargin: 10;
            anchors.verticalCenter: parent.verticalCenter;
            height: parent.height / 2;
            width: parent.height / 2;
        }

        Text {
            id: name;

            anchors.left: playerStatus.right;
            anchors.leftMargin: 7;
            anchors.right: current.left;
            anchors.verticalCenter: parent.verticalCenter;

            text: widget.nameLabel;
            elide: Text.ElideRight;
            styleColor: "black";
            visible: widget.nameLabel != "";
            font.pixelSize: widget.height * .45;
            font.bold: true
            color: "white";
        }

        Text {
            id: current;

            anchors.right: sep.left;
            anchors.rightMargin: 7;
            anchors.verticalCenter: parent.verticalCenter;

            styleColor: "black";
            text: widget.currentTimeLabel;
            visible: widget.currentTimeLabel != "";
            font.pixelSize: widget.height * .45;
            font.bold: true
            color: "#ccc";
        }

        Text {
            id: sep;

            anchors.right: end.left;
            anchors.rightMargin: 7;
            anchors.verticalCenter: parent.verticalCenter;
            text: "|";
            visible: end.visible && current.visible;

            font.pixelSize: widget.height * .35;
            color: "#ccc";
        }

        Text {
            id: end;

            anchors.right: parent.right;
            anchors.rightMargin: 10;
            anchors.verticalCenter: parent.verticalCenter;

            styleColor: "black";
            text: widget.endTimeLabel;
            visible: widget.endTimeLabel != "";
            font.pixelSize: widget.height * .45;
            font.bold: true
            color: "white";
        }
    }
}
