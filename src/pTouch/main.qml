import QtQuick
import QtQuick.Controls
import pTouch

ApplicationWindow {
    visible: true

    header: ToolBar {
        Row {
            anchors.fill: parent
            spacing: 2

            ToolButton {
                icon.name: "file"
                display: AbstractButton.IconOnly
            }

            ToolButton {
                icon.name: "folder-open"
                display: AbstractButton.IconOnly
            }

            ToolButton {
                icon.name: "content-save"
                display: AbstractButton.IconOnly
            }

            ToolSeparator {

                height: parent.height
            }

            ToolButton {
                icon.name: "text"
                display: AbstractButton.IconOnly
                onClicked: {
                    editor.addText()
                }
            }

            ToolButton {
                icon.name: "image"
                display: AbstractButton.IconOnly
            }

            ToolButton {
                icon.name: "shape"
                display: AbstractButton.IconOnly
            }

            ToolButton {
                icon.name: "barcode"
                display: AbstractButton.IconOnly
            }
        }

        ToolButton {
            text: PrinterManager.printer.ready ? PrinterManager.printer.name : qsTr(
                                                     "no printer")
            icon.name: PrinterManager.printer.ready ? "printer-check" : "printer-alert"
            icon.color: PrinterManager.printer.ready ? "green" : "red"
            display: PrinterManager.printer.ready ? AbstractButton.TextBesideIcon : AbstractButton.IconOnly
            enabled: false
            anchors.right: parent.right
        }
    }

    Label {
        anchors.centerIn: parent
        visible: !PrinterManager.printer.ready
        text: qsTr("Printer not ready")
    }

    Viewport {
        id: editor
        anchors.fill: parent
        visible: PrinterManager.printer.ready
        tapeWidth: PrinterManager.printer.tapeWidth
    }
}
