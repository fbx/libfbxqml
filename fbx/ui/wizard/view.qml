import QtQuick 2.0
import fbx.ui.controller 1.0

TransitionManager {
    id: self

    signal done
    signal cancelled
    signal error

    property QtObject model
    property int count: model.count
    property int currentIndex: -1
    property alias tip: self.currentItem

    property var commonProperties: ({})

    function next()
    {
        if (currentIndex + 1 < count)
            switchTo(currentIndex + 1)
        else
            done();
    }

    function prev()
    {
        if (currentIndex > 0)
            switchTo(currentIndex - 1)
        else
            cancelled();
    }

    function setTo(i)
    {
        if (i >= 0 && i < count)
            switchTo(i)
    }

    Connections {
        target: tip
        ignoreUnknownSignals: true
        onError: self.error();
        onDone: self.next();
        onCancel: self.prev();
        onReset: self.setTo(0);
        onEnd: self.done();
        //onSetTo: self.setTo(index); //why crash ?
    }

    function switchTo(index)
    {
        if (index == -1) return
        if (model.count <= index) return

        var animation = self.currentIndex < index ? "slideLeft" : "slideRight";

        if (index == -1)
            animation = "appear";

        if (index == -1)
            animation = "fade";

        var info = model.get(index);
        var args = {};

        for (var k in info) {
            if (k == "url")
                continue;
            args[k] = info[k];
        }

        for (var k in commonProperties) {
            args[k] = commonProperties[k];
        }

        args.index = index;
        var c = 0;
        for (var i = 0; i < model.count; i++) {
            if (model.get(i).noDisplayCount)
                continue
            c++
        }
        args.count = c;

        self.switchToUrl(info.url, args, animation).then(function (x) {
            self.currentIndex = index;
        });
    }

    Component.onCompleted: self.switchTo(currentIndex);
    onModelChanged: self.switchTo(currentIndex);
}
