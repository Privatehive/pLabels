import QtQuick
import QtQuick.Controls
import Qt5Compat.GraphicalEffects

Pane {

    focusPolicy: "ClickFocus"

    id: control
    property int tapeWidth: 18 // px
    padding: 0

    function addText() {
        textComponent.createObject(tape, {
                                       "text": "Text",
                                       "x": tape.width / 2,
                                       "y": tape.height / 2,
                                       "width": 100,
                                       "height": tape.height
                                   })
    }

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

    DropShadow {
        anchors.fill: tape
        radius: 10
        color: "#80000000"
        source: tape
    }

    Control {
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
