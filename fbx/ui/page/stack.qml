import QtQuick 2.0
import fbx.ui.controller 1.0
import fbx.ui.layout 1.0

FocusScope {
    id: self

    objectName: "fbx.ui.page.Stack"

    property alias baseUrl: stack.baseUrl
    property alias duration: tm.duration

    property bool canPopRoot: false
    property int depth: 0

    property string initialPage: ""
    property string animation: "slideLeft";

    property alias titleList: stack.titleList
    property alias cacheSize: stack.cacheSize
    property alias count: stack.count
    property alias topSize: stack.topCount

    property var tip

    implicitWidth: parent ? parent.width : 0
    implicitHeight: parent ? parent.height : 0

    signal animationDone();

    ComponentListModel {
        id: stack

        baseUrl: "./"
        cacheSize: 1
        topCount: 2

        property int lastCount: 0

        onUpdated: {
            inProgress = true;

            var pushing = stack.count > lastCount;
            lastCount = stack.count;
            self.depth = stack.count;

            var anim = self.animation;
            if (!pushing)
                anim = tm.animationReverse(anim);

            if (stack.count == 1 && pushing)
                anim = "appear";

            stack.element(-1, objectPool).fail(function (err) {
                console.error("New component creation failed:", err);
                return null;
            }).then(function (el) {
                console.debug("switch to", el, anim);
                return tm.switchToItem(el, anim);
            }).both(function (x) {
                inProgress = false;
                self.animationDone();
                stack.cleanup();
            });
        }

        property bool inProgress: false

        Component.onCompleted: {
            if (self.initialPage)
                push(self.initialPage, {});
        }
    }

    TransitionManager {
        id: tm
        anchors.fill: parent

        onDidSwitchItems: {
            if (tm.previousItem)
                tm.previousItem.didDisappear();
            if (tm.currentItem)
                tm.currentItem.didAppear();
            tm.focus = true;
            self.tip = tm.currentItem;
            if (tm.currentItem)
                tm.currentItem.stack = self;
        }

        onWillSwitchItems: {
            if (tm.currentItem)
                tm.currentItem.stack = null;
            if (tm.nextItem)
                tm.nextItem.willAppear();
            if (tm.currentItem)
                tm.currentItem.willDisappear();
        }
    }

    FocusScope {
        id: objectPool
        width: parent.width
        height: parent.height
        enabled: false
        opacity: 0
        x: -width
    }

    function push(url, props, title)
    {
        if (props === undefined)
            props = {}
        stack.push(url, props, title);
    }

    function popTo(index)
    {
        if (!canPopRoot)
            index = Math.max(index, 0);

        stack.popTo(index);
    }

    function pop()
    {
        if (canPopRoot || stack.count > 1) {
            stack.pop();
        }
    }

    function replaceAt(index, url, props, title)
    {
        if (props === undefined)
            props = {}

        stack.replaceAt(index, url, props, title);
    }

    function replace(url, props, title)
    {
        if (props === undefined)
            props = {}

        stack.replace(url, props, title);
    }

    function pushMany(all)
    {
        stack.pushMany(all);
    }

    function replaceAll(all)
    {
        stack.replaceAll(all)
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

    Keys.onPressed: {
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
}
