import QtQuick 2.0
import fbx.ui.control 1.0
import fbx.ui.layout 1.0
import fbx.data 1.0

InfoPanel {
    id: self
    height: col.height
    property bool hasControls: false
    background: ""

    property string name: player && player.metadata && player.metadata.title || ""
    property int duration: player && player.duration || 0
    property int position: player && player.position || 0
    property string status: player && mkStatus(vsc.seekDirection, player.mediaState, player.playbackState) || ""

    property alias handleNumbers: vsc.handleNumbers
    property alias handleSeek: vsc.handleSeek
    property alias handleJump: vsc.handleJump
    property alias handleControl: vsc.handleControl

    property Item player

    signal prev()
    signal next()

    default property alias container: body.data

    VideoSeekController {
        id: vsc
        position: self.position
        duration: self.duration
        onMoved: show();
        onSeek: player.seek(position);
        onPrev: self.prev();
        onNext: self.next();
        onStop: player.stop();
        onPlayPause: player.playPause();
    }

    FocusScope {
        id: col
        height: body.height + tl.height + (hasControls ? 10 : 0)
        width: parent.width

        FocusScope {
            id: body
            focus: true
            opacity: hasControls ? 1 : 0
            width: parent.width
            height: body.opacity == 1 ? childrenRect.height : 0
            Behavior on height {NumberAnimation{duration: 100}}
            Keys.forwardTo: [vsc]
        }

        Timeline {
            id: tl
            anchors.top: body.bottom
            anchors.topMargin: hasControls ? 10 : 0
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.leftMargin: 10
            anchors.rightMargin: 10
            height: 40
            value: self.position
            maximumValue: self.duration
            minimumValue: 0
            status: self.status
            onStatusChanged: show(status == "pause");
            currentTimeLabel: Formatter.hms(value / 1000)
            endTimeLabel: maximumValue ? Formatter.hms(maximumValue / 1000) : ""
            nameLabel: name
        }
    }

    function show(permanent, bodyToo)
    {
        if (!shown || (bodyToo && body.opacity == 0))
            body.opacity = hasControls && bodyToo ? 1 : 0;
        if (body.opacity == 1)
            col.focus = true

        if (permanent !== undefined)
            self.permanent = permanent;
        autoHideTimer.restart()
    }

    function hide()
    {
        self.permanent = false;
        autoHideTimer.stop();
    }

    property bool permanent: false
    shown: autoHideTimer.running || permanent || tl.status == "loading"
    onShownChanged: {
        if (shown) {
            if (body.opacity == 1)
                col.focus = true
            else
                vsc.focus = true
        } else {
            vsc.focus = true
        }
    }

    function mkStatus(sd, ms, ps)
    {
        if (sd < 0)
            return "rew";

        if (sd > 0)
            return "ff";

        switch (ms) {
        case "loading":
        case "buffering":
            switch (ps) {
            case "pause": return "loading";
            case "stop": return "loading";
            case "play": return "play";
            }
        case "ready":
            switch (ps) {
            case "pause": return "pause";
            case "stop": return "stop";
            case "play": return "play";
            }
        }
        return "stop";
    }

    Timer {
        id: autoHideTimer
        interval: 5000
    }

    onNameChanged: show()

    Keys.onPressed: {
        switch (event.key) {
        case Qt.Key_Return:
            event.accepted = true;
            show();
            break;
        case Qt.Key_Back:
            if (self.shown) {
                event.accepted = true;
                hide();
            }
            break;
        case Qt.Key_Help:
            event.accepted = true;
            if (self.shown) {
                if (self.hasControls && body.opacity == 0) {
                    show(true, true);
                } else {
                    hide();
                }
            } else {
                show(true, true);
            }
            break;
        }
    }
}
