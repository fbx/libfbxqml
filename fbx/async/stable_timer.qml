import QtQuick 2.0

Timer {
    property int delay: 300
    interval: delay
    running: true

    signal stable;

    function touch()
    {
        interval = delay;
        restart();
        expired = false;
    }

    function force(value)
    {
        if (value === undefined)
            value = true;

        stop();
        expired = value;
    }

    property bool expired: false
    onTriggered: expired = true;
    onExpiredChanged: if (expired) stable();
}
