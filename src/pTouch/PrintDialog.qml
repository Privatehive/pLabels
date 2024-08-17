import QtCore
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import MaterialRally as Rally
import pTouch

Dialog {

    id: control

    anchors.centerIn: parent

    title: qsTr("Preview")

    property var grabResult: null

    readonly property var image: grabResult ? grabResult.image : null
    readonly property var imageUrl: grabResult ? grabResult.url : null

    contentWidth: Math.min(Math.max(printerImage.implicitWidth, 300), 600)
    margins: 50

    GridLayout {

        anchors.fill: parent
        columns: 1

        Flickable {

            id: flick
            Layout.fillWidth: true
            Layout.row: 0
            implicitHeight: printerImage.implicitHeight
            contentHeight: printerImage.implicitHeight
            contentWidth: printerImage.implicitWidth
            boundsBehavior: Flickable.StopAtBounds
            clip: true

            PrinterImage {

                id: printerImage
                image: control.image
                dithering: ditheringEnabled.checked
            }

            MouseArea {

                anchors.fill: parent
                cursorShape: Qt.SizeAllCursor
                enabled: false
                visible: flick.ScrollBar.horizontal.policy === ScrollBar.AlwaysOn
            }

            ScrollBar.horizontal: ScrollBar {

                parent: flick.parent
                Layout.fillWidth: true
                Layout.row: 1
                policy: size < 1.0 ? ScrollBar.AlwaysOn : ScrollBar.AlwaysOff
            }
        }

        CheckBox {

            id: ditheringEnabled
            text: qsTr("Dithering")
            Layout.row: 2
        }

        RowLayout {

            Layout.fillWidth: true
            visible: PrinterManager.printer.ready && printerImage.implicitHeight !== PrinterManager.printer.tapeWidthPx

            Rally.Icon {

                icon.name: "alert"
                icon.color: Material.color(Material.Red)
            }

            Label {

                Layout.fillWidth: true
                text: qsTr("The label cannot be printed. It does not match the tape inserted in the printer (%1 mm). Please insert a tape with a size of %2 mm.").arg(
                          PrinterManager.printer.tapeWidthMm).arg(PrinterManager.getTapeMm(printerImage.implicitHeight))
                wrapMode: Text.WordWrap
            }
        }

        RowLayout {

            Layout.fillWidth: true
            visible: !PrinterManager.printer.ready

            Rally.Icon {

                icon.name: "alert"
                icon.color: Material.color(Material.Red)
            }

            Label {

                Layout.fillWidth: true
                text: qsTr("No pTouch printer was found. Make sure the printer is powered on and connected via USB. Also make sure the P-light mode is disabled on the printer or the switch is on position E (depends on model)")
                wrapMode: Text.WordWrap
            }
        }
    }

    footer: DialogButtonBox {

        Button {

            text: qsTr("Print")
            flat: true
            enabled: printerImage.implicitHeight === PrinterManager.printer.tapeWidthPx
            onClicked: {
                enabled = false
                Qt.callLater(() => {
                                 PrinterManager.print(printerImage.getTransformedImage())
                                 enabled = true
                             })
            }
        }

        Button {

            text: qsTr("Cancel")
            flat: true
            DialogButtonBox.buttonRole: DialogButtonBox.RejectRole
        }
    }
}
