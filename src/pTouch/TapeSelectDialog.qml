import QtCore
import QtQuick
import QtQuick.Controls
import QtQuick.Dialogs
import MaterialRally as Rally
import pTouch

Dialog {

    id: control

    signal newDocument(int tapeWidthPx)

    anchors.centerIn: parent

    onAboutToShow: {

        const tapeIndex = tapeSelect.indexOfValue(
                            PrinterManager.printer.tapeWidthPx)
        if (tapeIndex >= 0) {
            tapeSelect.currentIndex = tapeIndex
        } else {
            tapeSelect.currentIndex = 0
        }
    }

    onAccepted: {
        control.newDocument(tapeSelect.currentValue)
    }

    Column {

        spacing: 20

        Label {
            text: qsTr("Select a tape size") + ":"
            width: control.availableWidth
            wrapMode: Text.WordWrap
        }

        ComboBox {

            id: tapeSelect

            TapeModel {
                id: tapeModel
            }

            model: tapeModel
            textRole: "name"
            valueRole: "tapeWidthPx"
            width: control.availableWidth
            displayText: (PrinterManager.printer.ready
                          && PrinterManager.printer.tapeWidthPx
                          === currentValue) ? currentText + " (" + qsTr(
                                                  "loaded in printer") + ")" : currentText
            delegate: ItemDelegate {
                text: (PrinterManager.printer.ready
                       && PrinterManager.printer.tapeWidthPx
                       === tapeWidthPx) ? name + " (" + qsTr(
                                              "loaded in printer") + ")" : name
                width: parent.width
            }
        }

        Rally.IconLabel {
            icon.name: "alert"
            icon.color: "orange"
            visible: PrinterManager.printer.ready
                     && tapeSelect.currentValue !== PrinterManager.printer.tapeWidthPx
            text: qsTr("does not match the tape loaded in the printer!")
        }
    }

    standardButtons: Dialog.Ok | Dialog.Cancel
}
