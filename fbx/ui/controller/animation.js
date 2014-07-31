.pragma library

function animationSourceState(animation)
{
    switch (animation) {
        case "slideRight": return "left";
        case "slideLeft": return "right";
        case "slideRightFade": return "leftFade";
        case "slideLeftFade": return "rightFade";
        case "slideUp": return "down";
        case "slideDown": return "up";
        case "slideUpFade": return "downFade";
        case "slideDownFade": return "upFade";
        case "circleRight": return "cleft";
        case "circleLeft": return "cright";
        case "scaleUp": return "shrunk";
        case "scaleDown": return "magnified";
        case "fade": return "transparent";
        case "appear": return "hidden";
        default: return "left";
    }
}

function animationDestinationState(animation)
{
    switch (animation) {
        case "slideRight": return "right";
        case "slideLeft": return "left";
        case "slideRightFade": return "rightFade";
        case "slideLeftFade": return "leftFade";
        case "slideUp": return "up";
        case "slideDown": return "down";
        case "slideUpFade": return "upFade";
        case "slideDownFade": return "downFade";
        case "circleRight": return "cright";
        case "circleLeft": return "cleft";
        case "scaleUp": return "magnified";
        case "scaleDown": return "shrunk";
        case "fade": return "transparent";
        case "appear": return "hidden";
        default: return "right";
    }
}

function animationReverse(animation)
{
    switch (animation) {
        case "slideRight": return "slideLeft";
        case "slideLeft": return "slideRight";
        case "slideRightFade": return "slideLeftFade";
        case "slideLeftFade": return "slideRightFade";
        case "slideUp": return "slideDown";
        case "slideDown": return "slideUp";
        case "slideUpFade": return "slideDownFade";
        case "slideDownFade": return "slideUpFade";
        case "circleRight": return "circleLeft";
        case "circleLeft": return "circleRight";
        case "scaleUp": return "scaleDown";
        case "scaleDown": return "scaleUp";
        default: return animation;
    }
}

function animationProperties(state)
{
    switch (state) {
        case "main":
        return {
            xWidthScale: 0,
            yHeightScale: 0,
            opacity: 1,
            scale: 1,
            angle: 0,
            visible: true
        };

        case "left":
        return {
            xWidthScale: -1
        };

        case "right":
        return {
            xWidthScale: 1
        };

        case "leftFade":
        return {
            xWidthScale: -1,
            opacity: 0
        };

        case "rightFade":
        return {
            xWidthScale: 1,
            opacity: 0
        };

        case "up":
        return {
            yHeightScale: -1
        };

        case "down":
        return {
            yHeightScale: 1
        };

        case "upFade":
        return {
            yHeightScale: -1,
            opacity: 0
        };

        case "downFade":
        return {
            yHeightScale: 1,
            opacity: 0
        };

        case "cleft":
        return {
            xWidthScale: -1,
            angle: -90,
            opacity: 0
        };

        case "cright":
        return {
            xWidthScale: 1,
            angle: 90,
            opacity: 0
        };

        case "shrunk":
        return {
            scale: .8,
            opacity: 0
        };

        case "magnified":
        return {
            scale: 1.2,
            opacity: 0
        };

        case "transparent":
        return {
            opacity: 0
        };

        case "hidden":
        return {
            visible: false
        };

    }

    return {};
}

function applyState(item, width, height, state)
{
    var transforms = animationProperties(state);

    for (var i in transforms) {
        var val = transforms[i];
        if (i == "xWidthScale")
            item["x"] = val * width;
        else if (i == "yHeightScale")
            item["y"] = val * height;
        else
            item[i] = val;
    }
}
