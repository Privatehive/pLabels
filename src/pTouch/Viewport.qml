import QtQuick
import QtQuick.Controls

Control {

    id: asdasdfasdf

    function grabImage(callback) {

        asdasdfasdf.grabToImage(result => {
                                    callback(result)
                                })
    }

    background: Rectangle {
        color: "white"
    }
}
