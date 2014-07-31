import QtQuick 2.3
import fbx.ui.control 1.0

TextInput {
    objectName: "fbx.ui.control.PinInput"

    implicitHeight: 40
    implicitWidth: 120
    autoFocus: true

    placeholderText: "PIN"
    echoMode: TextInput.Password
    inputMethodHints: Qt.ImhDigitsOnly
    validator: RegExpValidator { regExp: /^\d{4}$/ }
}
