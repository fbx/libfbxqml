import QtQuick 2.0
import "component_list_model.js" as Priv

QtObject {
    id: self

    property QtObject titleList: ListModel {
        id: titleList
        ListElement {
            title: "" // Placeholder for static Roles
        }
    }

    property alias count: titleList.count
    property int topCount: 0
    property int cacheSize
    property string baseUrl: "./"

    signal updated()

    function getProperty(i, name)
    {
        return Priv.getProperty(i, name);
    }

    function push(url, defaults, title)
    {
        Priv.push(url.toString(), defaults, title);
        Priv.commit();
    }

    function pushMany(all)
    {
        for (var i = 0; i < all.length; ++i) {
            Priv.push(all[i].url.toString(), all[i].defaults, all[i].title);
        }
        Priv.commit();
    }

    function replaceAll(all)
    {
        Priv.popTo(-1);
        pushMany(all)
    }

    function pop()
    {
        if (count == 0)
            return;

        Priv.pop();
        Priv.commit();
    }

    function popTo(index)
    {
        if (count <= index + 1)
            return;

        Priv.popTo(index);
        Priv.commit();
    }

    function replace(url, defaults, title)
    {
        Priv.pop();
        return push(url, defaults, title);
    }

    function replaceAt(index, url, defaults, title)
    {
        Priv.popTo(index - 1);
        return push(url, defaults, title);
    }

    function element(index, parent)
    {
        return Priv.element(index, parent);
    }

    function cleanup()
    {
        return Priv.gc();
    }
}
