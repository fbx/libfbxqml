import QtQuick 2.0
import fbx.async 1.0 as Async

QtObject {
    id: self

    property alias interval: timer.interval

    property Timer timer: Timer {
        id: timer
        interval: 1000
        onTriggered: timer.fetch()

        property bool wip: false

        function fetch()
        {
            if (wip)
                return;

            wip = true;

            try {
                self.poll().both(function (err) {
                    timer.restart();
                    wip = false;
                });
            } catch (e) {
                timer.restart();
                wip = false;
            }
        }
    }

    function reload()
    {
        if (timer.wip)
            return;

        timer.stop();
        timer.fetch()
    }

    Component.onCompleted: {
        timer.fetch()
    }

    function poll()
    {
        return Async.Deferred.rejected("No poller func");
    }
}
