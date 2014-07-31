import QtQuick 2.0

QtObject {
    id: self

    property int interval
    property int time

    property var t: Timer {
        id: timer
        interval: scheduleNext()
        running: true
        repeat: true
        onTriggered: {
            self.updateTime();
            interval = scheduleNext();
        }
    }

    onIntervalChanged: scheduleNext()

    function updateTime()
    {
        var d = new Date();

        self.time = d.getTime() / 1000;
    }

    function scheduleNext()
    {
        var d = new Date();
        var interval = self.interval * 1000;

        var next = (interval
            - ((d.getSeconds() * 1000 + d.getMilliseconds()) % interval)
            + 50);

        if (next <= 100)
            next = 100;

        return next;
    }

    Component.onCompleted: updateTime()
}
