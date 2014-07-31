import QtQuick 2.0

Image {
    property string country: "no_flag"
    fillMode: Image.PreserveAspectFit
    smooth: true
    source: "flag/" + (basename || "no_flag") + ".png"
    property string basename: country;
    onCountryChanged: {
        basename = country;
    }
    onStatusChanged: {
        if (status == Image.Error)
            basename = "no_flag";
    }
}
