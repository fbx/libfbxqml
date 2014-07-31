var watchedProperties = [];
var watchedItems = [];
var watchedTarget = null;

var parentToken = {isParent: true};
var nonParentToken = {isParent: false};

function childPropertyChanged()
{
    var token = this;

    if (token.isParent)
        restart();

    self.someChildrenChanged();
}

function childrenChanged()
{
    restart();

    self.someChildrenChanged();
}

function restart()
{
    stop();
    start();
}

function start()
{
    if (!self.target)
        return;

    watchedTarget = self.target;
    watchedItems = watchedTarget.children;
    watchedProperties = self.watchedProperties;

    for (var i = 0; i < watchedItems.length; ++i) {
        var child = watchedItems[i];

        for (var j = 0; j < watchedProperties.length; ++j) {
            var propName = watchedProperties[j];
            var prop = child[propName + "Changed"];
            var token = propName == "parent" ? parentToken : nonParentToken;

            prop.connect(token, childPropertyChanged);
        }
    }

    self.target.childrenChanged.connect(nonParentToken, childrenChanged);
}

function stop(item)
{
    if (!watchedTarget)
        return;

    watchedTarget.childrenChanged.disconnect(nonParentToken, childrenChanged);

    for (var i = 0; i < watchedItems.length; ++i) {
        var child = watchedItems[i];

        for (var j = 0; j < watchedProperties.length; ++j) {
            var propName = watchedProperties[j];
            var prop = child[propName + "Changed"];
            var token = propName == "parent" ? parentToken : nonParentToken;

            prop.disconnect(token, childPropertyChanged);
        }
    }

    watchedTarget = null;
    watchedProperties = [];
    watchedItems = [];
}
