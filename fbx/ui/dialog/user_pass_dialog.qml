import QtQuick 2.0
import fbx.ui.control 1.0

Alert {
    id: self

    modal: true
    buttons: ["OK", "Annuler"]
    hasControls: true
    focusControls: true

    function responseData(data)
    {
        if (data.button != 0)
            throw "Cancelled";

        data.user = userInput.text;
        data.password = passInput.text;
        return data;
    }

    title: "Authentification"

    InputFrame {
        id: userFrame
        KeyNavigation.down: passFrame

        focus: true
        bgColor: "111111"

        text: "Utilisateur"

        anchors.top: self.label.bottom
        width: 500

        TextInput {
            id: userInput
            focus: true
        }
    }

    InputFrame {
        id: passFrame
        KeyNavigation.up: userFrame

        text: "Mot de passe"
        bgColor: "111111"

        anchors.top: userFrame.bottom
        width: 500

        TextInput {
            id: passInput
            echoMode: TextInput.PasswordEchoOnEdit
            focus: true
        }
    }
}
