import QtQuick 2.0

Item {
    id: self

    signal commit()
    property string value

    property alias timeout: timer.interval
    property alias typing: timer.running

    Timer {
        id: timer
        interval: 500

        function handleNum(n)
        {
            var cur = running ? self.value : "";

            self.value = cur + n;

            restart();
        }

        onTriggered: self.commit()
    }

    onCommit: timer.stop()

    function cancel()
    {
        timer.stop();
    }

    Keys.onPressed: {
        if (/^[0-9]+$/.test(event.text)) {
            timer.handleNum(event.text);
            event.accepted = true;
            return;
        }
    }
}
