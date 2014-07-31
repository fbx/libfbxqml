import QtQuick 2.0
import "deferred_worker.js" as Script

WorkerScript {
    id: self

    property string script: ""
    source: "deferred_worker_script.js"

    onMessage: Script.onMessage(msg);

    function call(meth, args)
    {
        return Script.doCall(meth, args);
    }

    onScriptChanged: scriptUpdate(script)
    Component.onCompleted: scriptUpdate(script)
}
