.pragma library

var Updater = function (get_uuid)
{
    this.elements = [];
    this.get_uuid = get_uuid;
}

Updater.prototype.__get_diff = function (nextData)
{
    var a_new = [];
    var uuids = {};

    for (var i = 0; i < nextData.length; ++i) {
        var e = {};

        for (var k in nextData[i])
            e[k] = nextData[i][k];

        e.__uuid = this.get_uuid(nextData[i]);

        if (uuids[e.__uuid])
            console.error("Multiple items with uuid", e.__uuid);

        uuids[e.__uuid] = true;

        a_new.push(e);
    }

    var i = 0;
    var j = 0;
    var a_old = this.elements;
    var ops = {};

    a_new.sort(function (a, b) {
        if (a.__uuid !== b.__uuid)
            return a.__uuid < b.__uuid ? -1 : 1;
        return 0;
    });

    while (i < a_old.length && j < a_new.length) {
        var o_uuid = a_old[i].__uuid;
        var n_uuid = a_new[j].__uuid;

        if (o_uuid === n_uuid) {
            if (JSON.stringify(a_old[i]) != JSON.stringify(a_new[j])) {
                ops[o_uuid] = { op: "upd", index: j };
            }
            ++j;
            i++;
        } else if (o_uuid < n_uuid) {
            ops[o_uuid] = { op: "del" };
            ++i;
        } else {
            ops[n_uuid] = { op: "add", index: j };
            ++j;
        }
    }

    while (i < a_old.length) {
        var o_uuid = a_old[i].__uuid;
        ops[o_uuid] = { op: "del" };
        ++i;
    }

    while (j < a_new.length) {
        var n_uuid = a_new[j].__uuid;

        ops[n_uuid] = { op: "add", index: j };
        ++j;
    }

    this.elements = a_new;

    return ops;
}

Updater.prototype.__apply_diff = function (diff, model, compare_sort_fn, direct)
{
    //console.log("Updating", model, "from", diff);

    //console.log("Handling deletes / updates");

    for (var i = model.count - 1; i >= 0; --i) {
        var m = model.get(i);
        var d = diff[m.__uuid];

        if (!d)
            continue;

        delete diff[m.__uuid];

        switch (d.op) {
        case "del": {
            //console.log("Removing item at", i, ":", JSON.stringify(m));
            model.remove(i);
            break;
        }

        case "upd": {
            //console.log("Updating item at", i, ":", JSON.stringify(this.elements[d.index]));
            model.set(i, this.elements[d.index]);
        }
        }
    }

    if (!direct)
        model.sync();

    //console.log("Handling moves");

    for (var i = 1; i < model.count; ++i) {
        var a = model.get(i - 1);
        var b = model.get(i);
        var score = compare_sort_fn(a, b);

        if (score <= 0)
            continue;

        // We have ...., a, b, ....
        // This should be ...., b, ..., a, ....

        for (var j = 0; j < i; ++j) {
            var score2 = compare_sort_fn(model.get(j), b);

            if (score2 <= 0)
                continue;

            //console.log("Moving item at", i, " to ", j, j, j + 1, i - j);
            model.move(j, j + 1, i - j);
//            model.move(i, j, 1);
//            model.sync();
            break;
        }
    }

    if (!direct)
        model.sync();

    //console.log("Sorting insertions");

    var to_add = [];
    for (var u in diff) {
        var d = diff[u];

        if (d.op == "add")
            to_add.push(this.elements[d.index]);
    }

    to_add.sort(compare_sort_fn);

    //console.log("Inserting", to_add.length, "elements");

    var idx = 0;
    for (var i in to_add) {
        var o = to_add[i];

        while (idx < model.count && compare_sort_fn(model.get(idx), o) < 0)
            idx++;

        model.insert(idx, o);

        //console.log("-> inserting at", idx, JSON.stringify(o));

        if (!direct)
            model.sync();
    }

    /*
    console.log("Final:");
    for (var i = 0; i < model.count; ++i) {
        var m = model.get(i);
        console.log(i, ": ", m.key, m.section, m.fileName);
    }
    */
}

Updater.prototype.update = function (elements, model, compare_sort_fn, direct)
{
    var diff = this.__get_diff(elements);
    this.__apply_diff(diff, model, compare_sort_fn, direct);
}
