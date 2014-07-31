import QtQuick 2.0

FocusScope {
    id: self

    objectName: "frame-" + state
    property real ratio: 1
    property int duration: 200
    property FocusScope container: inner
    property alias state: frame.state

    Item {
        id: frame

        anchors.top: self.top
        anchors.bottom: self.bottom

        state: "outleft"

        states: [
            State {
                name: "outleft"
                AnchorChanges {
                    target: frame
                    anchors.right: self.left
                    anchors.left: self.left
                }
                PropertyChanges {
                    target: frame.anchors
                    leftMargin: -self.width * self.ratio
                    rightMargin: 0
                }
            },
            State {
                name: "inleft"
                AnchorChanges {
                    target: frame
                    anchors.right: self.left
                    anchors.left: self.left
                }
                PropertyChanges {
                    target: frame.anchors
                    leftMargin: 0
                    rightMargin: -self.width * self.ratio
                }
            },
            State {
                name: "inright"
                AnchorChanges {
                    target: frame
                    anchors.right: self.right
                    anchors.left: self.right
                }
                PropertyChanges {
                    target: frame.anchors
                    leftMargin: -self.width * self.ratio
                    rightMargin: 0
                }
            },
            State {
                name: "outright"
                AnchorChanges {
                    target: frame
                    anchors.right: undefined
                    anchors.left: self.right
                }
                PropertyChanges {
                    target: frame.anchors
                    leftMargin: 0
                    rightMargin: -self.width * self.ratio
                }
            },

            State {
                name: "outleft-noanim"
                AnchorChanges {
                    target: frame
                    anchors.right: self.left
                    anchors.left: self.left
                }
                PropertyChanges {
                    target: frame.anchors
                    leftMargin: -self.width * self.ratio
                    rightMargin: 0
                }
            },
            State {
                name: "inleft-noanim"
                AnchorChanges {
                    target: frame
                    anchors.right: self.left
                    anchors.left: self.left
                }
                PropertyChanges {
                    target: frame.anchors
                    leftMargin: 0
                    rightMargin: -self.width * self.ratio
                }
            },
            State {
                name: "inright-noanim"
                AnchorChanges {
                    target: frame
                    anchors.right: self.right
                    anchors.left: self.right
                }
                PropertyChanges {
                    target: frame.anchors
                    leftMargin: -self.width * self.ratio
                    rightMargin: 0
                }
            },
            State {
                name: "outright-noanim"
                AnchorChanges {
                    target: frame
                    anchors.right: self.right
                    anchors.left: self.right
                }
                PropertyChanges {
                    target: frame.anchors
                    leftMargin: 0
                    rightMargin: -self.width * self.ratio
                }
            }
        ]

        transitions: Transition {
            to: "outleft,inleft,inright,outright"
            ParallelAnimation {
                AnchorAnimation { }
                PropertyAnimation { property: "anchors.leftMargin" }
                PropertyAnimation { property: "anchors.rightMargin" }
            }
        }

        FocusScope {
            id: inner
            anchors.fill: parent
            focus: true
        }
    }
}
