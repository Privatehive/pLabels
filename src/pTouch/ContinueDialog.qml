import QtQuick
import QtQuick.Controls
import QtQuick.Dialogs
import QtQuick.Layouts

Dialog {

    id: control

    anchors.centerIn: parent

    contentWidth: 300

    title: qsTr("The document has unsaved changes")

    RowLayout {

        anchors.fill: parent

        Label {
            Layout.fillWidth: true
            wrapMode: Text.WordWrap
            text: qsTr("Do you want to close the document? All unsaved changes will be lost!")
        }
    }

    standardButtons: MessageDialog.Ok | MessageDialog.Cancel
}
