import QtCore
import QtQuick
import QtQuick.Controls
import QtQuick.Dialogs
import MaterialRally as Rally
import pTouch

Dialog {

    id: control

    //readonly property ItemGrabResult grabResult: null
    function showImage(url) {
        image.source = url
        console.log("---- " + image.sourceSize.height)
    }

    Image {
        id: image
        height: 36 * Screen.pixelDensity //(25.4 * image.sourceSize.height * Screen.pixelDensity) / 180
        anchors.centerIn: parent
    }
}
