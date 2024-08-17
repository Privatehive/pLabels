import QtCore
import QtQuick
import QtQuick.Controls
import QtQuick.Dialogs
import MaterialRally as Rally
import pTouch

FileDialog {
    id: folderDialog
    defaultSuffix: "lbl"
    nameFilters: ["Label file (*.lbl)"]
    currentFolder: StandardPaths.standardLocations(StandardPaths.DocumentsLocation)[0]
    fileMode: FileDialog.SaveFile
    options: FileDialog.DontUseNativeDialog
}
