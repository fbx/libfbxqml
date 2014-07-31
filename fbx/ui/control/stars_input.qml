import QtQuick 2.0

FocusScope {
    id: self

    implicitWidth: height * maximumValue
    implicitHeight: 16

    property alias value: stars.value
    property alias maximumValue: stars.maximumValue

    Stars {
        id: stars
        anchors.fill: parent
    }

    Item {
        focus: true

        Keys.onPressed: {
            switch (event.key) {
            case Qt.Key_Left: {
                event.accepted = true;
                self.value = Math.max(self.value - 1, 0)
                break;
            }

            case Qt.Key_Right: {
                event.accepted = true;
                self.value = Math.min(self.value + 1, maximumValue)
                break;
            }
            }
        }
    }
}
