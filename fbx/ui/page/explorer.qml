import QtQuick 2.0
import fbx.ui.controller 1.0
import fbx.async 1.0

FocusScope {
    id: self

    objectName: "fbx.ui.page.PageStack"

    property alias baseUrl: stack.baseUrl
    property int duration: 300

    property bool canPopRoot: false
    property alias depth: stack.count

    property alias tip: stack.leftItem

    property alias cachedPages: stack.topCount

    property string initialPage: ""
    property alias titleList: stack.titleList

    implicitWidth: parent ? parent.width : 0
    implicitHeight: parent ? parent.height : 0

    signal animationDone();

    function focusCompanionView()
    {
        if (stack.inProgress)
            throw Error("Animation in progress");
        if (!stack.rightItem)
            throw Error("No companion view to focus");
        if (stack.rightContainer)
            stack.rightContainer.focus = true;
    }

    function focusMainView()
    {
        if (stack.rightContainer && stack.rightContainer.activeFocus)
            stack.leftContainer.focus = true;
    }

    ComponentListModel {
        id: stack

        baseUrl: "./"
        cacheSize: 2

        property int lastCount: 0
        topCount: 3

        function getContainer(excludedContainer)
        {
            var containers = [container0, container1, container2, container3];

            for (var i = 0; i < 4; ++i) {
                var c = containers[i];
                if (c == excludedContainer)
                    continue;
                if (c == leftContainer)
                    continue;
                if (c == rightContainer)
                    continue;
                return c;
            }

            return null;
        }

        onUpdated: {
            inProgress = true;

            focusHolder.focus = true;

            var pushing = stack.count > lastCount;
            var popping = stack.count < lastCount;

            /* Items, some may already be present in explorer view */
            element(-1, objectPool).fail(function (err) {
                console.log("New component creation failed:", err);
                return null;
            }).then(function (nextItem) {
                var nextLeftContainer = getContainer();
                var nextRightContainer = getContainer(nextLeftContainer);

                var nextCompanion = null;
                var ratio = 1.;

                if (nextItem) {
                    nextItem.stack = self;
                    nextCompanion = nextItem.companionView;

                    /* Parenting and position */
                    nextItem.parent = nextLeftContainer.container;

                    if (nextCompanion) {
                        nextCompanion.parent = nextRightContainer.container;
                        ratio = nextItem.ratio === undefined ? .5 : nextItem.ratio;
                    }

                    nextLeftContainer.state = pushing ? "inright-noanim" : "outleft-noanim";
                    nextRightContainer.state = pushing ? "outright-noanim" : "inleft-noanim";
                    nextLeftContainer.ratio = ratio;
                    nextRightContainer.ratio = 1 - ratio;
                }

                /* Signals */
                if (nextItem && nextItem !== leftItem && nextItem !== rightItem) {
                    nextItem.willAppear();
                    newLeftItem = nextItem;
                }

                if (leftItem && leftItem !== nextItem && leftItem !== nextCompanion) {
                    leftItem.willDisappear();
                    oldLeftItem = leftItem;
                }

                /* Animation */
                nextLeftContainer.state = "inleft";
                nextRightContainer.state = "inright";
                if (leftContainer)
                    leftContainer.state = pushing ? "outleft" : "inright";
                if (rightContainer)
                    rightContainer.state = pushing ? "inleft" : "outright";

                /* Groundwork for next animation */

                leftContainer = nextLeftContainer;
                rightContainer = nextRightContainer;

                oldRightItem = rightItem;

                leftItem = nextItem;
                rightItem = nextCompanion || null;

                lastCount = stack.count;
                toggle = !toggle;
            }).then(function () {
                return tq.wait(self.duration);
            }).then(function () {
                if (!inProgress)
                    return;
                inProgress = false;

                if (leftItem)
                    leftItem.focus = true;

                if (rightItem)
                    rightItem.focus = true;

                if (leftContainer)
                    leftContainer.focus = true;

                if (oldLeftItem) {
                    oldLeftItem.parent = objectPool;
                    oldLeftItem.didDisappear();
                }

                if (oldRightItem) {
                    oldRightItem.parent = objectPool;
                }

                if (newLeftItem)
                    newLeftItem.didAppear();

                oldLeftItem = null;
                newLeftItem = null;

                self.animationDone();
                stack.cleanup();
            });
        }

        property bool toggle: false

        property var leftContainer
        property var rightContainer

        property var oldLeftItem
        property var newLeftItem
        property var oldRightItem
        property var leftItem
        property var rightItem

        property bool inProgress: false;
    }

    FocusScope {
        id: objectPool
        objectName: "objectPool"
        width: parent.width
        height: parent.height
        x: -parent.width
        opacity: 0
    }

    TimeQueue {
        id: tq
    }

    Item {
        id: focusHolder
        focus: true
    }

    function push(url, props, title)
    {
        if (stack.inProgress)
            throw "Transition in progress";

        if (props === undefined)
            props = {}

        stack.push(url, props, title);
    }

    function popTo(index)
    {
        if (stack.inProgress)
            throw "Transition in progress";

        if (!canPopRoot)
            index = Math.max(index, 0);

        stack.popTo(index);
    }

    function pushMany(all)
    {
        if (stack.inProgress)
            throw "Transition in progress";

        stack.pushMany(all);
    }

    function replaceAll(all)
    {
        if (stack.inProgress)
            throw "Transition in progress";

        stack.replaceAll(all)
    }

    function pop()
    {
        if (stack.inProgress)
            throw "Transition in progress";

        if (canPopRoot || stack.count > 1) {
            stack.pop();
        }
    }

    function replace(url, props, title)
    {
        if (stack.inProgress)
            throw "Transition in progress";

        if (props === undefined)
            props = {}

        stack.replace(url, props, title);
    }

    function replaceAt(index, url, props, title)
    {
        if (stack.inProgress)
            throw "Transition in progress";

        if (props === undefined)
            props = {}

        stack.replaceAt(index, url, props, title);
    }

    function parentStack(level)
    {
        var item = self;

        while (item) {
            if (level == 0)
                return item;

            while (item.parent) {
                item = item.parent;

                if (item && item.objectName != self.objectName)
                    break;
            }

            level--;
        }

        return null;
    }

    Frame {
        id: container0
        anchors.fill: parent
    }

    Frame {
        id: container1
        anchors.fill: parent
    }

    Frame {
        id: container2
        anchors.fill: parent
    }

    Frame {
        id: container3
        anchors.fill: parent
    }

    Keys.onPressed: {
        if (stack.rightContainer && stack.rightContainer.focus) {
            switch (event.key) {
            case Qt.Key_Left:
            case Qt.Key_Escape:
            case Qt.Key_Back: {
                event.accepted = true;
                if (stack.leftContainer && !stack.inProgress)
                    stack.leftContainer.focus = true;
                break;
            }
            }
            return;
        }

        switch (event.key) {
        case Qt.Key_Escape:
        case Qt.Key_Back: {
            if (stack.count <= (canPopRoot ? 0 : 1))
                return;
            event.accepted = true;
            pop();
        }
        }
    }

    Component.onCompleted: {
        if (initialPage)
            push(initialPage);
    }
}
