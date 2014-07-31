import QtQuick 2.0
import "transition_manager.js" as Priv
import "animation.js" as Animation
import fbx.async 1.0

FocusScope {
    id: widget

    property int duration: 300

    property string baseUrl: "./"

    property var nextItem
    property var currentItem
    property var previousItem

    signal willSwitchItems();
    signal didSwitchItems();

    function switchToItem(item, animation)
    {
        return Priv.switchToItem(item, animation);
    }

    function switchToUrl(url, args, animation)
    {
        return Priv.switchToUrl(url, args, animation);
    }

    function switchToComponent(comp, args, animation)
    {
        return Priv.switchToComponent(comp, args, animation);
    }

    function animationReverse(a)
    {
        return Animation.animationReverse(a);
    }

    Item {
        id: focusPlaceholder
        focus: true
    }

    FocusScope {
        id: objectPool
        anchors.fill: parent
        opacity: 0
    }

    onWidthChanged: {
        if (Priv.currentItem)
            Priv.currentItem.width = width
    }

    onHeightChanged: {
        if (Priv.currentItem)
            Priv.currentItem.height = height
    }

    TimeQueue {
        id: tq
    }

    Component {
        id: frameComponent

        FocusScope {
            id: frame

            width: parent ? parent.width : 40
            height: parent ? parent.height : 40

            property var item
            property int duration
            property bool autoDelete: false

            signal animationComplete()

            function animate(destState) {
                rot.origin.x = destState == "main" ? 0 : frame.width;
                Animation.applyState(frame, frame.width, frame.height, destState);
            }

            Behavior on x {
                NumberAnimation { easing.type: Easing.InOutQuad; duration: frame.duration }
            }
            Behavior on y {
                NumberAnimation { easing.type: Easing.InOutQuad; duration: frame.duration }
            }
            Behavior on opacity {
                NumberAnimation { easing.type: Easing.InOutQuad; duration: frame.duration }
            }
            Behavior on scale {
                NumberAnimation { easing.type: Easing.InOutQuad; duration: frame.duration }
            }

            property real angle: 0
            Behavior on angle {
                NumberAnimation { easing.type: Easing.InOutCubic; duration: frame.duration }
            }
            transform: Rotation { id: rot; origin.y: frame.height / 2; axis { x: 0; y: 1; z: 0 } angle: frame.angle }
        }
    }
}
