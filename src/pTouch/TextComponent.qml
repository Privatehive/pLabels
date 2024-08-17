import QtQuick
import QtQuick.Controls
import pTouch

ResizableRectangle {

    id: control
    objectName: "TextComponent"

    property alias text: text.text
    property Viewport tape

    function createToolbar(parent) {

        let toolBar = textToolbarComponent.createObject(parent, {
                                                            "activeFont": text.font,
                                                            "activeRotation": text.rotation
                                                        })
        toolBar.onActiveFontChanged.connect(() => {
                                                text.font = toolBar.activeFont
                                                control.changed()
                                            })
        toolBar.onActiveRotationChanged.connect(() => {
                                                    text.rotation = toolBar.activeRotation
                                                    control.changed()
                                                })

        toolBar.activeVerticalAlignment.connect(alignment => {
                                                    text.verticalAlignment = alignment
                                                    // Qt Bug? Without size changes the alignment is not applyed
                                                    control.width -= 1
                                                    control.width += 1
                                                    control.changed()
                                                })

        return toolBar
    }

    function toJson() {

        return {
            "type": control.objectName,
            "font": text.font,
            "text": text.text,
            "rect": Qt.rect(control.x, control.y, control.width, control.height),
            "rotation": text.rotation,
            "verticalAlignment": text.verticalAlignment
        }
    }

    function fromJson(obj) {

        if (obj.type === control.objectName) {
            control.x = obj.rect.x
            control.y = obj.rect.y
            control.width = obj.rect.width
            control.height = obj.rect.height
            text.font = Qt.font(obj.font)
            text.text = obj.text
            text.rotation = obj.rotation
            text.verticalAlignment = obj.verticalAlignment
        } else {
            console.error("Not the expected type " + obj.type)
        }
    }

    property Component toolbar: Component {

        id: textToolbarComponent

        EditorToolBar {

            property font activeFont: Qt.font()
            property real activeRotation: 0

            signal activeVerticalAlignment(int alignment)

            Row {
                ToolButton {
                    icon.name: "rotate-right-variant"
                    display: AbstractButton.IconOnly

                    onClicked: {
                        activeRotation = (activeRotation + 90) % 360
                    }
                }

                ToolButton {
                    icon.name: "rotate-left-variant"
                    display: AbstractButton.IconOnly

                    onClicked: {
                        activeRotation = (activeRotation - 90 + 360) % 360
                    }
                }

                ToolSeparator {}
            }

            Row {
                Item {
                    height: 48
                    implicitWidth: fontFamily.width + 20

                    ComboBox {

                        id: fontFamily
                        width: 300
                        height: 34
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.horizontalCenter: parent.horizontalCenter
                        editable: true
                        selectTextByMouse: true

                        FontfamiliesModel {
                            id: fontfalimies
                        }

                        model: fontfalimies
                        valueRole: "font"
                        textRole: "family"

                        Component.onCompleted: currentIndex = find(activeFont.family)

                        onActivated: index => {
                                         const selectedFont = valueAt(index)
                                         activeFont.family = selectedFont.family
                                     }

                        onAccepted: {
                            const index = find(editText)
                            if (index >= 0) {
                                const selectedFont = valueAt(index)
                                activeFont.family = selectedFont.family
                            }
                        }
                    }
                }
            }

            Row {
                ToolButton {
                    icon.name: "format-bold"
                    display: AbstractButton.IconOnly
                    checkable: true

                    Component.onCompleted: checked = activeFont.bold

                    onClicked: {
                        activeFont.bold = checked
                    }
                }

                ToolButton {
                    icon.name: "format-italic"
                    display: AbstractButton.IconOnly
                    checkable: true

                    Component.onCompleted: checked = activeFont.italic

                    onClicked: {
                        activeFont.italic = checked
                    }
                }

                ToolButton {
                    icon.name: "format-underline"
                    display: AbstractButton.IconOnly
                    checkable: true

                    Component.onCompleted: checked = activeFont.underline

                    onClicked: {
                        activeFont.underline = checked
                    }
                }

                ToolSeparator {}
            }

            Row {
                ToolButton {
                    icon.name: "format-align-left"
                    display: AbstractButton.IconOnly

                    onClicked: {
                        activeVerticalAlignment(Text.AlignLeft)
                    }
                }

                ToolButton {
                    icon.name: "format-align-center"
                    display: AbstractButton.IconOnly

                    onClicked: {
                        activeVerticalAlignment(Text.AlignHCenter)
                    }
                }

                ToolButton {
                    icon.name: "format-align-right"
                    display: AbstractButton.IconOnly

                    onClicked: {
                        activeVerticalAlignment(Text.AlignRight)
                    }
                }
            }
        }
    }

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
        scale: Math.abs(rotation) == 90 || Math.abs(rotation)
               == 270 ? Math.min(parent.width / implicitHeight, parent.height
                                 / implicitWidth) : Math.min(parent.height / implicitHeight, parent.width / implicitWidth)
        width: Math.abs(rotation) == 90 || Math.abs(
                   rotation) == 270 ? parent.height * 1 / scale : parent.width * 1 / scale
        height: Math.abs(rotation) == 90 || Math.abs(
                    rotation) == 270 ? parent.width * 1 / scale : parent.height * 1 / scale
        transformOrigin: Item.TopLeft
        renderType: TextEdit.CurveRendering
        anchors.leftMargin: {

            if (Math.abs(rotation) == 90) {
                return height * scale
            } else if (Math.abs(rotation) == 180) {
                return width * scale
            }
            return 0
        }
        anchors.topMargin: {

            if (Math.abs(rotation) == 270) {
                return width * scale
            } else if (Math.abs(rotation) == 180) {
                return height * scale
            }
            return 0
        }
        rotation: 0
        verticalAlignment: Text.AlignLeft

        onTextChanged: {
            control.changed()
        }
    }
}
