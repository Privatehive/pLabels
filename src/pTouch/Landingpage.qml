import QtCore
import QtQuick
import QtQuick.Controls
import QtQuick.Dialogs
import MaterialRally as Rally
import pTouch

Pane {

    id: control
    signal openDocument(url file)
    signal newDocument(int tapeWidthPx)

    Column {
        spacing: 20
        width: 200
        anchors.centerIn: parent

        Button {
            text: qsTr("New Document")
            width: parent.width
            onClicked: {
                const dialog = Rally.Helper.createDialog(
                                 Qt.resolvedUrl("TapeSelectDialog.qml"))
                dialog.onNewDocument.connect(tapeWidthPx => control.newDocument(
                                                 tapeWidthPx))
            }
        }

        Button {
            text: qsTr("Open Document")
            width: parent.width
            onClicked: {
                fileDialog.open()
            }
        }

        FileDialog {
            id: fileDialog

            defaultSuffix: "lbl"
            nameFilters: ["Label file (*.lbl)"]
            currentFolder: StandardPaths.standardLocations(
                               StandardPaths.DocumentsLocation)[0]
            onAccepted: {
                control.openDocument(fileDialog.selectedFile)
            }
        }
    }
}
