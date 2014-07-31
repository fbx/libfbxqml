.import fbx.async 1.0 as Async
.import "animation.js" as Animation

var factory = new Async.Component.Factory(null);

function baseUrl()
{
    var url = widget.baseUrl;

    var index = url.lastIndexOf("/");
    if (index >= 0)
        return url.substr(0, index + 1);
    else
        return url + "/";
}

function absUrl(url)
{
    var pos = url.search("://");

    if (pos < 5 && pos > 0)
        return url;

    if (url.substr(0,1) == "/")
        return url;

    return baseUrl() + url;
}

function FrameAnimation(frame, next_state)
{
    this.frame = frame;
    this.frame.animate(next_state);
}

FrameAnimation.prototype.reparentItem = function()
{
    var i = this.frame.item;

    if (!i || this.frame.autoDelete)
        return null;

    this.frame.item = null;

    i.parent = null;
    return i;
};

FrameAnimation.prototype.cleanup = function()
{
    if (this.frame.item)
        this.frame.item.destroy();

    this.frame.destroy();
    this.frame = null;
};

var currentFrame = null;
var reanimate = null;
var pendingAnimation;

function cleanup(al)
{
    if (al.next) {
        if (al.next.frame.item)
            al.next.frame.item.focus = true;
        al.next.frame.focus = true;
        widget.currentItem = al.next.frame.item;
        currentFrame = al.next.frame;
    } else {
        widget.currentItem = null;
        currentFrame = null;
    }

    if (al.current)
        widget.previousItem = al.current.reparentItem();

    widget.nextItem = null;
    widget.didSwitchItems();
    widget.previousItem = null;

    if (al.current)
        al.current.cleanup();

    pendingAnimation = null;

    if (reanimate) {
        var r = reanimate;
        reanimate = null;

        return animate(r.item, "fade", r.autoDelete, 50);
    }
}

function animate(item, animation, autoDelete, duration)
{
    if (pendingAnimation) {
        if (reanimate && reanimate.autoDelete && reanimate.item)
            reanimate.item.destroy();

        reanimate = {
            item: item,
            animation: animation,
            autoDelete: autoDelete
        }

        return pendingAnimation;
    }

    duration = duration || widget.duration
    var sourceState = Animation.animationSourceState(animation);
    var destinationState = Animation.animationDestinationState(animation);
    var frame = null;

    pendingAnimation = tq.wait(duration)

    if (item) {
        var frameProps = {
            autoDelete: !!autoDelete,
            item: item,
            duration: duration
        };

        Animation.applyState(frameProps, widget.width, widget.height, sourceState);

        frame = frameComponent.createObject(widget, frameProps);

        try {
            item.parent = frame;
        } catch (e) {}

        if (item.anchors)
            item.anchors.fill = frame;
    }

    widget.nextItem = item;
    widget.willSwitchItems();

    focusPlaceholder.focus = true;

    // Attach animation on frame to destroy, or on next one if no prev
    pendingAnimation.thenReturn({
        current: currentFrame ? new FrameAnimation(currentFrame, destinationState) : null,
        next: frame ? new FrameAnimation(frame, "main") : null
    }).then(cleanup);

    return pendingAnimation;
};

function switchToItem(item, animation, autoDelete)
{
    return animate(item, animation, autoDelete);
}

function switchToComponent(component, args, animation)
{
    return new Async.Component.Incubator(component, null, args).then(function(element) {
        return switchToItem(element, animation, true);
    });
}

function switchToUrl(url, args, animation)
{
    return factory.get(absUrl(url), widget).then(function (component) {
        return switchToComponent(component, args, animation)
    }, function (err) {
        console.log("TransitionManager unable to load", url);
        console.log(err);
        return animate(null, animation, true).then(function (x) {
            return err;
        });
    });
}
