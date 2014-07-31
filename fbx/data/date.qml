import QtQuick 2.0

QtObject {
    id: self

    property string format: "dddd dd/MM/yyyy"
    property string date

    property var t: Timer {
        id: timer
        interval: scheduleNext()
        running: true;
        repeat: true;

        onTriggered: {
            self.updateSelf();
            interval = scheduleNext();
        }
    }

    function updateSelf()
    {
        var d = new Date();

        date = Qt.formatDate(d, format);
    }

    function scheduleNext()
    {
        var d = new Date();

        // Schedule every hour to handle DST change days
        var seconds = d.getSeconds() + d.getMinutes() * 60
        var next = (3600 - seconds) * 1000 + 50;

        if (next <= 100)
            next = 100;

        return next;
    }

    Component.onCompleted: updateSelf()
}
