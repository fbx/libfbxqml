import QtQuick 2.0
import fbx.ui.base 1.0
import fbx.ui.control 1.0
import fbx.ui.layout 1.0

FocusScope {
    anchors.leftMargin: 10
    objectName: "fbx.ui.menu.Menu"
    property string title: "Menu"

    default property alias elements: scrollable.elements;
    property alias currentIndex: scrollable.currentIndex;
    property var menu

    opacity: menu ? 1 : 0

    /** Public API */

    function close()
    {
        menu.close();
    }

    ScrollableColumn {
        id: scrollable

        focus: true
        anchors.fill: parent
        highlight: StandardAsset {
            anchors {
                fill: parent
                leftMargin: -20
                rightMargin: 10
                topMargin: 4
                bottomMargin: 4
            }
            background: "CC0000"
            reflet: true
        }

        function isUsable(item)
        {
            if (item.objectName != "fbx.ui.menu.Entry")
                return false;
            if (!item.visible)
                return false;
            if (item.enabled !== undefined && !item.enabled)
                return false;
            return true;
        }
    }
}
