import QtQuick 2.3

BorderImage {
    id: self

    border {
        top: 10
        left: 10
        right: 10
        bottom: 10
    }
    asynchronous: true
    smooth: true

    function getSource() {
        var s = "icon_list_bg/icon_list_bg_";
        if (solid)
            s += "solid_"
        if (focused) {
            s += "focus"
            if (bordered)
                s += "_border"
        } else
            s += "blur"
        return s + ".png"
    }

    source: getSource();

    property int iconWidth: height
    property bool bordered: false
    property bool focused: false
    property bool solid: false
    property alias logo: logoImage.source

    default property alias contents: container.data

    children: [
        Image {
            id: logoImage

            asynchronous: true
            smooth: true
            fillMode: Image.PreserveAspectFit

            anchors {
                top: parent.top
                topMargin: 5
                bottom: parent.bottom
                bottomMargin: 5
                left: parent.left
                leftMargin: 5
                right: parent.left
                rightMargin: - self.height
            }
        },

        Image {
            id: separator

            smooth: true
            asynchronous: true

            anchors {
                margins: 5
                top: parent.top
                bottom: parent.bottom
                left: logoImage.right
            }

            opacity: .5
            source: "icon_list_bg/icon_list_bg_sep.png"
        },

        Item {
            id: container

            anchors {
                margins: 3
                top: parent.top
                bottom: parent.bottom
                left: separator.right
                right: parent.right
            }
        }
    ]
}
