import QtQuick 2.0
import fbx.ui.control 1.0

Alert {
    id: self

    modal: true
    buttons: ["Confirmer", "Annuler"]
    hasControls: true

    property alias input: textInput
    property alias value: textInput.text

    title: "Prompt"

    Component.onCompleted: {
        textInput.focus = true
    }

    function responseData(data)
    {
        if (data.button != 0)
            throw "Cancelled";

        data.text = textInput.text;
        return data;
    }

    TextInput {
        id: textInput
        focus: true
        autoFocus: true

        anchors.top: label.bottom
        width: 500
    }
}
