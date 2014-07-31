import QtQuick 2.0

Row {
    id: self

    property alias columns: rep.model
    property variant texts
    property int zeroWidth: 0
    default property alias delegate: rep.delegate

    property int pixelSize: 20
    property bool bold: false
    property string color: "white"
    property int horizontalAlignment: Text.AlignLeft
    property int verticalAlignment: Text.AlignTop

    onColumnsChanged: reload()
    onWidthChanged: reload()

    Repeater {
        id: rep

        onCountChanged: reload()

        Text {
            horizontalAlignment: self.horizontalAlignment
            verticalAlignment: self.verticalAlignment
            font.pixelSize: self.pixelSize
            font.bold: self.bold
            color: self.color
            text: (texts ? texts[model.index] : model.text) || ""
            width: model.width || zeroWidth
            height: self.height
            elide: Text.ElideRight
        }
    }

    function reload()
    {
        var zeroCount = 0;
        var available = self.width + spacing;

        for (var i = 0; i < columns.count; ++i) {
            var m = columns.get(i);

            available -= spacing;
            if (m.width)
                available -= m.width;
            else
                zeroCount++;
        }

        self.zeroWidth = available / (zeroCount || 1);
        console.log("Adaptable column width", self.zeroWidth, "/", self.width)
    }
}
