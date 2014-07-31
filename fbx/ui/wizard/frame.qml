import QtQuick 2.0
import fbx.ui.dialog 1.0
import fbx.ui.layout 1.0

FocusScope {
    id: self
    default property alias contents: frame.contents
    property string title
    property bool noDisplayCount: false
    property int index
    property int count

    signal end();
    signal error();
    signal done();
    signal cancel();
    signal reset();
    signal setTo(int index);

    Background {
        background: "player"
    }

    Frame {
        id: frame
        focus: true
        anchors.centerIn: parent
        title: noDisplayCount ? self.title : (index + 1) + "/" + count + " : " + self.title
    }
}
