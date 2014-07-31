import QtQuick 2.0
import fbx.ui.control 1.0

Item {
    id: self

    property var model
    property int count: model ? model.count : 0
    property int duration: 500

    property string baseUrl: "./"

    property int currentIndex: 0
    property bool animating: false
    property int direction: 0
    property int angleOfRotation: 45

    Component {
        id: imgComp

        FramedImage {
            property alias angle: rot.angle

            Behavior on opacity { NumberAnimation{} }

            transform: Rotation {
                id: rot
                origin.x: parent.width / 2
                origin.y: parent.height / 2
                axis { x: 0; y: 1; z: 0 }
                angle: 0
            }
        }
    }

    Image {
        id: prev
        anchors {
            left: parent.left
            leftMargin: 5
            verticalCenter: parent.verticalCenter
        }
        source: "carousel/previous.png"

        opacity: (self.currentIndex > 0 && !animating) ? 1 : 0

        Behavior on opacity { NumberAnimation{} }
    }

    Image {
        id: next
        anchors {
            right: parent.right
            rightMargin: 5
            verticalCenter: parent.verticalCenter
        }
        source: "carousel/next.png"

        opacity: (self.currentIndex < model.count - 1 && !animating) ? 1 : 0

        Behavior on opacity { NumberAnimation{} }
    }

    Item {
        anchors {
            left: prev.right
            right: next.left
            top: parent.top
            bottom: parent.bottom
            margins: 10
        }

        Loader {
            id: img0
            sourceComponent: imgComp
            anchors.centerIn: parent
            width: parent.width
            height: parent.height
        }

        Loader {
            id: img1
            sourceComponent: imgComp
            anchors.centerIn: parent
            width: parent.width
            height: parent.height

            opacity: 0
        }
    }

    Keys.onPressed: {
        if (animating)
            return;

        switch (event.key) {
        case Qt.Key_Left: {
            if (currentIndex == 0)
                return;
            doAnimation(-1);
            event.accepted = true;
            break;
        }
        case Qt.Key_Right: {
            if (currentIndex >= model.count - 1)
                return;
            doAnimation(1);
            event.accepted = true;
            break;
        }
        }
    }

    onCountChanged: doAnimation(0)

    function doAnimation(d) {
        if (!model || !model.count)
            return
        if (!img0.item)
            return

        self.animating = true;

        self.direction = d;

        img0.item.source = baseUrl + model.get(currentIndex + d).url;
        img0.item.label = model.get(currentIndex + d).label || "";
        img0.opacity = 0;
        img0.anchors.horizontalCenterOffset = d * img0.width;
        img0.item.angle = - angleOfRotation * d;

        img1.item.source = baseUrl + model.get(currentIndex).url;
        img1.item.label = model.get(currentIndex).label || "";
        img1.opacity = 1;
        img1.anchors.horizontalCenterOffset = 0;
        img1.item.angle = 0;

        slideEffect.restart();
    }

    onCurrentIndexChanged: {
        img0.item.source = baseUrl + model.get(currentIndex).url;
        img1.item.source = baseUrl + model.get(currentIndex).url;
    }

    Component.onCompleted: {
        doAnimation(0);
    }

    SequentialAnimation {
        id: slideEffect

        ParallelAnimation {
            PropertyAnimation { target: img0; easing.type: Easing.InOutQuad; property: "anchors.horizontalCenterOffset"; to: 0; duration: self.duration }
            PropertyAnimation { target: img0.item; property: "angle"; to: 0; duration: self.duration }
            PropertyAnimation { target: img0; property: "opacity"; to: 1; duration: self.duration }
            PropertyAnimation { target: img1; easing.type: Easing.InOutQuad; property: "anchors.horizontalCenterOffset"; to: - self.direction * img1.width; duration: self.duration }
            PropertyAnimation { target: img1.item; property: "angle"; to: self.direction * self.angleOfRotation; duration: self.duration }
            PropertyAnimation { target: img1; property: "opacity"; to: 0; duration: self.duration }
        }

        ScriptAction {
            script: {
                self.currentIndex += self.direction
                self.animating = false;
            }
        }
    }
}
