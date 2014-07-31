import QtQuick 2.0

FocusScope {
    id: self

    signal animationFinished()

    property int duration: 300

    property var source
    property var destination

    function moveTo(dest, animated, dest_opacity) {
        if (self.destination) {
            self.source = self.destination;
            self.state = "0";
        }

        self.destination = dest;

        opacityAnimation.enabled = animated;
        self.opacity = dest_opacity;

        if (animated) {
            self.state = "1";
        } else {
            self.source = dest;
            self.state = "0";
        }
    }

    states: [
        State {
            name: "0"
            AnchorChanges {
                target: self
                anchors.top: source.top
                anchors.bottom: source.bottom
                anchors.left: source.left
                anchors.right: source.right
            }
        },
        State {
            name: "1"
            AnchorChanges {
                target: self
                anchors.top: destination.top
                anchors.bottom: destination.bottom
                anchors.left: destination.left
                anchors.right: destination.right
            }
        }
    ]

    transitions: Transition {
        from: "0"
        to: "1"
        SequentialAnimation {
            AnchorAnimation { duration: self.duration }
            ScriptAction { script: self.animationFinished() }
        }
    }

    Behavior on opacity {
        id: opacityAnimation
        NumberAnimation { duration: self.duration }
    }
}
