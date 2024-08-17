import QtQuick.Controls
import QtQuick.Dialogs
import QtQuick.Layouts
import pTouch

Dialog {

    id: control

    anchors.centerIn: parent

    contentWidth: 300

    title: qsTr("Printer")

    GridLayout {

        anchors.fill: parent
        columns: 2

        Label {
            text: qsTr("Name:")
            font.bold: true
        }

        Label {
            text: PrinterManager.printer.name
        }

        Label {
            text: qsTr("ID:")
            font.bold: true
        }

        Label {
            text: PrinterManager.printer.id
        }

        Label {
            text: qsTr("Tape:")
            font.bold: true
        }

        Label {
            text: PrinterManager.printer.tapeWidthMm + " mm, " + PrinterManager.printer.tapeWidthPx + " px"
        }
    }

    standardButtons: MessageDialog.Ok
}
