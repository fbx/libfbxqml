import QtQuick 2.0
import fbx.ui.control 1.0
import fbx.ui.layout 1.0
import fbx.ui.page 1.0

FocusScope {
    id: view

    /** Public API */
    property alias initialPage: pageStack.initialPage
    property alias baseUrl: pageStack.baseUrl

    /** Private */

    property alias depth: pageStack.depth

    onDepthChanged: {
        if (!depth)
            pop();
        else
            pageStack.focus = true;
    }

    function push(x,y) { pageStack.push(x,y); }

    Background {
        background: "player"
        fillMode: Image.PreserveAspectCrop
    }

    Stack {
        id: pageStack
        focus: true

        anchors.top: title.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom

        Keys.onPressed: {
            if (event.key == Qt.Key_Up && !event.isAutoRepeat)
                title.focus = true;
        }
    }

    Breadcrumb {
        id: title

        z: 15

        stack: pageStack

        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right

        KeyNavigation.down: pageStack
    }
}
