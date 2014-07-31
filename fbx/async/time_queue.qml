import QtQuick 2.0
import "time_queue.js" as Script

Timer {
    id: self

    running: true
    repeat: true

    function wait(timeout)
    {
        return Script.newTimeout(timeout);
    }

    property int granularity: 40

    onTriggered: {
        var next = Script.run();

        interval = Math.max(next - new Date().getTime(), granularity);
    }
}
