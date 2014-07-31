import QtQuick 2.0
import fbx.ui.base 1.0
import fbx.data 1.0

FocusScope {
    id: self

    implicitWidth: 300
    implicitHeight: 40

    property int value: -1
    property int minimumValue: new Date().getTime() / 1000
    property int maximumValue: minimumValue + 3600 * 24 * 7

    signal done();

    onActiveFocusChanged: {
        if (!activeFocus)
            day.focus = true;
    }

    Combo {
        id: day
        anchors.fill: parent
        items: ListModel {
            id: days
        }

        focus: true

        onSelected: {
            self.setValues(day.value);
            done();
        }
    }

    onMinimumValueChanged: reloadRange()
    onMaximumValueChanged: reloadRange()
    property bool __completed: false
    Component.onCompleted: { __completed = true; reloadRange(); reloadValue() }
    onValueChanged: reloadValue()


    function prettyDate(d)
    {
        if (!__completed)
            return;

        var day = new Date();
        day.setHours(0); day.setMinutes(0); day.setSeconds(0); day.setMilliseconds(0);

        if (d.getDate() == day.getDate()
            && d.getMonth() == day.getMonth()
            && d.getFullYear() == day.getFullYear())
            return "Aujourd'hui";

        day.setDate(day.getDate() + 1);

        if (d.getDate() == day.getDate()
            && d.getMonth() == day.getMonth()
            && d.getFullYear() == day.getFullYear())
            return "Demain";

        return Qt.formatDate(d, "ddd d MMM yyyy");
    }

    function reloadRange()
    {
        if (!__completed)
            return;

        days.clear();
        for (var i = self.minimumValue; i <= self.maximumValue; i += 3600 * 24) {
            var d = new Date();

            d.setTime(i * 1000);
            d.setHours(0); d.setMinutes(0); d.setSeconds(0); d.setMilliseconds(0);
            days.append({ label: prettyDate(d), value: d.getTime() / 1000 });
        }

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
        d.setHours(0); d.setMinutes(0); d.setSeconds(0); d.setMilliseconds(0);
        var base = d.getTime() / 1000;
        day.valueSet(base);
    }

    function setValues(base)
    {
        self.value = base;
    }
}
