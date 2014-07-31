var stack = [];
var inited = false;

function init()
{
    //console.log("menu init", menu.root)
    inited = true;

    if (menu.root)
        push(menu.root);
}

function resetRoot()
{
    if (!inited)
        return;

    //console.log("menu resetRoot", menu.root)
    if (stack.length)
        stack = [menu.root];
    rewind();
}

function push(item)
{
    if (!inited)
        return;

    //console.log("menu push", item)
    if (stack.length == 0) {
        tm.switchToItem(item, "appear");
    } else {
        tm.switchToItem(item, "slideLeft");
    }
    item.menu = menu;
    stack.push(item);
}

function rewind()
{
    if (!inited)
        return;

    //console.log("menu rewind", menu.root, stack.length)
    if (stack.length == 0 && menu.root)
        return push(menu.root);

    if (tm.currentItem)
        tm.currentItem.currentIndex = 0;

    stack = [menu.root];
    if (tm.currentItem !== menu.root) {
        tm.switchToItem(menu.root, "appear");
        try {
            if (menu.root) {
                menu.root.menu = menu || null;
                menu.root.currentIndex = 0;
            }
        } catch (e) {}
    }
}

function pop()
{
    if (!inited)
        return false;

    //console.log("menu pop", stack.length)
    if (stack.length <= 1)
        return false;

    if (tm.currentItem)
        tm.currentItem.currentIndex = 0;

    stack.pop();
    stack[stack.length - 1].menu = menu;
    tm.switchToItem(stack[stack.length - 1], "slideRight");
    return true;
}
