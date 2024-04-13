import QtQuick
import QtQuick.Controls
import Qt5Compat.GraphicalEffects
import MaterialRally as Rally
import pTouch

Rally.RallyRootPage {

    id: control

    visible: true

    Component.onCompleted: {
        swipeView.addItem(Rally.Helper.createItem(Qt.resolvedUrl("Editor.qml"),
                                                  null, {
                                                      "tapeWidth": 128
                                                  }))
    }

    function newEditor(tapeWidthPx) {

        swipeView.addItem(Rally.Helper.createItem(Qt.resolvedUrl("Editor.qml"),
                                                  null, {
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
                    const dialog = Rally.Helper.createDialog(
                                     Qt.resolvedUrl("TapeSelectDialog.qml"))
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
                enabled: swipeView.currentEditor
                         && swipeView.currentEditor.canSave
            }

            ToolButton {
                icon.name: "printer"
                display: AbstractButton.IconOnly
                enabled: swipeView.currentEditor && PrinterManager.printer.ready
                onClicked: {
                    swipeView.currentEditor.grabImage(grabResult => {

                                                          const dialog = Rally.Helper.createDialog(
                                                              Qt.resolvedUrl(
                                                                  "PrintDialog.qml"))
                                                          //dialog.data.push(
                                                          //    grabResult) // we have to keep the reference alive as long as the dialog lives
                                                          dialog.showImage(
                                                              grabResult.url)
                                                      })
                }
            }

            ToolSeparator {

                height: parent.height
            }

            ToolButton {
                icon.name: "text"
                display: AbstractButton.IconOnly
                enabled: swipeView.currentEditor
                onClicked: {
                    swipeView.currentEditor.addText()
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
            text: PrinterManager.printer.ready ? PrinterManager.printer.name : qsTr(
                                                     "no printer")
            icon.name: PrinterManager.printer.ready ? "printer-check" : "printer-alert"
            icon.color: PrinterManager.printer.ready ? "green" : "red"
            display: PrinterManager.printer.ready ? AbstractButton.TextBesideIcon : AbstractButton.IconOnly
            enabled: false
            anchors.right: parent.right
        }
    }

    Page {

        anchors.fill: parent

        header: Row {
            TabBar {
                id: bar

                Repeater {
                    model: swipeView.count

                    TabButton {
                        text: index
                        width: 200
                        rightPadding: 40

                        RoundButton {
                            width: 40
                            height: 40
                            flat: true
                            icon.name: "close"
                            anchors.right: parent.right
                            anchors.verticalCenter: parent.verticalCenter
                            onClicked: {
                                swipeView.removeItem(swipeView.itemAt(index))
                            }
                        }
                    }
                }
            }

            TabButton {
                visible: bar.count > 0
                checkable: false
                width: 50
                icon.name: "plus"

                onClicked: {
                    swipeView.addItem(landingpageComponent.createObject(
                                          swipeView))
                }
            }
        }

        SwipeView {

            id: swipeView
            anchors.fill: parent
            currentIndex: bar.currentIndex
            interactive: false

            property Editor currentEditor: {
                //if (swipeView.currentItem instanceof Editor) { // not working
                if (swipeView.currentItem
                        && swipeView.currentItem.objectName === "Editor") {
                    return currentItem
                }
                return null
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


        /*
        Editor {
            id: editor
            anchors.fill: parent
            tapeWidth: PrinterManager.printer.tapeWidth
        }*/
    }
}
