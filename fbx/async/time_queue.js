.import "deferred.js" as Deferred

function Timeout(deadline)
{
    Deferred.Deferred.call(this, function (self) {
        remove(self);
    });

    this.deadline = deadline;
}

Timeout.prototype = new Deferred.Deferred();
Timeout.prototype.constructor = Timeout;

var queue = [];

function remove(to)
{
    var index = queue.indexOf(to);
    if (index < 0)
        return;

    to.queue = null;
    queue.splice(index, 1);
}

function add(to)
{
    queue.push(to);
    queue.sort(function (a, b) { return b.deadline - a.deadline; });
    reschedule();
}

function reschedule()
{
    if (!queue.length)
        return;

    self.interval = Math.max(self.granularity, queue[queue.length - 1].deadline - new Date().getTime());

    self.restart();
}

function run()
{
    var now = new Date().getTime();
    var changed = false;

    while (queue.length) {
        var to = queue[queue.length - 1];

        to.log(to.deadline, now, to.deadline < now + granularity);

        if (to.deadline > now + granularity)
            return to.deadline;

        var to = queue.pop();

        to.resolve("done");
        changed = true;
    }

    return now + 10000;
}

function newTimeout(timeout)
{
    var to = new Timeout(new Date().getTime() + timeout);
    add(to);
    return to;
}
