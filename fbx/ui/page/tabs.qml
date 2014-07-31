import QtQuick 2.0
import fbx.ui.layout 1.0
import fbx.ui.controller 1.0

FocusScope {
    id: self

    property var model

    property alias baseUrl: tm.baseUrl
    property int currentIndex: -1
    property alias tip: tm.currentItem

    property var commonProperties: []

    TabList {
        id: tabs

        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right

        KeyNavigation.down: tm

        model: self.model

        onCurrentIndexChanged: {
            if (!activeFocus)
                self.currentIndex = currentIndex;
        }

        onSelected: {
            self.currentIndex = index;
        }

        onActiveFocusChanged: {
            if (!activeFocus)
                tabs.currentIndex = self.currentIndex;
        }
    }

    TransitionManager {
        id: tm

        focus: true

        KeyNavigation.up: tabs

        anchors.top: tabs.bottom
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.right: parent.right

        property int currentIndex: -1
        property int targetIndex: -1
        property int pending: 0

        function switchTo(index)
        {
            if (index == currentIndex || pending > 1)
                return;

            var animation = tm.currentIndex < index ? "slideLeft" : "slideRight";

            if (currentIndex == -1)
                animation = "appear";

            if (index == -1)
                animation = "fade";

            var info = model.get(index);
            var args = {};

            for (var k in info) {
                if (k == "url" || k.charAt(0) == "_")
                    continue;
                args[k] = info[k];
            }

            for (var k in commonProperties)
                args[k] = self[k];

            if (tm.currentItem)
                tm.currentItem.stack = null;

            if (pending) {
                animation = "fade";
                tm.duration = 50;
            } else {
                tm.duration = 300;
            }

            console.log("TM trying to switch from", currentIndex, "to", index, animation);
            pending = pending + 1;
            tm.switchToUrl(info.url, args, animation).both(function () {
                pending = pending - 1;
            }).then(function (x) {
                console.log("-> Tabs done switching to", index);
                tm.focus = true;
                try {
                    tm.currentItem.stack = self;
                } catch (e) {
                }
                tm.currentIndex = index;
            }, function(err) {
                console.log("Tab switching to", info.url, "failed:", err);
            });
        }

        onTargetIndexChanged: tm.switchTo(targetIndex);
        onCurrentIndexChanged: tm.switchTo(targetIndex);

        Keys.onPressed: {
            switch (event.key) {
            case Qt.Key_Left: {
                if (self.currentIndex < 1)
                    return;
                event.accepted = true;
                self.currentIndex--;
                break;
            }
            case Qt.Key_Right: {
                if (self.currentIndex >= tabs.count - 1)
                    return;
                event.accepted = true;
                self.currentIndex++;
                break;
            }
            }
        }
    }

    onCurrentIndexChanged: {
        tm.targetIndex = currentIndex;
        tabs.currentIndex = currentIndex;
    }

    Component.onCompleted: currentIndex = 0;
}
