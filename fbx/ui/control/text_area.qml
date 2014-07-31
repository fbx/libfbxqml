import QtQuick 2.0
import fbx.ui.base 1.0

FocusToggler {
    id: widget

    implicitHeight: 400
    implicitWidth: 300

    signal onLinkActivated (string link)

    /*** Appearance */
    /* Text shown when edit line is empty, shaded. */
    property string placeholderText: "Appuyez sur 'OK'"

    /*** Styling */
    property alias color: textEdit.color
    property alias font: textEdit.font
    property alias selectionColor: textEdit.selectionColor
    property alias horizontalAlignment: textEdit.horizontalAlignment
    property alias textFormat: textEdit.textFormat
    property alias selectionStart: textEdit.selectionStart
    property alias selectionEnd: textEdit.selectionEnd
    property alias cursorPosition: textEdit.cursorPosition
    property alias cursorRectangle: textEdit.cursorRectangle

    /*** Data */
    /* Actual entered text, may not be validated yet. */
    property alias text: textEdit.text

    /*** Behavior */
    /* Hint for virtual keyboard
       Use Qt.ImhDigitsOnly, Qt.ImhUrlCharactersOnly, Qt.ImhEmailCharactersOnly */
    property alias inputMethodHints: textEdit.inputMethodHints

    property bool readOnly: false;


    function positionAt(x, y)
    {
        textEdit.positionAt(x, y)
    }

    function positionToRectangle(r)
    {
        textEdit.positionToRectangle(r)
    }

    function select(a, b)
    {
        textEdit.select(a, b)
    }

    function deselect()
    {
        textEdit.deselect()
    }

    function selectAll()
    {
        textEdit.selectAll()
    }

    // Internal

    control: textEdit;

    StandardAsset {
        border: widget.enabled ? (widget.activeFocus && !textEdit.activeFocus ? "FF0000" : "FFFFFF") : "";
        anchors.fill: parent
        anchors.margins: 6;
        background: widget.enabled ? (readOnly ? "CCCCCC" : "FFFFFF") : "666666"
    }

    Scrollbar {
        id: scrollbar

        anchors.right: widget.right
        anchors.top: widget.top
        anchors.bottom: widget.bottom
        anchors.margins: 12;

        width: 5

        widthRatio: flickable.visibleArea.widthRatio
        heightRatio: flickable.visibleArea.heightRatio
        xPosition: flickable.visibleArea.xPosition
        yPosition: flickable.visibleArea.yPosition

        cursor.color: textEdit.activeFocus ? "red" : "#80ffffff"
        animationDuration: 0
    }

    Flickable {
        id: flickable

        anchors.right: scrollbar.right
        anchors.top: widget.top
        anchors.bottom: widget.bottom
        anchors.left: widget.left

        anchors.topMargin: 12
        anchors.leftMargin: 12
        anchors.rightMargin: 3
        anchors.bottomMargin: 12

        interactive: false

        contentWidth: textEdit.width
        contentHeight: textEdit.height

        clip: true

        TextEdit {
            id: textEdit

            smooth: true;
            cursorVisible: activeFocus;
            activeFocusOnPress: widget.enabled;
            font.pixelSize: 20
            color: "black"
            width: flickable.width
            readOnly: widget.readOnly || !widget.enabled
            wrapMode: TextEdit.Wrap
            selectByMouse: true

            onActiveFocusChanged: {
                updateViewport(cursorRectangle);
                if (activeFocus && widget.enabled && !widget.readOnly) {
                    openSoftwareInputPanel();
                }
            }

            onCursorRectangleChanged: updateViewport(cursorRectangle)
            onHeightChanged: updateViewport(cursorRectangle)
            onWidthChanged: updateViewport(cursorRectangle)
            onTextChanged: updateViewport(cursorRectangle)
            onSelectionEndChanged: updateViewport(positionToRectangle(selectionEnd))
            onSelectionStartChanged: updateViewport(positionToRectangle(selectionStart))

            selectionColor: "#ffcccc"
            selectedTextColor: "black"

            onLinkActivated: widget.onLinkActivated(link)

            function updateViewport(pos)
            {
                var ybegin = flickable.contentY
                var yview = flickable.visibleArea.heightRatio * height;
                var yend = flickable.contentY + yview;
                var cursy = pos.y;
                var cursyend = pos.y + pos.height;

                if (cursy < ybegin)
                    flickable.contentY = cursy;
                else if (cursyend > yend)
                    flickable.contentY = cursyend - yview;
            }

            Keys.priority: Keys.BeforeItem

            property int backspaceRepeatCount: 0;

            Keys.onPressed: {
                // As we handle keys before the view, we have to eat
                // Up/Down events in case they would get us out of the
                // view.
                // In read only mode, Up/Down scrolls.
                switch (event.key) {
                case Qt.Key_Up: {
                    if (readOnly) {
                        flickable.contentY = Math.max(
                            0,
                            flickable.contentY - textEdit.font.pixelSize);
                        event.accepted = true;
                    } else if (cursorRectangle.y < font.pixelSize) {
                        event.accepted = true;
                    }
                    return;
                }

                case Qt.Key_Delete: {
                    var m = Qt.ControlModifier | Qt.ShiftModifier;
                    if ((event.modifiers & m) == m) {
                        event.accepted = true;
                        textEdit.text = "";
                    }
                    break;
                }

                case Qt.Key_Down: {
                    if (readOnly) {
                        flickable.contentY = Math.min(
                            textEdit.height - flickable.visibleArea.heightRatio * height,
                            flickable.contentY + textEdit.font.pixelSize);
                        event.accepted = true;
                    } else if (cursorRectangle.y + cursorRectangle.height >= height) {
                        event.accepted = true;
                    }
                    return;
                }

                // If there are many repeats with backspace, we select
                // the whole word before the cursor (never after) and
                // let the TextEdit handle backspace as usual
                case Qt.Key_Backspace: {
                    if (!event.isAutoRepeat) {
                        backspaceRepeatCount = 0;
                    } else if (backspaceRepeatCount > 20) {
                        var curs = cursorPosition;
                        selectWord();
                        select(selectionStart, curs);
                    } else {
                        backspaceRepeatCount++;
                    }
                    return;
                }

                case Qt.Key_Return:
                case Qt.Key_Enter: {
                    if (readOnly)
                        event.accepted = widget.leaveEditing()
                    break;
                }

                case Qt.Key_Escape:
                case Qt.Key_Back: {
                    event.accepted = widget.leaveEditing()
                    break;
                }
                }
            }
        }
    }

    Text {
        clip: true
        anchors.fill: flickable
        anchors.topMargin: 2
        visible: textEdit.text == "" && widget.enabled && !widget.readOnly
        text: placeholderText
        font.pixelSize: 20
        color: "grey"
        style: Text.Raised;
        styleColor: "white"
    }
}
