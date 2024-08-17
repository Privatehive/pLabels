import QtCore
import QtQuick
import QtQuick.Controls
import QtQuick.Controls.Material
import QtQuick.Layouts
import QtQuick.Dialogs
import MaterialRally as Rally
import pTouch

Dialog {

    id: control

    signal newDocument(int tapeWidthPx)

    anchors.centerIn: parent

    onAboutToShow: {

        const tapeIndex = tapeSelect.indexOfValue(PrinterManager.printer.tapeWidthPx)
        if (tapeIndex >= 0) {
            tapeSelect.currentIndex = tapeIndex
        } else {
            tapeSelect.currentIndex = 0
        }
    }

    onAccepted: {
        control.standardButton(Dialog.Ok).enabled = false
        control.newDocument(tapeSelect.currentValue)
    }

    contentWidth: 300

    title: qsTr("Select tape")

    GridLayout {

        anchors.fill: parent
        columns: 1

        ComboBox {

            id: tapeSelect
            Layout.fillWidth: true

            TapeModel {
                id: tapeModel
            }

            model: tapeModel
            textRole: "name"
            valueRole: "tapeWidthPx"
            displayText: (PrinterManager.printer.ready
                          && PrinterManager.printer.tapeWidthPx === currentValue) ? currentText + " (" + qsTr(
                                                                                        "inserted") + ")" : currentText
            delegate: ItemDelegate {
                text: (PrinterManager.printer.ready
                       && PrinterManager.printer.tapeWidthPx === tapeWidthPx) ? name + " (" + qsTr(
                                                                                    "inserted") + ")" : name
                width: parent.width
            }
        }

        RowLayout {

            Layout.fillWidth: true
            visible: PrinterManager.printer.ready && tapeSelect.currentValue !== PrinterManager.printer.tapeWidthPx

            Rally.Icon {

                icon.name: "alert"
                icon.color: Material.color(Material.Yellow)
            }

            Label {

                Layout.fillWidth: true
                text: qsTr("The selected tape size does not match the inserted tape in the printer (%1 mm).").arg(
                          PrinterManager.printer.tapeWidthMm)
                wrapMode: Text.WordWrap
            }
        }
    }

    standardButtons: Dialog.Ok | Dialog.Cancel
}
