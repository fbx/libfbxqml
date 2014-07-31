import QtQuick 2.0
import fbx.ui.page 1.0
import fbx.ui.control 1.0
import fbx.ui.controller 1.0
import fbx.ui.layout 1.0
import fbx.ui.base 1.0

Page {
    id: page

    persistentProperties: ["currentIndex", "infoWanted"]
    property alias currentIndex: scrollable.currentIndex

    property bool showInfo: true
    property alias infoWanted: info.wanted

    default property alias elements: scrollable.elements

    ScrollableColumn {
        id: scrollable
        focus: true

        anchors.margins: 10
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: info.top

        clip: true

        highlightMoveDuration: 50
        highlight: StandardAsset {
            anchors {
                fill: parent
                margins: 2
            }
            background: "CC0000"
            reflet: true
        }

        function isUsable(item)
        {
            if (item.objectName != "fbx.ui.setting.Entry")
                return false;
            if (!item.visible)
                return false;
            if (item.enabled !== undefined && !item.enabled)
                return false;
            return true;
        }

        onCurrentItemChanged: info.text = (currentItem ? currentItem.info : "");
    }

    InfoPanel {
        id: info

        shown: !!stack && !!stack.tip && !!stack.tip.showInfo && wanted

        property bool wanted: true
        property string text

        onTextChanged: {
            var way = scrollable.movingUp ? "slideLeft" : "slideRight";
            if (text)
                tm.switchToComponent(infoText, { text: text }, way);
            else
                tm.switchToItem(null, way);
        }

        TransitionManager {
            id: tm
            anchors.fill: parent
            anchors.margins: 10
            duration: 200
        }

        Binding {
            target: tm.currentItem || null
            when: !!tm.currentItem
            property: "text"
            value: info.text
        }
    }

    Component {
        id: infoText

        Text {
            color: "white"
            font.pixelSize: 20
            wrapMode: Text.Wrap
        }
    }

    Keys.onPressed: {
        if (event.key == Qt.Key_Help) {
            info.wanted = !info.wanted;
            event.accepted = true;
        }
    }
}
