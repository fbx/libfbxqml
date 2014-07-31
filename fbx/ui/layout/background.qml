import QtQuick 2.0

Image {
    id: widget

    property string background: ""
    property string logo: ""
    property real logoRatio: .8

    asynchronous: true
    anchors.fill: parent
    smooth: true
    source: widget.background ? ("background/" + widget.background + ".png") : ""

    Image {
        visible: widget.logo != ""
        anchors {
            centerIn: parent
        }
        width: Math.min(widget.width, widget.height) * widget.logoRatio
        height: Math.min(widget.width, widget.height) * widget.logoRatio
        fillMode: Image.PreserveAspectFit
        smooth: true
        asynchronous: true
        source: widget.logo ? "background/" + widget.logo + ".png" : ""
    }
}
