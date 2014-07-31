import QtQuick 2.0
import fbx.ui.control 1.0
import fbx.ui.util 1.0

Flickable {
    id: widget

    property bool movingUp: false;
    property var currentItem;
    property int currentIndex: -1;
    property int highlightMoveDuration: 100;
    interactive: false;
    property int focusMargin: height / 5
    property var highlight

    default property alias elements: col.data

    function isUsable(item)
    {
        if (!item.visible)
            return false;
        if (item.width == 0 && item.height == 0)
            return false;
        return true;
    }

    /** Private */

    QtObject {
        id: priv

        property bool completed: false;

        function getItems(base)
        {
            var r = [];
            for (var i = 0; i < base.children.length; ++i) {
                var item = base.children[i];
                if (widget.isUsable(item))
                    r.push(item);
                else
                    r = r.concat(getItems(item));
            }
            return r;
        }

        function doHighlight(index)
        {
            if (!priv.completed)
                return false;

            var elems = getItems(col);

            if (elems.length == 0) {
                widget.contentY = 0;
                widget.returnToBounds();
                //console.log(widget, index, "No elements");
                currentIndex = -1;
                return false;
            } else if (index == -1 && currentIndex == -1) {
                index = 0;
            }

            if (index >= elems.length) {
                //console.log(widget, index, "After end");
                return false;
            }
            if (index < 0) {
                //console.log(widget, index, "Before start");
                return false;
            }

            var item = elems[index];

            highlightAnimation.follow = null;

            //console.log(widget, currentIndex, "->", index);

            item.focus = true;
            widget.movingUp = index < widget.currentIndex;
            widget.currentItem = item;
            widget.currentIndex = index;

            // widget.contentItem.mapFromItem(item, 0, 0) crashes,
            // silly workaround
            var y = widget.mapFromItem(item, 0, 0).y + widget.contentY
            var yend = y + item.height;
            var visibleHeight = widget.height;


            // Taking last focusable item bottom as scrollable height
            // is basically broken, but we have no usable total height
            // field available.

            // This will make non-interactive bottom of viewport
            // invisible (at least partly), but as position scrolls
            // with focus, this is defective by design anyway.
            var totalHeight = (widget.mapFromItem(elems[elems.length - 1], 0, 0).y
                + elems[elems.length - 1].height
                + widget.contentY);

            var dest = widget.contentY;

            if (widget.contentY > y - widget.focusMargin)
                dest = y - widget.focusMargin;
            else if (widget.contentY + visibleHeight < yend + widget.focusMargin)
                dest = yend - visibleHeight + widget.focusMargin;

            widget.contentY = Math.max(0, Math.min(totalHeight - visibleHeight, dest));
            highlightAnimation.follow = item;

            return true;
        }
    }

    children: [
        // Dont put this one in the column, keep it as acutal child on Scrollable
        Scrollbar {
            id: scrollbar
            anchors.right: widget.right
            anchors.top: widget.top
            anchors.topMargin: 5
            anchors.bottom: widget.bottom
            anchors.bottomMargin: 5
            width: 5
            widthRatio: parent.visibleArea.widthRatio
            heightRatio: parent.visibleArea.heightRatio
            xPosition: parent.visibleArea.xPosition
            yPosition: parent.visibleArea.yPosition
            autoHide: true
        }
    ]

    Keys.onPressed: {
        var delta = 0;

        switch (event.key) {
        case Qt.Key_Up: {
             event.accepted = priv.doHighlight(currentIndex - 1);
             break;
        }
        case Qt.Key_Down: {
             event.accepted = priv.doHighlight(currentIndex + 1);
             break;
        }
        }
    }

    Component.onCompleted: {
        priv.completed = true;
        priv.doHighlight(currentIndex)
    }
    onCurrentIndexChanged: priv.doHighlight(currentIndex)
    onContentHeightChanged: priv.doHighlight(currentIndex)
    onHeightChanged: priv.doHighlight(currentIndex)
    onVisibleChanged: priv.doHighlight(currentIndex)
    onActiveFocusChanged: priv.doHighlight(currentIndex)
    onHighlightChanged: {
        if (highlight) {
            highlight.parent = highlightItem;
        }
    }

    ChildWatcher {
        target: col
        onSomeChildrenChanged: priv.doHighlight(currentIndex)
    }

    Item {
        id: highlightItem
        x: 0
        y: 0
        visible: !!(currentItem && currentItem.activeFocus)
        width: widget.width
        height: highlightAnimation.follow ? highlightAnimation.follow.height : 0
    }

    // Behavior on highlightItem would have been easier, but racy as
    // QML wont ever recompute destination value y if its source is
    // also animated.  That means highlight may end up at a wrong
    // position if source object is animated.
    NumberAnimation {
        property var follow

        id: highlightAnimation
        duration: widget.highlightMoveDuration
        target: highlightItem
        property: "y"

        onFollowChanged: {
            stop();
            if (follow) {
                to = col.mapFromItem(follow, 0, 0).y;
                start();
            }
        }
    }

    Column {
        id: col
        width: widget.width
    }

    contentWidth: col.width
    contentHeight: col.height
}
