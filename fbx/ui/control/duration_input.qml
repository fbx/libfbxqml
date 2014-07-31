import QtQuick 2.0
import fbx.ui.base 1.0

FocusScope {
    id: self

    implicitWidth: 120
    implicitHeight: 40

    property int minimumValue: 0
    property int maximumValue: 86400
    property int value: 3600

    signal done();

    onActiveFocusChanged: {
        if (!activeFocus)
            hour.focus = true;
    }

    NumericRangeInput {
        id: hour

        focus: true

        anchors {
            top: parent.top
            bottom: parent.bottom
            right: colon.left
        }

        width: 50

        minimumValue: parseInt(self.minimumValue / 3600)
        maximumValue: parseInt(self.maximumValue / 3600)

        KeyNavigation.right: minute

        onSelected: {
            self.setValues(hour.value, minute.value);
            minute.focus = true;
        }
    }

    Text {
        id: colon

        anchors {
            top: parent.top
            bottom: parent.bottom
            right: minute.left
        }

        color: "white"
        font.pixelSize: self.height * .7
        text: ":"
    }

    NumericRangeInput {
        id: minute

        anchors {
            top: parent.top
            bottom: parent.bottom
            right: parent.right
        }

        width: 50

        minimumValue: self.minimumValue < 3600
                    ? parseInt(self.minimumValue / 60)
                    : 60
        maximumValue: self.maximumValue < 3600
                    ? parseInt(self.maximumValue / 60)
                    : 60

        KeyNavigation.left: hour

        onSelected: {
            self.setValues(hour.value, minute.value);
            self.done();
        }
    }

    property bool __completed: false
    Component.onCompleted: { __completed = true; reloadValue() }
    onValueChanged: reloadValue()

    function reloadValue()
    {
        if (!__completed)
            return;

        var h = hour.value = parseInt(self.value / 3600);
        var m = minute.value = parseInt((self.value / 60) % 60);
    }

    function setValues(h, m)
    {
        self.value = h * 3600 + m * 60;
    }
}
