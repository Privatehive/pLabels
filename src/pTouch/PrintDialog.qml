import QtCore
import QtQuick
import QtQuick.Controls
import QtQuick.Dialogs
import MaterialRally as Rally
import pTouch

Dialog {

    id: control

    title: qsTr("Print")

    anchors.centerIn: parent

    property var grabResult: null

    readonly property var image: grabResult ? grabResult.image : null
    readonly property var imageUrl: grabResult ? grabResult.url : null

    Image {
        id: image
        source: control.imageUrl
        anchors.centerIn: parent

        Rectangle {
            anchors.fill: image
            z: -1
            color: "white"
        }
    }

    footer: DialogButtonBox {

        Button {
            text: qsTr("Print")
            flat: true
            onClicked: {
                PrinterManager.print(control.image)
            }
        }

        Button {
            text: qsTr("Cancel")
            flat: true
            DialogButtonBox.buttonRole: DialogButtonBox.RejectRole
        }
    }
}
