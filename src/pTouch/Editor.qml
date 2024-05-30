import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Qt5Compat.GraphicalEffects
import pTouch

Page {

    id: control
    focusPolicy: "ClickFocus"
    objectName: "Editor"

    property int tapeWidth: 18 // px
    property bool canSave: false

    function grabImage(callback) {

        for (var i = 0; i < tape.children.length; i++) {
            tape.children[i].focus = false
        }
        tape.grabImage(callback)
    }

    function addText() {
        const component = textComponent.createObject(tape, {
                                                         "text": "Text",
                                                         "x": tape.width / 2 - 100,
                                                         "y": 0,
                                                         "width": 200,
                                                         "height": tape.height,
                                                         "selected": true
                                                     })
    }

    padding: 0

    Component {
        id: textToolbarComponent

        ToolBar {
            ComboBox {

                width: 400
                height: parent.height
                editable: true
                selectTextByMouse: true

                FontfamiliesModel {
                    id: fontfalimies
                }

                model: fontfalimies
                textRole: "family"
            }

            ToolButton {
                icon.name: "format-bold"
                display: AbstractButton.IconOnly
            }

            ToolButton {
                icon.name: "format-italic"
                display: AbstractButton.IconOnly
            }

            ToolButton {
                icon.name: "format-underline"
                display: AbstractButton.IconOnly
            }
        }
    }

    Component {
        id: textComponent

        ResizableRectangle {

            property alias text: text.text

            bounds: Qt.rect(0, 0, Number.MAX_VALUE, tape.height)
            leftAboutToChange: left => tape.snapLeft(this, left)
            topAboutToChange: top => tape.snapTop(this, top)
            rightAboutToChange: right => tape.snapRight(this, right)
            bottomAboutToChange: bottom => tape.snapBottom(this, bottom)

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
                renderType: TextEdit.QtRendering
            }
        }
    }

    DropShadow {
        anchors.fill: tapBg
        radius: 12
        samples: 12 * scale
        color: "#80000000"
        source: tapBg
        transformOrigin: Item.Left
        scale: zoomSlieder.value
    }

    Rectangle {
        id: tapBg
        color: "white"
        anchors.fill: tape
        transformOrigin: Item.Left
        scale: zoomSlieder.value
    }

    // Only the children of the viewport will be printed (nothing else)
    Viewport {
        id: tape
        x: -hbar.position * (width * scale)
        y: -vbar.position * (height * scale)
        width: implicitWidth
        height: control.tapeWidth
        anchors.verticalCenter: parent.verticalCenter
        transformOrigin: Item.Left
        scale: zoomSlieder.value
    }

    ScrollBar {
        id: vbar
        hoverEnabled: true
        active: hovered || pressed
        orientation: Qt.Vertical
        size: control.height / (tape.height * tape.scale)
        anchors.top: parent.top
        anchors.right: parent.right
        anchors.bottom: parent.bottom
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
        policy: size < 1.0 ? ScrollBar.AlwaysOn : ScrollBar.AlwaysOff
    }

    background: Rectangle {
        color: "grey"
    }

    footer: ToolBar {
        height: 30
        Row {
            anchors.verticalCenter: parent.verticalCenter
            anchors.right: parent.right
            Slider {
                id: zoomSlieder
                from: 1
                to: 3
            }
        }
    }
}
