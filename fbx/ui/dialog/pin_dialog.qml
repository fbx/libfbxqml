import QtQuick 2.0
import fbx.ui.control 1.0

Alert {
    id: self
    objectName: "fbx.ui.dialog.PinDialog"

    property alias pin: pinInput.text

    buttons: ["OK", "Annuler"]
    property int buttonOnAccepted: 0
    focusControls: true
    hasControls: true

    function responseData(data)
    {
        data.text = pinInput.text;
        return data;
    }

    InputFrame {
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: label.bottom
        anchors.topMargin: 20

        text: "PIN"
        focus: true
        color: "white"
        bgColor: "111111"

        PinInput {
            id: pinInput
            focus: true
            anchors.fill: parent
            autoFocus: true

            placeholderText: ""

            onAccepted: {
                if (explicit && buttonOnAccepted >= 0)
                    self.buttonSelected(buttonOnAccepted)
            }
        }
    }
}
