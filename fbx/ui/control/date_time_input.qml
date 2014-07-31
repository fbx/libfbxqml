import QtQuick 2.0
import fbx.ui.base 1.0

FocusScope {
    id: self

    implicitWidth: 340
    implicitHeight: 40

    property int value: -1
    property int minimumValue: new Date().getTime() / 1000
    property int maximumValue: minimumValue + 3600 * 24 * 7

    signal done();

    onActiveFocusChanged: {
        if (!activeFocus)
            day.focus = true;
    }

    DateInput {
        id: day
        minimumValue: self.minimumValue
        maximumValue: self.maximumValue
        focus: true
        anchors {
            top: parent.top
            bottom: parent.bottom
            left: parent.left
            right: fromLabel.left
        }
        KeyNavigation.right: time
        onDone: {
            self.setValues(day.value, time.value);
            time.focus = true;
        }
    }

    Text {
        id: fromLabel
        anchors {
            verticalCenter: parent.verticalCenter
            right: time.left
            rightMargin: 10
        }

        color: "white"
        font.pixelSize: self.height * .5
        text: "à"
    }

    TimeInput {
        id: time
        anchors {
            top: parent.top
            bottom: parent.bottom
            right: parent.right
        }
        KeyNavigation.left: day
        onActiveFocusChanged: hour.focus = true
        onValueChanged: self.setValues(day.value, time.value);
        onDone: self.done();
    }

    onMinimumValueChanged: reloadRange()
    onMaximumValueChanged: reloadRange()
    property bool __completed: false
    Component.onCompleted: { __completed = true; reloadRange(); reloadValue() }
    onValueChanged: reloadValue()

    function reloadRange()
    {
        if (!__completed)
            return;

        if (self.value < self.minimumValue)
            self.value = self.minimumValue;
        else if (self.value > self.maximumValue)
            self.value = self.maximumValue;

        reloadValue();
    }

    /* Make "Tomorrow" and other pretty dates follow current date. */
    Date {
        onDateChanged: self.reloadRange();
    }

    function reloadValue()
    {
        if (!__completed)
            return;

        var d = new Date();

        d.setTime(self.value * 1000);

        var h = d.getHours();
        var m = d.getMinutes();

        d.setHours(0); d.setMinutes(0); d.setSeconds(0); d.setMilliseconds(0);
        var base = d.getTime() / 1000;
        day.setValues(base);
        time.setValues(h, m)
    }

    function setValues(base, time)
    {
        self.value = base + time;
    }
}
