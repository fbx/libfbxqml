import QtQuick 2.0

QtObject {
    id: self

    property string format: "hh:mm"
    property string time: Qt.formatTime(getDate(now.time), format)

    property var now: Now {
        interval: (format.indexOf("s") >= 0) ? 1 : 60
    }

    function getDate(t)
    {
        var d = new Date();
        d.setTime(t * 1000);
        return d;
    }
}
