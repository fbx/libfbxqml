import QtQuick 2.0
import fbx.ui.base 1.0

Restorable {
    id: page
    anchors.fill: parent

    /** Public API */

    // Accessor to current page stack
    property var stack
    property string title: ""

    // Signals display events
    signal willAppear()
    signal didAppear()
    signal willDisappear()
    signal didDisappear()

    function parentStack(level)
    {
        return stack.parentStack(level);
    }

    function push(url, properties) {
        return stack.push(url, properties);
    }

    function pop() {
        return stack.pop();
    }

    function replace(url, properties) {
        return stack.replace(url, properties);
    }
}
