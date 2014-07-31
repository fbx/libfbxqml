import QtQuick 2.0
import "child_watcher.js" as Script

QtObject {
    id: self

    property var target

    signal someChildrenChanged

    property var watchedProperties: ["enabled", "visible", "parent"]

    Component.onCompleted: Script.start()
    onWatchedPropertiesChanged: Script.restart()
    onTargetChanged: Script.restart()
}
