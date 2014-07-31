import QtQuick 2.0
import fbx.ui.control 1.0

FocusScope {
    id: self;
    focus: false;

    property var stack
    property alias showClock: clock.visible

    implicitHeight: 40

    Image {
        anchors.fill: parent;
        source: "breadcrumb/background.png"
    }

    ListView {
        id: listView
        delegate: itemDelegate
        focus: true;

        orientation: ListView.Horizontal
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.right: clock.left
        anchors.rightMargin: 20

        model: self.stack.titleList

        onCountChanged: {
            currentIndex = count - 1;
            atEnd();
            ensureTimer.restart();
        }

        onActiveFocusChanged: atEnd();
        onWidthChanged: atEnd();

        function atEnd()
        {
            if (!activeFocus) {
                currentIndex = count - 1;
                listView.positionViewAtEnd();
            }
        }

        function atEndLater()
        {
            ensureTimer.restart();
        }

        Timer {
            id: ensureTimer
            interval: 1
            onTriggered: listView.atEnd()
        }

        preferredHighlightBegin: width * .33
        preferredHighlightEnd: width * .66

        highlightRangeMode: ListView.ApplyRange
        highlightMoveDuration: 100

        function userSelected(index)
        {
            self.stack.popTo(index);
        }
    }

    Image {
        id: clock
        anchors.top: parent.top;
        anchors.right: parent.right;
        anchors.bottom: parent.bottom;
        width: visible ? 120 : 0

        source: "breadcrumb/background.png"

        CurrentTime {
            opacity: 0.7

            anchors.centerIn: parent

            font.pixelSize: parent.height - 5
            font.bold: true

            color: "black"
        }
    }

    Component {
        id: itemDelegate

        FocusScope {
            id: item
            focus: false;

            property string pageTitle: model.title || " "

            property string image: getImage(activeFocus, ListView.isCurrentItem, index, ListView.view.count);
            property string color: getColor(activeFocus, ListView.isCurrentItem, index, ListView.view.count);

            function getImage(activeFocus, isCurrentItem, index, count)
            {
                if (activeFocus && isCurrentItem)
                    return "focus";
                if (ListView.view.count - 1 == index)
                    return "last";
                if (index < 0)
                    return "blur0";
                return "blur" + (index % 2);
            }

            function getColor(activeFocus, isCurrentItem, index, count)
            {
                if (activeFocus && isCurrentItem)
                    return "white";
                if (ListView.view.count - 1 == index)
                    return "white";
                return "#333"
            }

            visible: pageTitle != ""
            width: pageTitle == "" ? 0 : Math.min(label.implicitWidth, 500) + 30
            height: parent.height

            Keys.onReturnPressed: ListView.view.userSelected(index)
            Keys.onEnterPressed: ListView.view.userSelected(index)

            function rehashSize()
            {
                ListView.view.atEndLater();
            }

            BorderImage {
                anchors.left: label.left;
                width: label.implicitWidth + 62;
                anchors.leftMargin: -31;
                border {
                    left: 20
                    right: 20
                }
                smooth: true
                source: "breadcrumb/" + parent.image + ".png"

                Behavior on width { NumberAnimation { duration: 100 } }
                onWidthChanged: item.rehashSize();
            }

            Text {
                id: label
                anchors.fill: parent;
                anchors.rightMargin: 30;
                anchors.leftMargin: 10;
                color: parent.color
                text: parent.pageTitle
                verticalAlignment: Text.AlignVCenter

                font {
                    pixelSize: item.height / 2
                    capitalization: Font.AllUppercase
                    bold: true
                }
            }

            MouseArea {
                id: mouseArea
                anchors.fill: parent;
                onClicked: item.ListView.view.userSelected(index);
                enabled: true
            }
        }
    }
}
