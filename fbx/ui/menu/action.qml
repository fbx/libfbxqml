import QtQuick 2.0

Entry {
    id: widget
    enabled: true

    signal clicked()

    property alias text: textItem.text
    property int rightMargin: 16
    property bool close: true

    Text {
        id: textItem
        color: widget.enabled ? "white" : "gray"
        font.pixelSize: parent.height * 0.55
        anchors.verticalCenter: parent.verticalCenter
        anchors.left: parent.left
        anchors.leftMargin: 16
        anchors.right: parent.right
        anchors.rightMargin: widget.rightMargin
        elide: Text.ElideRight
    }

    Keys.onPressed: {
        switch (event.key) {
        case Qt.Key_Return:
        case Qt.Key_Enter: {
            if (widget.close)
                findView().close();
            clicked();
            event.accepted = true;
        }
        }
    }

    function findView()
    {
        var item = widget;

        while (item && item.objectName != "fbx.ui.menu.View")
            item = item.parent;

        return item;
    }
}
