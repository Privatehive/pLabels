import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Qt5Compat.GraphicalEffects

Page {

    focusPolicy: "ClickFocus"

    objectName: "Editor"

    id: control
    property int tapeWidth: 18 // px
    property bool canSave: false

    function grabImage(callback) {

        tape.grabImage(callback)
    }

    function addText() {
        const component = textComponent.createObject(tape, {
                                                         "text": "Text",
                                                         "x": tape.width / 2,
                                                         "y": tape.height / 2,
                                                         "parent": tape,
                                                         "width": 100,
                                                         "height": tape.height,
                                                         "xAboutToChange": x => {

                                                             return x
                                                         }
                                                     })
    }

    padding: 0

    Component {
        id: textComponent

        ResizableRectangle {

            property string text: ""
            bounds: Qt.rect(0, 0, tape.width, tape.height)

            onActivatedChanged: {
                text.enabled = activated
                if (activated) {
                    text.forceActiveFocus()
                }
            }

            TextEdit {
                id: text
                color: "black"
                enabled: false
                anchors.top: parent.top
                anchors.left: parent.left
                scale: Math.min(parent.height / implicitHeight, parent.width / implicitWidth)
                width: parent.width * 1 / scale
                height: parent.height * 1 / scale
                transformOrigin: Item.TopLeft
            }
        }
    }

    DropShadow {
        anchors.fill: tape
        radius: 10
        color: "#80000000"
        source: tape
    }

    Viewport {
        id: tape
        width: parent.width
        height: control.tapeWidth
        anchors.centerIn: parent
        background: Rectangle {
            color: "white"
        }
    }

    background: Rectangle {
        color: "grey"
    }
}
