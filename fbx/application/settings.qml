import QtQuick 2.0
import "settings.js" as Priv

QtObject {
    id: self

    signal ready()

    property Timer _lazy: Timer {
        interval: 100
        onTriggered: Priv.save()
    }

    Component.onCompleted: {
        Priv.bind();
        Priv.load();
    }
    Component.onDestruction: Priv.save();

    property Connections _conn: Connections {
        target: App
        ignoreUnknownSignals: true
        onSettingsChanged: Priv.load();
    }
}
