import QtQuick 2.0

Row {
    id: self

    property int value: 3
    property int maximumValue: 5

    property real starSize: Math.min(height, width / maximumValue)

    width: 20 * maximumValue
    height: 20

    Repeater {
        model: maximumValue

        Image {
            width: starSize
            height: starSize
            asynchronous: true

            property bool on: self.value > index
            source: on
                 ? (starSize > 16 ? "stars/ok_big.png" : "stars/ok.png")
                 : (starSize > 16 ? "stars/nok_big.png" : "stars/nok.png")
        }
    }
}
