import QtQuick 2.0

FocusScope {
    id: self

    property var persistentProperties: []

    function serialize() {
        var ret = {};

        for (var k in self.persistentProperties) {
            var name = self.persistentProperties[k];

            try {
                ret[name] = self[name];
            } catch (e) {
            }
        }

        return JSON.stringify(ret);
    }
}
