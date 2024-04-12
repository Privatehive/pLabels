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
        textComponent.createObject(tape, {
                                       "text": "Text",
                                       "x": tape.width / 2,
                                       "y": tape.height / 2,
                                       "width": 100,
                                       "height": tape.height
                                   })
    }

    padding: 0

    Component {
        id: textComponent

        ResizableRectangle {

            property string text: ""

            onActivatedChanged: {
                text.enabled = activated
                if (activated) {
                    text.forceActiveFocus()
                }
            }

            TextEdit {
                id: text
                wrapMode: "WordWrap"
                color: "black"
                enabled: false
                anchors.fill: parent
            }
        }
    }


    /*
    DropShadow {
        anchors.fill: tape
        radius: 10
        color: "#80000000"
        source: tape
    }*/
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
