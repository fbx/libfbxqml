import fbx.ui.control 1.0
import fbx.ui.menu 1.0
import fbx.data 1.0
import fbx.async 1.0
import fbx.os.mms 1.0
import QtQuick 2.3 // Override fqw.menu.Item

FocusScope {
    id: self

    /*readonly*/ property string preserveAspectFit: "letterbox"
    /*readonly*/ property string preserveAspectCrop: "panscan"
    /*readonly*/ property string stretch: "fullscreen"
    /*readonly*/ property string anamorphic: "anamorphic"

    signal error(string error, bool fatal)

    property alias source: mms.url
    property alias purpose: mms.purpose
    property alias metadata: mms.metadata
    property alias status: mms.status

    property alias playbackState: mms.playbackState
    property alias mediaState: mms.mediaState

    property alias subtitleUrl: mms.subtitleUrl

    property alias position: mms.interpolatedPosition
    property alias duration: mms.duration

    property alias mute: mms.mute
    property alias volume: mms.volume
    property alias autoplay: mms.autoplay

    property alias parentalRating: mms.morality
    property alias parentalLock: mms.parentalLock

    property alias fillMode: mms.scalingMode

    property alias audioList: mms.audioList
    property alias videoList: mms.videoList
    property alias subtitleList: mms.subtitleList
    property alias currentAudioIndex: mms.currentAudioIndex
    property alias currentVideoIndex: mms.currentVideoIndex
    property alias currentSubtitleIndex: mms.currentSubtitleIndex

    property alias debug: mms.debug

    signal videoListUpdated()
    signal audioListUpdated()
    signal subtitleListUpdated()

    signal firstPicture(bool fake);

    onSourceChanged: self.parentalRating = 16;
    onPurposeChanged: self.parentalRating = 16;

    function urlOpen(url, properties)
    {
        var args = [];
        url = url.toString();

        if (properties) {
            var pos = url.lastIndexOf("#");
            if (pos >= 0)
                url = url.substr(0, pos);

            var qd = new Http.Http.QueryDict(properties);
            var s = qd.toString(",");
            if (s)
                url = url + "#" + s
        }

        mms.url = url;
    }

    function close()
    {
        mms.close();
    }

    function play(position)
    {
        mms.play(position);
    }

    function pause()
    {
        mms.pause();
    }

    function playPause()
    {
        mms.togglePlay();
    }

    function stop()
    {
        mms.stop();
    }

    function seek(position, unit, whence)
    {
        mms.seek(position, unit, whence);
    }

    property Mms mms: mms

    Mms {
        id: mms

        purpose: "main"

        onMediaStateChanged: if (mediaState == "ended") self.ended()

        onFirstPicture: self.firstPicture(fake)

        onCurrentVideoIndexChanged: videoSelector.value = currentVideoIndex
        onCurrentAudioIndexChanged: audioSelector.value = currentAudioIndex
        onCurrentSubtitleIndexChanged: subtitleSelector.value = currentSubtitleIndex

        onVideoListUpdated: self.videoListUpdated();
        onAudioListUpdated: self.audioListUpdated();
        onSubtitleListUpdated: self.subtitleListUpdated();

        onError: self.error(error, fatal);
    }

    signal ended()

    property bool streamMenuVideo : true
    property Menu streamMenu: Menu {
        id: formatMenu
        title: "Langues et sous-titres"

        Section {
            text: "Vidéo"
            visible: streamMenuVideo
        }

        Repeater {
            model: mms.videoList


            CheckBox {
                id: videoCheckBox
                visible: streamMenuVideo
                exclusiveGroup: model && videoSelector
                text: model.codec + (model.width ? (", " + model.width + "x" + model.height) : "")
                value: model.index
                onClicked: mms.currentVideoIndex = model.index
                checked: mms.currentVideoIndex == model.index
                Connections {
                    target: mms
                    onCurrentVideoIndexChanged: videoCheckBox.checked = (mms.currentVideoIndex == model.index)
                }
            }
        }

        Section {
            text: "Audio"
            visible: mms.audioList.count > 0
        }

        Repeater {
            model: mms.audioList

            CheckBox {
                id: audioCheckBox
                exclusiveGroup: model && audioSelector
                text: Iso639.lookup(model.language) + ", " + (model.codec || "Inconnu")
                value: model.index
                onClicked: mms.currentAudioIndex = model.index
                checked: mms.currentAudioIndex == model.index
                visible: !!model
                Connections {
                    target: mms
                    onCurrentAudioIndexChanged: audioCheckBox.checked = (mms.currentAudioIndex == model.index)
                }
            }
        }

        Section {
            text: "Sous-titres"
        }

        CheckBox {
            id: noSubtitleCheckBox
            exclusiveGroup: subtitleSelector
            text: "Pas de sous-titre"
            value: -1
            onClicked: mms.currentSubtitleIndex = -1
            checked: mms.currentSubtitleIndex == -1
            Connections {
                target: mms
                onCurrentSubtitleIndexChanged: noSubtitleCheckBox.checked = (mms.currentSubtitleIndex == -1)
            }
        }

        Repeater {
            model: mms.subtitleList

            CheckBox {
                id: subtitleCheckBox
                exclusiveGroup: subtitleSelector
                text: model.language == "frf" ? "Français forcé" : Iso639.lookup(model.language)
                value: model.index
                onClicked: mms.currentSubtitleIndex = model.index
                checked: mms.currentSubtitleIndex == model.index
                Connections {
                    target: mms
                    onCurrentSubtitleIndexChanged: {
                        subtitleCheckBox.checked = (mms.currentSubtitleIndex == model.index)
                    }
                }
            }
        }
    }


    CheckableGroup {
        id: videoSelector
    }

    CheckableGroup {
        id: audioSelector
    }

    CheckableGroup {
        id: subtitleSelector
    }
}
