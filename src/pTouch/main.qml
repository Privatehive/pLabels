import QtQuick
import QtQuick.Controls
import Qt5Compat.GraphicalEffects
import MaterialRally as Rally
import pTouch

Rally.RallyRootPage {

    id: control

    visible: true

    Component.onCompleted: {

        stackView.replace(Rally.Helper.createItem(Qt.resolvedUrl("Editor.qml"), null, {
                                                      "tapeWidth": 128
                                                  }))
    }

    function newEditor(tapeWidthPx) {

        stackView.replace(Rally.Helper.createItem(Qt.resolvedUrl("Editor.qml"), null, {
                                                      "tapeWidth": tapeWidthPx
                                                  }))
    }

    header: ToolBar {
        Row {
            anchors.fill: parent
            spacing: 2

            ToolButton {
                icon.name: "file"
                display: AbstractButton.IconOnly
                onClicked: {
                    const dialog = Rally.Helper.createDialog(Qt.resolvedUrl("TapeSelectDialog.qml"))
                    dialog.onNewDocument.connect(s => newEditor(s))
                }
            }

            ToolButton {
                icon.name: "folder-open"
                display: AbstractButton.IconOnly
            }

            ToolButton {
                icon.name: "content-save"
                display: AbstractButton.IconOnly
                enabled: stackView.currentEditor && stackView.currentEditor.canSave
            }

            ToolButton {
                icon.name: "printer"
                display: AbstractButton.IconOnly
                enabled: stackView.currentEditor && PrinterManager.printer.ready
                onClicked: {
                    stackView.currentEditor.grabImage(grabResult => {

                                                          const dialog = Rally.Helper.createDialog(
                                                              Qt.resolvedUrl("PrintDialog.qml"), {
                                                                  "grabResult": grabResult
                                                              })
                                                      })
                }
            }

            ToolSeparator {

                height: parent.height
            }

            ToolButton {
                icon.name: "text"
                display: AbstractButton.IconOnly
                enabled: stackView.currentEditor
                onClicked: {
                    stackView.currentEditor.addText()
                }
            }

            ToolButton {
                icon.name: "image"
                display: AbstractButton.IconOnly
                enabled: PrinterManager.printer.ready
            }

            ToolButton {
                icon.name: "shape"
                display: AbstractButton.IconOnly
                enabled: PrinterManager.printer.ready
            }

            ToolButton {
                icon.name: "barcode"
                display: AbstractButton.IconOnly
                enabled: PrinterManager.printer.ready
            }
        }

        ToolButton {
            text: PrinterManager.printer.ready ? PrinterManager.printer.name : qsTr("no printer")
            icon.name: PrinterManager.printer.ready ? "printer-check" : "printer-alert"
            icon.color: PrinterManager.printer.ready ? "green" : "red"
            display: PrinterManager.printer.ready ? AbstractButton.TextBesideIcon : AbstractButton.IconOnly
            enabled: false
            anchors.right: parent.right
        }
    }

    Component {
        id: landingpageComponent

        Landingpage {
            id: landingpage
            onNewDocument: tapeWidthPx => {}
            onOpenDocument: fileUrl => {}
        }
    }

    Page {

        anchors.fill: parent

        StackView {

            id: stackView
            anchors.fill: parent

            property Editor currentEditor: {
                //if (stackView.currentItem instanceof Editor) { // not working
                if (stackView.currentItem && stackView.currentItem.objectName === "Editor") {
                    return currentItem
                }
                return null
            }
        }
    }
}
