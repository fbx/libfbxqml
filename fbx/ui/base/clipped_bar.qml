import QtQuick 2.0

Item {
    id: outer;
    property real ratio: 0.;
    property alias color: bar.background;
    property alias degrade: bar.degrade;
    property alias reflet: bar.reflet;
    property int animDuration: 100

    onRatioChanged: {
        var animate = Math.abs(ratio - inner.ratio) < .1;

        if (animate) {
            smoothChange.to = ratio;
            smoothChange.duration = outer.animDuration;
            smoothChange.restart();
        } else {
            smoothChange.stop();
            inner.ratio = ratio;
        }
    }

    Item {
        id: inner
        clip: true;
        anchors.left: parent.left;
        anchors.top: parent.top;
        anchors.bottom: parent.bottom;

        width: outer.width * ratio;

        property real ratio: 0;

        NumberAnimation {
            id: smoothChange
            target: inner
            property: "ratio"
        }

        StandardAsset {
            id: bar;

            width: outer.width;
            degrade: true

            anchors {
                left: parent.left;
                top: parent.top;
                bottom: parent.bottom;
            }
        }
    }
}
