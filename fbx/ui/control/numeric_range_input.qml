import QtQuick 2.0
import fbx.ui.controller 1.0

Combo {
    id: self

    property int minimumValue: 0
    property int maximumValue: 9
    value: minimumValue

    items: ListModel {
        id: model
    }

    onMinimumValueChanged: reload()
    onMaximumValueChanged: reload()
    Component.onCompleted: reload()

    function reload()
    {
        var v = parseInt(self.value);

        model.clear()

        for (var i = self.minimumValue; i <= self.maximumValue; ++i) {
            var l = Math.max(
                self.minimumValue.toString().length,
                self.maximumValue.toString().length);
            var s = ("00000000" + i.toString()).substr(-l);
            model.append({ value: i, label: s });
        }

        self.valueSet(v);
    }

    Keys.forwardTo: kni

    KeyNumericInput {
        id: kni

        timeout: 1000

        onValueChanged: {
            if (value.length >= self.minimumValue.toString().length
                && value.length >= self.maximumValue.toString().length)
                commit();
        }

        onCommit: {
            for (var i = 0; i < model.count; ++i) {
                if (model.get(i).value == parseInt(value)) {
                    self.select(i);
                    return;
                }
            }
        }
    }
}
