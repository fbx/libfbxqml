import QtQuick 2.0
import fbx.ui.base 1.0

FocusToggler {
    id: widget

    implicitHeight: 40
    implicitWidth: 300

    /*** Signals */
    signal accepted(bool explicit);
    signal cancelled();

    /*** Appearance */
    /* Text shown when input line is empty, shaded. */
    property string placeholderText: autoFocus ? "" : "Appuyez sur 'OK'"
    /* Usual echo modes, TextInput.Password, TextInput.PasswordEchoOnEdit */
    property alias echoMode: textInput.echoMode;

    property bool errorHighlight: !textInput.acceptableInput

    /*** Styling */
    property alias validator: textInput.validator
    property alias color: textInput.color
    property alias font: textInput.font
    property alias selectionColor: textInput.selectionColor
    property string highlightColor: "FF0000"
    property alias horizontalAlignment: textInput.horizontalAlignment

    /*** Data */
    /* Actual entered text, may not be validated yet. */
    property string text
    /* Typed text, useful for on-the-fly operations. */
    property alias typedText: textInput.text
    /* Maximal length of text */
    property alias maximumLength: textInput.maximumLength
    /* Cursor position in the line. R/W */
    property alias cursorPosition: textInput.cursorPosition;

    /*** Behavior */
    /* Hint for virtual keyboard
       Use Qt.ImhDigitsOnly, Qt.ImhUrlCharactersOnly, Qt.ImhEmailCharactersOnly */
    property alias inputMethodHints: textInput.inputMethodHints

    property string displayText

    property bool userModified: false

    // Internal

    control: textInput;

    KeyNavigation.priority: KeyNavigation.BeforeItem;

    StandardAsset {
        border: widget.enabled ? (widget.activeFocus ? highlightColor : "FFFFFF") : "";
        blur: widget.errorHighlight
        blurColor: widget.enabled ? "CC0000" : ""
        anchors.fill: parent
        anchors.margins: 6;
        background: widget.enabled ? "FFFFFF" : "666666"
    }

    onEditingChanged: {
        if (editing)
            return;
        widget.text = textInput.text;
    }

    TextInput {
        id: textInput
        smooth: true;
        activeFocusOnPress: widget.enabled;
        font.pixelSize: widget.height / 2
        color: "black"

        anchors.verticalCenter: parent.verticalCenter
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.leftMargin: 16
        anchors.rightMargin: 16

        clip: true
        readOnly: !widget.enabled

        onActiveFocusChanged: {
            cursorVisible = textInput.activeFocus;
        }

        KeyNavigation.priority: KeyNavigation.BeforeItem;
        KeyNavigation.up: widget.KeyNavigation.up
        KeyNavigation.down: widget.KeyNavigation.down

        onAccepted: {
            widget.text = textInput.text;

            widget.leaveEditing()
            widget.accepted(true);
        }

        onTextChanged: {
            if (editing)
                widget.userModified = true;
            if (autoFocus)
                widget.text = text;
        }

        Keys.onPressed: {
            switch (event.key) {
            case Qt.Key_Delete: {
                var m = Qt.ControlModifier | Qt.ShiftModifier;
                if ((event.modifiers & m) == m) {
                    event.accepted = true;
                    text = "";
                }
                break;
            }

            case Qt.Key_Escape:
            case Qt.Key_Back: {
                if (text == "") {
                    event.accepted = !autoFocus;
                    textInput.text = widget.text;
                    widget.cancelled();
                } else {
                    event.accepted = true
                    text = ""
                }
                break;
            }
            }
        }
    }

    onTextChanged: {
        if (!editing && textInput.text != text)
            widget.userModified = false;

        if (textInput.text != text)
            textInput.text = text;
        switch (echoMode) {
        case TextInput.Normal: {
            displayText = text;
            break;
        }
        case TextInput.NoEcho: {
            displayText = "";
            break;
        }
        case TextInput.PasswordEchoOnEdit:
        case TextInput.Password: {
            displayText = "************".substr(0, text.length);
            break;
        }
        }
    }

    Keys.onPressed: {
        switch (event.key) {
        case Qt.Key_Up:
        case Qt.Key_Down:
        case Qt.Key_Left:
        case Qt.Key_Right:
        case Qt.Key_Tab:
            if (editing && !textInput.acceptableInput && !autoFocus)
                event.accepted = true;
        }
    }

    Text {
        clip: true
        anchors.fill: textInput
        visible: textInput.text == "" && widget.enabled
        text: placeholderText
        font.pixelSize: textInput.font.pixelSize
        color: "grey"
        style: Text.Raised;
        styleColor: "white"
    }
}
