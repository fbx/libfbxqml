import QtQuick 2.0
import fbx.data 1.0

Text {
    id: clock

    property alias format: t.format

    font.pixelSize: height * .8
    text: t.time

    Time {
        id: t
    }
}
