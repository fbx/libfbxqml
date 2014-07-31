import QtQuick 2.0
import fbx.data 1.0

Text {
    id: self

    property alias format: date.format

    Date {
        id: date
    }

    text: date.date;
    font.pixelSize: height * .8
}
