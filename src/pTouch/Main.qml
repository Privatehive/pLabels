import QtCore
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Dialogs
import Qt5Compat.GraphicalEffects
import MaterialRally as Rally
import pTouch

Rally.RallyApplicationWindow {

    id: control

    visible: true

    width: 300
    height: 300

    Component.onCompleted: {

        control.newLandingPage()
    }

    property list<string> recentFiles: []

    Settings {
        property alias recentFile: control.recentFiles
    }

    function newEditor(tapeWidthPx, file) {
        const editor = Rally.Helper.createItem(Qt.resolvedUrl("Editor.qml"), null, {
                                                   "tapeWidth": tapeWidthPx ? tapeWidthPx : 18,
                                                   "file": file ? file : ""
                                               })
        editor.onClose.connect(() => {
                                   control.newContinueDialog(editor.canSave, () => {
                                                                 control.newLandingPage()
                                                                 editor.destroy()
                                                             })
                               })


        /*
        editor.onSaved.connect(file => {
                                   let found = false
                                   let recentFilesList = [file]

                                   for (var i = 0; i < control.recentFiles.length; i++) {
                                       const tmpFile = control.recentFiles[i]
                                       if (tmpFile != file) {
                                           recentFilesList.push(tmpFile)
                                       }
                                       if (recentFilesList.length === 10) {
                                           break
                                       }
                                   }

                                   control.recentFiles.length = 0
                                   recentFilesList.forEach(ele => {
                                                               control.recentFiles.push(ele)
                                                           })
                               })
                               */
        stackView.replace(editor)

        if (file) {
            let recentFilesList = [file]

            for (var i = 0; i < control.recentFiles.length; i++) {
                const tmpFile = control.recentFiles[i]
                if (tmpFile != file) {
                    recentFilesList.push(tmpFile)
                }
                if (recentFilesList.length === 10) {
                    break
                }
            }

            control.recentFiles.length = 0
            recentFilesList.forEach(ele => {
                                        control.recentFiles.push(ele)
                                    })
        }
    }

    function newLandingPage() {

        const landingPage = Rally.Helper.createItem(Qt.resolvedUrl("Landingpage.qml"), null, {
                                                        "recentFile": control.recentFiles
                                                    })
        landingPage.newDocument.connect(size => {
                                            control.newEditor(size)
                                            landingPage.destroy()
                                        })
        landingPage.onOpenDocument.connect(file => {
                                               control.newEditor(undefined, file)
                                               landingPage.destroy()
                                           })
        stackView.replace(landingPage)
    }

    function newContinueDialog(ask, callback) {

        if (ask) {
            const dialog = Rally.Helper.createDialog(Qt.resolvedUrl("ContinueDialog.qml"))
            dialog.onAccepted.connect(() => callback())
        } else {
            callback()
        }
    }

    function newFileDialog() {

        control.newContinueDialog(stackView.currentEditor?.canSave, () => {

                                      const dialog = Rally.Helper.createDialog(Qt.resolvedUrl("TapeSelectDialog.qml"))
                                      dialog.onNewDocument.connect(s => {
                                                                       control.newEditor(s)
                                                                   })
                                  })
    }

    function newPrintDialog() {

        stackView.currentEditor.grabImage(grabResult => {
                                              const dialog = Rally.Helper.createDialog(Qt.resolvedUrl(
                                                                                           "PrintDialog.qml"), {
                                                                                           "grabResult": grabResult
                                                                                       })
                                          })
    }

    function newOpenDialog() {

        control.newContinueDialog(stackView.currentEditor?.canSave, () => {

                                      const dialog = Rally.Helper.createDialog(Qt.resolvedUrl("OpenFileDialog.qml"))
                                      dialog.onOpenDocument.connect(file => {
                                                                        control.newEditor(undefined, file)
                                                                    })
                                  })
    }

    header: EditorToolBar {

        Row {
            ToolButton {
                display: AbstractButton.IconOnly
                icon.name: "file"

                Shortcut {
                    sequences: [StandardKey.New]
                    onActivated: control.newFileDialog()
                }

                onClicked: {
                    control.newFileDialog()
                }
            }
            ToolButton {
                display: AbstractButton.IconOnly
                icon.name: "folder-open"

                Shortcut {
                    sequences: [StandardKey.Open]
                    onActivated: control.newOpenDialog()
                }

                onClicked: {
                    control.newOpenDialog()
                }
            }
            ToolButton {
                display: AbstractButton.IconOnly
                enabled: stackView.currentEditor && stackView.currentEditor.canSave
                icon.name: "content-save"

                Shortcut {
                    sequences: [StandardKey.Save]
                    onActivated: stackView.currentEditor.save()
                }

                onClicked: {
                    stackView.currentEditor.save()
                }
            }
            ToolButton {
                display: AbstractButton.IconOnly
                enabled: stackView.currentEditor && !stackView.currentEditor.empty
                icon.name: "printer"

                Shortcut {
                    sequences: [StandardKey.Print]
                    onActivated: control.newPrintDialog()
                }

                onClicked: {
                    control.newPrintDialog()
                }
            }
            ToolSeparator {
                height: parent.height
            }
        }

        Row {
            ToolButton {
                display: AbstractButton.IconOnly
                enabled: stackView.currentEditor
                icon.name: "text"

                onClicked: {
                    stackView.currentEditor.addText()
                }
            }
            ToolButton {
                display: AbstractButton.IconOnly
                enabled: false //PrinterManager.printer.ready
                icon.name: "image"
            }
            ToolButton {
                display: AbstractButton.IconOnly
                enabled: false //PrinterManager.printer.ready
                icon.name: "shape"
            }
            ToolButton {
                display: AbstractButton.IconOnly
                enabled: false //PrinterManager.printer.ready
                icon.name: "barcode"
            }
        }
    }

    Page {
        anchors.fill: parent

        StackView {
            id: stackView

            property Editor currentEditor: {
                if (stackView.currentItem && stackView.currentItem instanceof Editor) {
                    return currentItem
                }
                return null
            }

            anchors.fill: parent
        }
    }
}
