import QtQuick 2.0
import fbx.ui.base 1.0

FocusToggler {
    id: widget
    implicitWidth: 200
    implicitHeight: 40

    property var value: null;
    property var originalValue: null
    onOriginalValueChanged: {
        valueSet(originalValue)
    }

    signal selected(int index, variant value);

    property alias items: listView.model
    property int surroundingElementCount: 2
    property string displayText: listView.currentIndex >= 0 && listView.currentIndex < items.count
             ? items.get(listView.currentIndex).label
             : ""

    function valueSet(v)
    {
        for (var i = 0; i < items.count; ++i) {
            if (items.get(i).value == v) {
                if (v != value)
                    value = v;
                listView.currentIndex = i;
                return;
            }
        }

        listView.currentIndex = -1;
        value = null;
    }

    onValueChanged: if (value != null) {
                        valueSet(value);
                    }

    onEditingChanged: {
        if (editing) {
            listView.originalIndex = listView.currentIndex;
        } else {
            selectionTimer.start();
        }
    }

    // Hacky timer to ensure correct item is viewed when unfocusing the
    // object through external means.
    Timer {
        id: selectionTimer;
        interval: 40;
        onTriggered: listView.ensureCorrectHighlight(false)
    }

    StandardAsset {
        anchors.fill: listView;
        anchors.rightMargin: -8
        anchors.leftMargin: -3
        anchors.topMargin: -3
        anchors.bottomMargin: -3
        background: "000000";
        visible: listView.height > widget.height
    }

    Scrollbar {
        id: scrollbar
        anchors.right: listView.right
        anchors.topMargin: 5
        anchors.bottomMargin: 5
        anchors.top: listView.top
        anchors.bottom: listView.bottom
        width: 4
        heightRatio: 1 / items.count
        yPosition: listView.currentIndex / items.count
        color: "#333333"
        cursor.color: "red"
        visible: listView.activeFocus
    }

    control: listView;

    ListView {
        id: listView
        delegate: delegateComp
        interactive: false
        snapMode: ListView.SnapOneItem;

        clip: true;

        property int span: (height - widget.height) / 2
        preferredHighlightBegin: 0
        preferredHighlightEnd: height - 2;

        onCountChanged: {
            if (count) {
                if (originalValue)
                    valueSet(originalValue)
                else
                    valueSet(model.get(0).value)
            }
        }

        keyNavigationWraps: true
        anchors.top: parent.top
        anchors.topMargin: 0
        anchors.left: parent.left
        width: parent.width
        height:  (activeFocus
                 ? (Math.min(listView.model.count, widget.surroundingElementCount * 2 + 1)
                     * widget.height - 1)
                 : widget.height)

        highlightRangeMode: ListView.ApplyRange

        // Proxy for delegates
        property bool focusInCombo: widget.activeFocus && widget.enabled;
        property int originalIndex;

        onFocusChanged: {
            if (focus && listView.currentIndex < 0)
                listView.currentIndex = 0;
        }

        onActiveFocusChanged: {
            var parent = widget;
            while (parent) {
                parent.z = activeFocus ? 10 : 0;
                parent = parent.parent;
            }

            ensureCorrectHighlight(false)
        }

        function ensureCorrectHighlight(fromTimer)
        {
            listView.anchors.topMargin = currentItem && activeFocus ? listView.mapToItem(currentItem, 0, 0).y : 0
            listView.positionViewAtIndex(listView.currentIndex, ListView.Center)
            if (!fromTimer)
                ensureTimer.start();
        }

        Timer {
            id: ensureTimer;
            interval: 20;
            onTriggered: listView.ensureCorrectHighlight(true)
        }

        onHeightChanged: ensureCorrectHighlight(false)
        onCurrentItemChanged: {
            if (currentItem)
                currentItem.focus = true;
            ensureCorrectHighlight(false)
        }
        onCurrentIndexChanged: ensureCorrectHighlight(false)
        Component.onCompleted: ensureCorrectHighlight(false)

        Keys.onPressed: {
            switch (event.key) {
            case Qt.Key_Enter:
            case Qt.Key_Return: {
                if (event.isAutoRepeat)
                    return;

                event.accepted = true;
                widget.select(listView.currentIndex);
                break;
            }

            case Qt.Key_Escape:
            case Qt.Key_Back: {
                event.accepted = widget.leaveEditing();
                if (event.accepted)
                    listView.currentIndex = originalIndex;
                break;
            }

            case Qt.Key_Up: {
                event.accepted = true;
                if (event.isAutoRepeat && listView.currentIndex == 0)
                    break;
                listView.decrementCurrentIndex();
                break;
            }

            case Qt.Key_Down: {
                event.accepted = true;
                if (event.isAutoRepeat && listView.currentIndex == listView.count - 1)
                    break;
                listView.incrementCurrentIndex();
                break;
            }
            }
        }

        MouseArea {
            id: mouse
            anchors.fill: parent
            enabled: widget.enabled;
//            hoverEnabled: listView.activeFocus;
//            onPositionChanged: {
//                var index = listView.indexAt(mouseX, mouseY);
//                console.log(mouseX, mouseY, index)
//                if (index >= 0)
//                    listView.currentIndex = index;
//            }
            onReleased: {
                if (listView.activeFocus) {
                    widget.select(listView.currentIndex);
                } else {
                    widget.enterEditing();
                }
            }
        }
    }

    function select(index) {
        if (index >= widget.items.count)
            return;

        var value = widget.items.get(index).value;
        widget.value = value;
        widget.selected(index, value)
        listView.originalIndex = listView.currentIndex = index;

        widget.leaveEditing();
    }

    Component {
        id: delegateComp

        Item {
            width: widget.width - (focusInCombo ? 5 : 0)
            height: widget.height
            property bool focusInCombo: ListView.view.focusInCombo
            property bool isSelectedItem: index == ListView.view.currentIndex
            property string text: label

            StandardAsset {
                anchors.fill: parent
                background: (parent.isSelectedItem
                    ? (parent.focusInCombo ? "CC0000" : "333333")
                    : ((index % 2) ? "666666" : "333333"));
                border: parent.focusInCombo && parent.isSelectedItem ? "FFFFFF" : "333333";
                degrade: !parent.focusInCombo || parent.isSelectedItem;
                reflet: !parent.focusInCombo || parent.isSelectedItem;
                anchors.margins: 6
            }

            Text {
                anchors.fill: parent
                horizontalAlignment: Text.AlignHCenter;
                verticalAlignment: Text.AlignVCenter;
                text: parent.text
                font.bold: true
                font.pixelSize: height / 2
                smooth: true
                color: "white";
            }
        }
    }
}
