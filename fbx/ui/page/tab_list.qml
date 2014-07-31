import QtQuick 2.0
import fbx.ui.base 1.0

ListView {
    id: listView

    signal selected(int index)

    delegate: Clickable {
        id: self

        property string text: title
        clip: true

        /*** Private */

        implicitWidth: 135
        implicitHeight: 40

        StandardAsset {
            id: background
            anchors.fill: parent
            anchors.topMargin: 5
            anchors.leftMargin: 5
            anchors.rightMargin: 5
            anchors.bottomMargin: -10

            background: !enabled ? "666666" :
                !self.focus ? "333333" :
                listView.activeFocus ? "CC0000" : "660000"
            degrade: self.enabled
            reflet: true
            border: (self.enabled && self.hovered) ? "FF0000" : ""
        }

        Text {
            text: self.text
            font.bold: true
            font.pixelSize: self.height / 2
            smooth: true
            color: "white"
            anchors.centerIn: parent
        }

        onClicked: listView.selected(model.index)
    }

    orientation: ListView.Horizontal

    onCurrentItemChanged: currentItem.focus = true

    implicitWidth: 500
    implicitHeight: 40

    preferredHighlightBegin: width * .33
    preferredHighlightEnd: width * .66

    highlightRangeMode: ListView.ApplyRange
    highlightMoveDuration: 100
}
