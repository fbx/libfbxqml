var items = [];
var selectedItem = null;
var inited = false;
var changingChecks = true;

function candidates()
{
    var c = [];

    for (var i = 0; i < items.length; i++) {
        var item = items[i];

        if (item.enabled)
            c.push(item);
    }

    return c;
}

function valueChanged(v)
{
    if (changingChecks)
        return;

    changingChecks = true;

    var c = candidates();
    var checked = false;

    for (var i = 0; i < c.length; ++i) {
        if (c[i].value === v && !checked) {
            c[i].checked = true;
            checked = true;
        } else {
            c[i].checked = false;
        }
    }

    changingChecks = false;

    if (!checked && !self.canUnselect)
        selectOne();
}

function disconnect(item)
{
    item.exclusiveGroupChanged.disconnect(item, handleExclusiveGroupChanged);
    item.valueChanged.disconnect(item, handleItemChanged);
    item.enabledChanged.disconnect(item, handleItemChanged);
    item.checkedChanged.disconnect(item, handleItemChanged);
}

function connect(item)
{
    item.exclusiveGroupChanged.connect(item, handleExclusiveGroupChanged);
    item.valueChanged.connect(item, handleItemChanged);
    item.enabledChanged.connect(item, handleItemChanged);
    item.checkedChanged.connect(item, handleItemChanged);
}

function add(item)
{
    items.push(item);
    connect(item);

    if (item.enabled && (self.value === item.value || (item.checked && !selectedItem) || (items.length == 1 && !inited))) {
        check(item);
    } else {
        changingChecks = true;
        item.checked = false;
        changingChecks = false;
    }
}

function selectOne()
{
    var c = candidates();

    if (!c.length && items.length && !self.canUnselect)
        console.log("No candidates and no null selection possible !");

    return check(c.length ? c[c.length - 1] : null);
}

function handleExclusiveGroupChanged()
{
    var item = this;

    if (item.checkGroup === self)
        return;

    var index = items.indexOf(item);
    if (index == -1)
        return;

    disconnect(item);
    items.splice(index, 1);

    if (item === selectedItem)
        selectOne();
}

function handleItemChanged()
{
    if (changingChecks)
        return;

    var item = this;

    if (item.checked && item.enabled)
        check(item);
    else if (item == selectedItem) {
        if (self.canUnselect)
            self.check(null);
        else
            selectOne();
    }

    if (item.enabled && !selectedItem)
        selectOne();
}

function check(item)
{
    changingChecks = true;

    if (selectedItem)
        selectedItem.checked = false;

    selectedItem = item;

    if (selectedItem)
        selectedItem.checked = true;

    self.value = item ? item.value : null;

    changingChecks = false;
}

function completed()
{
    inited = true;

    if (selectedItem === null && !self.canUnselect)
        selectOne();

    changingChecks = false;
}
