import QtCore
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Dialogs
import MaterialRally as Rally
import pTouch

Dialog {

    id: control

    title: qsTr("Preview")

    anchors.centerIn: parent

    property var grabResult: null

    readonly property var image: grabResult ? grabResult.image : null
    readonly property var imageUrl: grabResult ? grabResult.url : null

    contentWidth: Math.max(printerImage.implicitWidth, 300)
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
            Layout.fillWidth: true
            text: qsTr("Dithering")
            Layout.row: 2
        }

        RowLayout {

            Layout.fillWidth: true
            visible: printerImage.implicitHeight !== PrinterManager.printer.tapeWidthPx

            Rally.Icon {

                icon.name: "alert"
                icon.color: "red"
            }

            Label {

                Layout.fillWidth: true
                text: qsTr("The label cannot be printed. It does not match the tape inserted in the printer (%1 mm). Please insert a tape with a size of %2 mm.").arg(
                          PrinterManager.printer.tapeWidthMm).arg(PrinterManager.getTapeMm(printerImage.implicitHeight))
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
                PrinterManager.print(printerImage.getTransformedImage())
            }
        }

        Button {

            text: qsTr("Cancel")
            flat: true
            DialogButtonBox.buttonRole: DialogButtonBox.RejectRole
        }
    }
}
