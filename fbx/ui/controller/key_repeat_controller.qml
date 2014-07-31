import QtQuick 2.0

Item {
    id: self

    property int key

    property int timeout: 500
    property int period: 50

    property bool pressed: false
    property int repeats: 0
    property int step: 0
    property int maximumStep: 3
    property int stepRepeats: 10

    signal event(bool pressed, int step);
    signal cleared();

    onStepChanged: repeats = 0;

    Keys.onPressed: {
        if (event.key != key)
            return;

        event.accepted = true;

        if (event.isAutoRepeat)
            return;

        timer.interval = self.timeout;
        self.pressed = true;
        self.event(true, self.step);
    }

    Keys.onReleased: {
        if (event.key != key)
            return;

        event.accepted = true;

        timer.interval = self.timeout;
        self.repeats = 0;
        self.pressed = false;
        self.event(false, self.step);
    }

    Timer {
        id: timer
        running: !!(self.pressed || self.step)
        repeat: true

        onTriggered: {
            if (pressed)
                interval = self.period;

            if (!pressed && self.step) {
                self.step = 0;
                self.cleared();
            } else {
                self.repeats++;

                if (self.repeats > self.stepRepeats && self.step < maximumStep)
                    self.step++;

                self.event(self.pressed, self.step);
            }
        }
    }
}
