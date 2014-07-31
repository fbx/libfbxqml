import QtQuick 2.0
import QtQuick.Window 2.1

Window {
    id: self

    property string identifier
    property string name
    property int profileId

    objectName: "fbx.application.Application"
    default property alias contents: inner.data

    color: "transparent"

    property alias scaler: scaler

    /*
       Privates
     */

    data: UiScaler {
        id: scaler

        FocusScope {
            id: inner

            focus: true
            anchors.fill: parent

            Keys.onPressed: {
                switch (event.key) {
                case Qt.Key_Escape:
                case Qt.Key_Back: {
                    event.accepted = true;

                    break;
                }
                }
            }
        }
    }

    Component.onCompleted: {
        self.visibility = Window.FullScreen
    }
}
