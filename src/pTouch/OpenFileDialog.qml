import QtCore
import QtQuick
import QtQuick.Controls
import QtQuick.Dialogs
import QtQuick.Controls.Material

FileDialog {
    id: control

    signal openDocument(url file)

    options: FileDialog.DontUseNativeDialog
    defaultSuffix: "lbl"
    nameFilters: ["Label file (*.lbl)"]
    currentFolder: StandardPaths.standardLocations(StandardPaths.DocumentsLocation)[0]
    onAccepted: {
        control.openDocument(control.selectedFile)
    }
}
