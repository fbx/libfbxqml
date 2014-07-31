import QtQuick 2.0
import fbx.ui.controller 1.0

FocusScope {
    id: self

    property alias baseUrl: stack.baseUrl
    property alias duration: stack.duration
    property alias canPopRoot: stack.canPopRoot
    property alias depth: stack.depth
    property alias initialPage: stack.initialPage
    property alias titleList: stack.titleList
    property alias cacheSize: stack.cacheSize
    property alias count: stack.count
    property alias topSize: stack.topSize
    property alias tip: stack.tip

    property real ratio: .6

    function push(url, props, title)
    {
        return stack.push(url, props, title);
    }

    function popTo(index)
    {
        return stack.popTo(index);
    }

    function pop()
    {
        return stack.pop();
    }

    function replaceAt(index, url, props, title)
    {
        return stack.replaceAt(index, url, props, title);
    }

    function replace(url, props, title)
    {
        return stack.replace(url, props, title);
    }

    function pushMany(all)
    {
        return stack.pushMany(all);
    }

    function replaceAll(all)
    {
        return stack.replaceAll(all)
    }

    function parentStack(level)
    {
        return stack.parentStack(level)
    }

    function focusCompanionView()
    {
        return stack.focusCompanionView()
    }

    function focusMainView()
    {
        return stack.focusMainView()
    }

    function companionSwitchToUrl(url, args)
    {
        return stack.companionSwitchToUrl(url, args)
    }

    Stack {
        id: stack

        anchors {
            top: parent.top
            left: parent.left
            bottom: parent.bottom
        }
        width: parent.width * ((tip ? tip.ratio : 0) || parent.ratio)

        focus: true

        function companionSwitchToUrl(url, args)
        {
            return tm.switchToUrl(url, args, "fade");
        }

        function focusCompanionView()
        {
            console.debug("DetailedStack.focusCompanionView", tm.currentItem)

            if (tm.currentItem) {
                tm.focus = true;
                return true;
            }
            return false;
        }

        function focusMainView()
        {
            if (tm.currentItem && tm.activeFocus)
                stack.focus = true;
        }
    }

    Rectangle {
        z: 10
        anchors.fill: stack
        color: "#1F1F1F"
        opacity: stack.focus ? 0 : 0.75
        Behavior on opacity {NumberAnimation{}}
    }

    TransitionManager {
        id: tm

        onCurrentItemChanged: if (tm.focus) stack.focus = true

        anchors {
            top: parent.top
            left: stack.right
            leftMargin: 10
            bottom: parent.bottom
            right: parent.right
        }

        property Item compv: stack.tip && stack.tip.companionView || null
        onCompvChanged: tm.switchToItem(compv, "fade")

        Keys.onPressed: {
            switch (event.key) {
            case Qt.Key_Left:
            case Qt.Key_Escape:
            case Qt.Key_Back: {
                event.accepted = true;
                stack.focus = true;
                break;
            }
            }
            return;
        }
    }
}
