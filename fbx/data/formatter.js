.pragma library

//
// utility functions
//
function number(number, decimals, dec_point, thousands_sep)
{
    var n = number, c = isNaN(decimals = Math.abs(decimals)) ? 2 : decimals;
    var d = dec_point == undefined ? "," : dec_point;
    var t = thousands_sep == undefined ? "." : thousands_sep, s = n < 0 ? "-" : "";
    var i = parseInt(n = Math.abs(+n || 0).toFixed(c)) + "", j = (j = i.length) > 3 ? j % 3 : 0;

    return s + (j ? i.substr(0, j) + t : "") +
        i.substr(j).replace(/(\d{3})(?=\d)/g, "$1" + t) +
        (c ? d + Math.abs(n - i).toFixed(c).slice(2) : "");
}

function int_zero(x, n)
{
    var l = "" + x;
    var r = "0000000000" + (x || 0);
    return r.substr(r.length - Math.max(n, l.length));
}

function size_i(filesize)
{
    if (filesize == null)
        return null;
    if (filesize >= 1099511627776)
	return number(filesize / 1099511627776, 2, ',', '') + ' Tio';
    if (filesize >= 1073741824)
        return number(filesize / 1073741824, 2, ',', '') + ' Gio';
    if (filesize >= 1048576)
        return number(filesize / 1048576, 2, ',', '') + ' Mio';
    if (filesize >= 1024)
        return number(filesize / 1024, 0) + ' Kio';
    return number(filesize, 0) + ' octets';
}

function size(filesize)
{
    if (filesize == null)
        return null;
    if (filesize >= 1000000000000)
	return number(filesize / 1000000000000, 2, ',', '') + ' To';
    if (filesize >= 1000000000)
        return number(filesize / 1000000000, 2, ',', '') + ' Go';
    if (filesize >= 1000000)
        return number(filesize / 1000000, 2, ',', '') + ' Mo';
    if (filesize >= 1000)
        return number(filesize / 1000, 0) + ' Ko';
    return number(filesize, 0) + ' octets';
}

function rate(rate, shorten)
{
    if (rate == null)
        return null;
    if (rate >= 1000000000)
        return number(rate / 1000000000, 2, ',', ' ') + ' Go/s';
    if (rate >= 1000000)
        return number(rate / 1000000, 2, ',', ' ') + ' Mo/s';
    if (rate >= 1000)
        return number(rate / 1000, 0) + ' Ko/s';
    if (shorten)
        return number(rate, 0) + ' o/s';
    else
        return number(rate, 0) + ' octet/s';
}

function bitrate(rate)
{
    if (rate == null)
        return null;
    if (rate >= 1000000000)
        return number(rate / 1000000000, 2, ',', ' ') + ' Gbit/s';
    if (rate >= 1000000)
        return number(rate / 1000000, 2, ',', ' ') + ' Mbit/s';
    if (rate >= 1000)
        return number(rate / 1000, 0) + ' Kbit/s';
    return number(rate, 0) + ' bit/s';
}

function min_to_msecs(value) {
    return (value * 60 * 1000);
}

function uptime(uptime, simplified)
{
    var nOfDays = Math.floor(uptime / (60*60*24));
    uptime = uptime - nOfDays * 60 * 60 * 24;
    var nOfHours = Math.floor(uptime / (60*60));
    uptime = uptime - nOfHours * 60 * 60;
    var nOfMinutes = Math.floor(uptime / 60);
    uptime = uptime - nOfMinutes * 60;
    var nOfSeconds = Math.floor(uptime);

    var ret = [];

    var tString = [];

    if (nOfDays > 0)
        tString.push(nOfDays + (simplified ? " j": (" jour" + ((nOfDays>1) ? "s":""))));

    if (nOfHours > 0)
        tString.push(nOfHours + (simplified ? " h": (" heure" + ((nOfHours>1) ? "s":""))));

    if (nOfMinutes > 0)
        tString.push(nOfMinutes + (simplified ? " min": (" minute" + ((nOfMinutes>1) ? "s":""))));

    if (nOfSeconds > 0)
        tString.push(nOfSeconds + (simplified ? " sec": (" seconde" + ((nOfSeconds>1) ? "s":""))));

    return tString.join(", ");
}

function hms(timeToFormat)
{
    if (timeToFormat < 0)
        return "--:--:--";

    var h = Math.floor(timeToFormat / (60*60));
    if (h<10) h="0"+h;

    var m = Math.floor((timeToFormat / 60) % 60);
    if (m<10) m="0"+m;

    var s = Math.floor(timeToFormat % 60);
    if (s<10) s="0"+s;

    return ""+h+":"+m+":"+s;
}

function mac(m) {
    var t = []
    for (var i in m)
        t.push((0x100 + m[i]).toString(16).substr(1));
    return t.join(":").toUpperCase();
}

function mac2Tab (m) {
    var t = m.split(":")
    for (var i = 0; i < t.length; i++) {
        t[i] = parseInt(t[i],16)
    }
    return t
}

function ipv4(ip) {
    var nibble = [];

    for (var i = 0; i < 3; ++i)
        nibble[i] = (ip >> (i * 8)) & 0xff;

    return nibble[0] + "." + nibble[1] + "." + nibble[2] + "." + nibble[3];
}

function date(timestamp, datePrefix, formatDate)
{
    var d = new Date();
    d.setTime(timestamp * 1000);

    var today = new Date();
    var tomorrow = new Date();
    var yesterday = new Date();

    tomorrow.setDate(tomorrow.getDate() + 1);
    yesterday.setDate(yesterday.getDate() - 1);

    if (d.getDate() == today.getDate()
        && d.getMonth() == today.getMonth()
        && d.getFullYear() == today.getFullYear())
        return "aujourd'hui";

    if (d.getDate() == tomorrow.getDate()
        && d.getMonth() == tomorrow.getMonth()
        && d.getFullYear() == tomorrow.getFullYear())
        return "demain";

    if (d.getDate() == yesterday.getDate()
        && d.getMonth() == yesterday.getMonth()
        && d.getFullYear() == yesterday.getFullYear())
        return "hier";

    return (datePrefix ? (datePrefix + " ") : "") + Qt.formatDate(d, formatDate || "ddd d MMM yyyy");
}

function time(timestamp)
{
    var d = new Date();
    d.setTime(timestamp * 1000);

    return Qt.formatTime(d, "hh'h'mm");
}

function duration(seconds, format)
{
    if (!format) format = "dhm"

    var days = format.indexOf("d") >= 0 ? parseInt(seconds / (3600 * 24)) : 0;
    var remainingSeconds = seconds - days * 3600 * 24;
    var hours = parseInt(remainingSeconds / 3600);
    remainingSeconds -= hours * 3600;
    var minutes = parseInt(remainingSeconds / 60);

    var ret = [];
    if (days)
        ret.push(days + "j");
    if (hours)
        ret.push(hours + "h");
    if (minutes)
        ret.push(minutes + "m");

    return ret.join(" ");
}

function enumeration(list)
{
    var end = list.pop();

    if (list.length)
        return list.join(", ") + " et " + end;
    else
        return end;
}

function capitalize(string)
{
    return string.charAt(0).toUpperCase() + string.slice(1);
}

function weekdays(monday, tuesday, wednesday, thursday, friday, saturday, sunday, shorten)
{
    if (monday && tuesday && wednesday && thursday && friday && saturday && sunday)
        return "tous les jours";
    if (!monday && !tuesday && !wednesday && !thursday && !friday && !saturday && !sunday)
        return "jamais";
    if (monday && tuesday && wednesday && thursday && friday && !saturday && !sunday)
        return "la semaine";
    if (!monday && !tuesday && !wednesday && !thursday && !friday && saturday && sunday)
        return "le week-end";

    var days = [];
    var notdays = [];
    (monday ? days : notdays).push(shorten ? "lun" : "lundi");
    (tuesday ? days : notdays).push(shorten ? "mar" : "mardi");
    (wednesday ? days : notdays).push(shorten ? "mer" : "mercredi");
    (thursday ? days : notdays).push(shorten ? "jeu" : "jeudi");
    (friday ? days : notdays).push(shorten ? "ven" : "vendredi");
    (saturday ? days : notdays).push(shorten ? "sam" : "samedi");
    (sunday ? days : notdays).push(shorten ? "dim" : "dimanche");

    if (notdays.length == 1)
        return "tous les jours sauf le " + notdays[0];
    if (notdays.length == 2)
        return "tous les jours sauf " + notdays[0] + " et " + notdays[1];

    return "le " + enumeration(days);
}
