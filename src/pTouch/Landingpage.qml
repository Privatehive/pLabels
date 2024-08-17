import QtCore
import QtQuick
import QtQuick.Controls
import QtQuick.Controls.Material
import QtQuick.Layouts
import QtQuick.Dialogs
import MaterialRally as Rally
import pTouch

Pane {

    id: control
    signal openDocument(url file)
    signal newDocument(int tapeWidthPx)

    readonly property list<string> recentFile: []

    GridLayout {

        id: gr
        anchors.centerIn: parent
        width: Math.min(parent.width, implicitWidth)
        height: Math.min(rectenFilesBox.implicitHeight, parent.height)
        columnSpacing: 30
        rows: 2

        Column {

            spacing: 20

            Button {
                anchors.horizontalCenter: parent.horizontalCenter
                icon.name: PrinterManager.printer.ready ? "printer" : "printer-off"
                icon.height: 40
                icon.width: 40
                display: AbstractButton.TextUnderIcon
                text: (PrinterManager.printer.ready ? PrinterManager.printer.name : qsTr("no printer"))
                enabled: PrinterManager.printer.ready
                flat: true
                onClicked: {
                    Rally.Helper.createDialog(Qt.resolvedUrl("PrinterInfoDialog.qml"))
                }
            }

            Button {
                text: qsTr("New Document")
                implicitWidth: 200
                onClicked: {
                    const dialog = Rally.Helper.createDialog(Qt.resolvedUrl("TapeSelectDialog.qml"))
                    dialog.onNewDocument.connect(tapeWidthPx => control.newDocument(tapeWidthPx))
                }
            }

            Button {
                text: qsTr("Open Document")
                implicitWidth: 200
                onClicked: {
                    const dialog = Rally.Helper.createDialog(Qt.resolvedUrl("OpenFileDialog.qml"))
                    dialog.onOpenDocument.connect(control.openDocument)
                }
            }
        }

        GroupBox {

            id: rectenFilesBox
            Layout.minimumHeight: 0
            Layout.fillWidth: true
            Layout.fillHeight: true
            visible: control.recentFile.length > 0
            title: qsTr("Recent documents")

            ScrollView {

                id: scrollView
                anchors.fill: parent

                Column {

                    Repeater {

                        model: control.recentFile

                        delegate: ItemDelegate {

                            required property string modelData
                            readonly property bool fileExists: Helper.fileExists(new URL(modelData))

                            width: Math.max(implicitWidth, scrollView.contentWidth)
                            text: modelData.replace("file://", "")
                            font.strikeout: fileExists ? false : true
                            icon.color: fileExists ? Material.accent : Material.color(Material.Red)
                            icon.name: fileExists ? "file-document" : "file-question"
                            enabled: fileExists
                            onClicked: {
                                control.openDocument(new URL(modelData))
                            }
                        }
                    }
                }
            }
        }
    }
}
