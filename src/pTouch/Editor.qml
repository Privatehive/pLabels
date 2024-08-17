import QtQuick
import QtQuick.Controls
import QtQuick.Dialogs
import QtQuick.Layouts
import Qt5Compat.GraphicalEffects
import MaterialRally as Rally
import pTouch

Page {

    id: control

    focus: true

    property int tapeWidth: 18 // px
    property string file: ""

    property bool canSave: false
    readonly property alias empty: tape.empty

    signal close
    signal saved(url file)

    function grabImage(callback) {

        for (var i = 0; i < tape.children.length; i++) {
            tape.children[i].selected = false
        }
        tape.grabImage(callback)
    }

    function addText() {
        const component = Rally.Helper.createItem(Qt.resolvedUrl("TextComponent.qml"), tape, {
                                                      "tape": tape,
                                                      "text": "Text",
                                                      "x": tape.width / 2 - 100,
                                                      "y": 0,
                                                      "width": 200,
                                                      "height": tape.height
                                                  })
        component.onChanged.connect(() => control.canSave = true)
        component.selected = true
        control.forceActiveFocus()
        control.canSave = true
    }

    function save() {

        if (control.file.length > 0) {
            let items = []
            tape.iterateChildren(item => {
                                     items.push(item.toJson())
                                 })
            Helper.saveLable(JSON.stringify({
                                                "items": items,
                                                "tape": control.tapeWidth
                                            }), control.file)
            control.canSave = false
            control.saved(control.file)
        } else {
            let saveDialog = Rally.Helper.createDialog(Qt.resolvedUrl("SaveDialog.qml"))
            saveDialog.onAccepted.connect(() => {
                                              control.file = saveDialog.selectedFile
                                              if (control.file.length > 0) {
                                                  control.save()
                                              } else {
                                                  console.error("No valid file selected to save")
                                              }
                                          })
        }
    }

    Component.onCompleted: {

        control.load()
    }

    function load() {

        if (control.file.length > 0) {

            if (Helper.fileExists(new URL(control.file))) {

                try {
                    const doc = JSON.parse(Helper.readLable(control.file))
                    control.tapeWidth = doc.tape
                    for (var i = 0; i < doc.items.length; i++) {
                        const item = doc.items[i]
                        // Potentially dangerous. Injection of malicious qml file possible?
                        let component = Rally.Helper.createItem(Qt.resolvedUrl(item.type + ".qml"), tape, {
                                                                    "tape": tape
                                                                })
                        component.fromJson(item)
                        component.onChanged.connect(() => control.canSave = true)
                    }
                } catch (error) {
                    let dialog = Rally.Helper.createDialog(Qt.resolvedUrl("ContinueDialog.qml"), {
                                                               "text": qsTr("Loading label failed"),
                                                               "informativeText": qsTr("The file \"%1\" does not contain a valid label document.").arg(
                                                                                      control.file),
                                                               "buttons": MessageDialog.Ok
                                                           })
                    dialog.onAccepted.connect(() => {
                                                  control.close()
                                              })
                }
            } else {
                let dialog = Rally.Helper.createDialog(Qt.resolvedUrl("ContinueDialog.qml"), {
                                                           "text": qsTr("Loading label failed"),
                                                           "informativeText": qsTr("The file \"%1\" does not exist.").arg(
                                                                                  control.file),
                                                           "buttons": MessageDialog.Ok
                                                       })
                dialog.onAccepted.connect(() => {
                                              control.close()
                                          })
            }
        }
    }

    padding: 0

    Keys.onDeletePressed: {
        tape.deleteSelectedItem()
    }

    header: Row {

        //opacity: 0.5
        id: toolBarHolder
        function descroyChildren() {

            for (var i = 0; i < children.length; i++) {
                let child = children[i]
                if (child && child instanceof EditorToolBar && child.destroy) {
                    child.visible = false
                    child.destroy()
                }
            }
        }


        /*
        Flow {

            id: first

            visible: tape.selectedItem
            width: parent.width

            ToolButton {
                icon.name: "delete"

                onClicked: {
                    tape.deleteSelectedItem()
                    control.canSave = true
                }
            }

            ToolSeparator {}

            Item {

                id: toolBarHolder



            }
        }



        ToolButton {
            icon.name: "close"

            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter

            onClicked: {
                control.close()
            }
        }*/
    }

    DropShadow {
        anchors.fill: tapBg
        radius: 12
        samples: 12 * scale
        color: "#80000000"
        source: tapBg
        transformOrigin: Item.Left
        scale: tape.scale
    }

    Rectangle {
        id: tapBg
        color: "white"
        anchors.fill: tape
        transformOrigin: Item.Left
        scale: tape.scale
    }

    MouseArea {
        anchors.fill: parent
        onClicked: mouse => {
                       tape.deselect()
                       control.forceActiveFocus()
                   }
    }

    ToolButton {
        display: AbstractButton.IconOnly
        anchors.top: parent.top
        anchors.right: parent.right
        icon.name: "close"
        onClicked: {
            control.close()
        }
    }

    GroupBox {

        anchors.centerIn: parent
        width: Math.min(300, parent.width)
        visible: tape.empty

        RowLayout {

            width: parent.width

            Label {
                Layout.fillWidth: true
                text: qsTr("It seems like you have an empty workspace. You may want to add a text element by clicking this button.")
                wrapMode: Text.WordWrap
            }

            ToolButton {
                display: AbstractButton.IconOnly

                icon.name: "text"

                onClicked: {
                    control.addText()
                }
            }
        }
    }

    // Only the children of the viewport will be printed (nothing else)
    Viewport {

        property real calcScale: Math.min((control.contentItem.height - header.height) / tape.height, zoomSlieder.value)

        //property real yScale: ((y - height) * 1 / calcScale)
        id: tape
        x: -hbar.position * (width * calcScale)
        width: implicitWidth
        height: control.tapeWidth

        //anchors.verticalCenter: parent.verticalCenter
        y: (control.contentItem.height / 2 - (height / 2) - header.height / 2)

        transformOrigin: Item.Left
        scale: calcScale

        onItemSelected: item => {
                            let toolbar = item.createToolbar(toolBarHolder)
                            toolbar.width = Qt.binding(() => {
                                                           return control.width
                                                       })
                        }

        onItemDeselected: item => {
                              toolBarHolder.descroyChildren()
                          }

        function deleteSelectedItem() {
            if (tape.selectedItem) {
                const selectedItem = tape.selectedItem
                tape.deselect()
                selectedItem.visible = false
                selectedItem.destroy()
            }
        }
    }

    ScrollBar {
        id: hbar
        hoverEnabled: true
        active: hovered || pressed
        orientation: Qt.Horizontal
        size: control.width / (tape.width * tape.scale)
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        policy: !control.empty ? (size < 1.0 ? ScrollBar.AlwaysOn : ScrollBar.AlwaysOff) : ScrollBar.AlwaysOff
    }

    background: Rectangle {

        color: Material.color(Material.Grey)
    }

    footer: ToolBar {

        height: 30

        RowLayout {

            anchors.left: parent.left
            anchors.right: parent.right
            anchors.leftMargin: 10
            anchors.rightMargin: 10
            height: parent.height
            spacing: 20

            Rally.IconLabel {
                icon.name: "script"
                text: PrinterManager.getTapeMm(control.tapeWidth) + " mm"
            }

            Rally.IconLabel {
                icon.name: PrinterManager.printer.ready ? "printer" : "printer-off"
                text: (PrinterManager.printer.ready ? PrinterManager.printer.name : "")
                onClicked: Rally.Helper.createDialog(Qt.resolvedUrl("PrinterInfoDialog.qml"))
                enabled: PrinterManager.printer.ready
            }

            Label {
                Layout.fillWidth: true
            }

            Slider {

                id: zoomSlieder
                from: 1
                to: 5
                value: 1
                Layout.maximumHeight: 30
                focusPolicy: Qt.NoFocus
            }

            Label {

                text: qsTr("zoom: %1 %").arg(Math.round(zoomSlieder.value * 100))
                Layout.preferredWidth: 80
            }
        }
    }
}
