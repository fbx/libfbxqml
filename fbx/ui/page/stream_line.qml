import QtQuick 2.0
import fbx.ui.layout 1.0
import fbx.ui.controller 1.0

TransitionManager {
    id: self

    signal done
    signal cancelled

    property var model
    property int currentIndex: 0

    property var commonProperties: []

    function next()
    {
        if (currentIndex + 1 < model.count)
            currentIndex++;
        else
            done();
    }

    function zap(dest)
    {
        for (var i = 0; i < model.count; ++i) {
            if (model.get(i).name == dest) {
                currentIndex = i;
                break;
            }
        }

        cancelled();
    }

    function prev()
    {
        if (currentIndex > 0)
            currentIndex--;
        else
            cancelled();
    }

    onCurrentIndexChanged: priv.targetIndex = currentIndex

    Item {
        id: priv
        property int targetIndex: -1
        property int currentIndex: -1
        onTargetIndexChanged: self.switchTo(targetIndex);
        onCurrentIndexChanged: self.switchTo(targetIndex);
    }

    function switchTo(index)
    {
        if (index == priv.currentIndex)
            return;

        var animation = priv.currentIndex < index ? "slideLeft" : "slideRight";

        if (priv.currentIndex == -1)
            animation = "appear";

        if (index == -1)
            animation = "fade";

        var info = model.get(index);
        if (!info) {
            console.warn("Bad index", index)
            return;
        }

        var args = {};

        for (var i in commonProperties) {
            var k = commonProperties[i];
            args[k] = self[k];
        }

        console.log("TM trying to switch from", priv.currentIndex, "to", index, animation);
        self.switchToUrl(info.url, args, animation).then(function (x) {
            console.log("-> Tabs done switching to", index);
            priv.currentIndex = index;
        }, function(err) {
            console.log("Tab switching to", info.url, "failed:", err);
        });
    }

    Component.onCompleted: priv.targetIndex = currentIndex;
}
