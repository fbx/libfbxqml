import QtQuick 2.0
import fbx.ui.control 1.0
import fbx.ui.menu 1.0
import fbx.wl 1.0
import fbx.data 1.0

AudioPlayer {
    id: self

    onXChanged: updateBbox();
    onYChanged: updateBbox();
    onWidthChanged: updateBbox();
    onHeightChanged: updateBbox();

    function updateBbox()
    {
        if (!visible || !width || !height)
            return;

        self.mms.bbox = Qt.rect(0, 0, width, height);
    }

    ForeignSurface {
        z: -1
        name: mms.handle
        onNameChanged: updateBbox();
        anchors.fill: parent
    }

    CheckableGroup {
        id: formatSelector

        onValueChanged: {
            console.debug("Image format now", value)
            self.fillMode = value || self.preserveAspectFit;
        }
    }

    property Menu formatMenu: Menu {
        id: formatMenu
        title: "Format d'image"

        CheckBox {
            exclusiveGroup: formatSelector
            text: "Letterbox"
            value: self.preserveAspectFit
            checked: true
        }

        CheckBox {
            exclusiveGroup: formatSelector
            text: "Plein écran"
            value: self.stretch
        }

        CheckBox {
            exclusiveGroup: formatSelector
            text: "Pan Scan"
            value: self.preserveAspectCrop
        }

        CheckBox {
            exclusiveGroup: formatSelector
            text: "Anamorphique"
            value: self.anamorphic
        }
    }
}
