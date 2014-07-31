import QtQuick 2.0

FocusScope {
    id: widget

    property bool autoFocus: false;
    enabled: true;
    property var control: null;
    property bool editing: control.activeFocus;

    signal tryToLeave();

    function rehashFocus()
    {
        if (widget.enabled && autoFocus) {
            if (control)
                control.focus = true;
        } else
            focusPlaceholder.focus = true;
    }

    onAutoFocusChanged: rehashFocus();
    onEnabledChanged: rehashFocus();
    Component.onCompleted: rehashFocus();

    onActiveFocusChanged: {
        if (!activeFocus)
            rehashFocus();
    }

    Item {
        id: focusPlaceholder
        focus: true;

        // Events not catched by textInput
        Keys.onPressed: {
            if (event.isAutoRepeat)
                return;

            switch (event.key) {
            case Qt.Key_Enter:
            case Qt.Key_Return: {
                if (widget.enabled) {
                    control.focus = true
                    event.accepted = true
                    break;
                }
            }
            }
        }
    }

    function leaveEditing()
    {
        if (autoFocus) {
            tryToLeave();
            return false;
        }
        focusPlaceholder.focus = true;
        return true;
    }

    function enterEditing()
    {
        if (!widget.enabled)
            return false;
        control.focus = true;
        return true;
    }
}
