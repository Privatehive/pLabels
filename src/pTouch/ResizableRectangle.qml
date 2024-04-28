import QtQuick
import QtQuick.Controls
import pTouch

FocusScope {

    id: control

    default property alias contentItem: holder.children
    readonly property size grabberSize: Qt.size(10, 10)
    readonly property int minWidth: grabberSize.width * 2 + 2
    readonly property int minHeight: grabberSize.height * 2 + 2
    property rect bounds: Qt.rect(0, 0, parent ? parent.width : Number.MAX_VALUE,
                                  parent ? parent.height : Number.MAX_VALUE)
    property bool activated: false
    property real inverseScale: parent ? 1 / parent.scale : 1

    property var leftAboutToChange: left => left
    property var topAboutToChange: top => top
    property var rightAboutToChange: right => right
    property var bottomAboutToChange: bottom => bottom

    implicitHeight: {
        if (holder.children[0]) {
            return holder.children[0].implicitHeight
        }
        return 0
    }

    implicitWidth: {
        if (holder.children[0]) {
            return holder.children[0].implicitWidth
        }
        return 0
    }

    Component.onCompleted: {
        priv.apply(Qt.rect(control.x, control.y, control.width, control.height), true)
    }

    onActiveFocusChanged: {
        activated = activeFocus
    }

    Canvas {
        anchors.fill: parent
        onPaint: {
            var ctx = getContext("2d")
            ctx.lineWidth = 1 * control.inverseScale
            ctx.strokeStyle = "black"
            ctx.beginPath()
            ctx.lineTo(width, 0)
            ctx.lineTo(width, height)
            ctx.lineTo(0, height)
            ctx.lineTo(0, 0)
            ctx.closePath()
            ctx.stroke()
        }
    }

    // whole
    ResizeGrabber {
        anchors.fill: parent
        color: "transparent"
        cursorShape: Qt.SizeAllCursor
        target: control
        onResized: rect => {
                       priv.apply(Qt.rect(rect.x, rect.y, control.width, control.height))
                   }
        onDoubleClicked: {
            control.activated = !control.activated
        }
    }

    Item {
        id: holder
        anchors.fill: parent
    }

    // left
    ResizeGrabber {
        width: grabberSize.width * control.inverseScale
        height: grabberSize.height * control.inverseScale
        anchors.verticalCenter: parent.verticalCenter
        anchors.horizontalCenter: parent.left
        cursorShape: Qt.SizeHorCursor
        target: control
        invertWidth: true
        onResized: rect => {
                       priv.apply(Qt.rect(rect.x, control.y, rect.width, control.height))
                   }
    }

    // topleft
    ResizeGrabber {
        width: grabberSize.width * control.inverseScale
        height: grabberSize.height * control.inverseScale
        anchors.verticalCenter: parent.top
        anchors.horizontalCenter: parent.left
        cursorShape: Qt.SizeFDiagCursor
        target: control
        invertWidth: true
        invertHeight: true
        onResized: rect => {
                       priv.apply(Qt.rect(rect.x, rect.y, rect.width, rect.height))
                   }
    }

    // top
    ResizeGrabber {
        width: grabberSize.width * control.inverseScale
        height: grabberSize.height * control.inverseScale
        anchors.verticalCenter: parent.top
        anchors.horizontalCenter: parent.horizontalCenter
        cursorShape: Qt.SizeVerCursor
        target: control
        invertHeight: true
        onResized: rect => {
                       priv.apply(Qt.rect(control.x, rect.y, control.width, rect.height))
                   }
    }

    // topright
    ResizeGrabber {
        width: grabberSize.width * control.inverseScale
        height: grabberSize.height * control.inverseScale
        anchors.verticalCenter: parent.top
        anchors.horizontalCenter: parent.right
        cursorShape: Qt.SizeBDiagCursor
        target: control
        invertHeight: true
        onResized: rect => {
                       priv.apply(Qt.rect(control.x, rect.y, rect.width, rect.height))
                   }
    }

    // right
    ResizeGrabber {
        width: grabberSize.width * control.inverseScale
        height: grabberSize.height * control.inverseScale
        anchors.verticalCenter: parent.verticalCenter
        anchors.horizontalCenter: parent.right
        cursorShape: Qt.SizeHorCursor
        target: control
        invertHeight: true
        onResized: rect => {
                       priv.apply(Qt.rect(control.x, control.y, rect.width, control.height))
                   }
    }

    // bottomright
    ResizeGrabber {
        width: grabberSize.width * control.inverseScale
        height: grabberSize.height * control.inverseScale
        anchors.verticalCenter: parent.bottom
        anchors.horizontalCenter: parent.right
        cursorShape: Qt.SizeFDiagCursor
        target: control
        onResized: rect => {
                       priv.apply(Qt.rect(control.x, control.y, rect.width, rect.height))
                   }
    }

    // bottom
    ResizeGrabber {
        width: grabberSize.width * control.inverseScale
        height: grabberSize.height * control.inverseScale
        anchors.verticalCenter: parent.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        cursorShape: Qt.SizeVerCursor
        target: control
        onResized: rect => {
                       priv.apply(Qt.rect(control.x, control.y, control.width, rect.height))
                   }
    }

    // bottomleft
    ResizeGrabber {
        width: grabberSize.width * control.inverseScale
        height: grabberSize.height * control.inverseScale
        anchors.verticalCenter: parent.bottom
        anchors.horizontalCenter: parent.left
        cursorShape: Qt.SizeBDiagCursor
        target: control
        invertWidth: true
        onResized: rect => {
                       priv.apply(Qt.rect(rect.x, control.y, rect.width, rect.height))
                   }
    }

    QtObject {

        id: priv

        function apply(rect, forceChange) {

            const leftOutOfBounds = function (rect) {
                return rect.x < control.bounds.x
            }
            const topOutOfBounds = function (rect) {
                return rect.y < control.bounds.y
            }
            const bottomOutOfBounds = function (rect) {
                return rect.y + rect.height > control.bounds.height
            }
            const rightOutOfBounds = function (rect) {
                return rect.x + rect.width > control.bounds.width
            }

            const xChanged = rect.x !== control.x || forceChange
            const yChanged = rect.y !== control.y || forceChange
            const widthChanged = rect.width !== control.width || forceChange
            const heightChanged = rect.height !== control.height || forceChange

            // --- handle snap ---


            /*
            if (xChanged) {
                let snapped = false
                if (control.leftAboutToChange) {
                    const newx = control.leftAboutToChange(rect.x)
                    let snapped = newx !== rect.x
                    rect.width -= newx - rect.x
                    rect.x = newx
                }
                if (!snapped && control.rightAboutToChange) {
                    const newRight = control.rightAboutToChange(rect.x + rect.width)
                    rect.x = newRight - rect.width
                }
            }

            if (widthChanged) {
                if (control.rightAboutToChange) {
                    const newRight = control.rightAboutToChange(rect.x + rect.width)
                    rect.width = newRight - rect.x
                }
            }

            if (yChanged) {
                let snapped = false
                if (control.topAboutToChange) {
                    const newy = control.topAboutToChange(rect.y)
                    let snapped = newy !== rect.y
                    rect.height -= newy - rect.y
                    rect.y = newy
                }
                if (!snapped && control.bottomAboutToChange) {
                    const newBottom = control.bottomAboutToChange(rect.y + rect.height)
                    rect.y = newBottom - rect.height
                }
            }

            if (heightChanged) {
                if (control.bottomAboutToChange) {
                    const newBottom = control.bottomAboutToChange(rect.y + rect.height)
                    rect.height = newBottom - rect.y
                }
            }
*/
            // ------------------

            // clamp to minWidth
            if (rect.width < control.minWidth) {
                rect.x -= control.minWidth - rect.width
                rect.width = control.minWidth
            }

            // clamp to minHeight
            if (rect.height < control.minHeight) {
                rect.y -= control.minHeight - rect.height
                rect.height = control.minHeight
            }

            if (xChanged) {
                if (leftOutOfBounds(rect)) {
                    if (widthChanged) {
                        rect.width -= control.bounds.x - rect.x
                    }
                    rect.x = control.bounds.x
                } else if (rightOutOfBounds(rect)) {
                    rect.x = control.bounds.width - control.width
                }
                control.x = Math.max(rect.x, control.bounds.x)
            }

            if (yChanged) {
                if (topOutOfBounds(rect)) {
                    if (heightChanged) {
                        rect.height -= control.bounds.y - rect.y
                    }
                    rect.y = control.bounds.y
                } else if (bottomOutOfBounds(rect)) {
                    rect.y = control.bounds.height - control.height
                }
                control.y = Math.max(rect.y, control.bounds.y)
            }

            if (widthChanged) {
                if (rightOutOfBounds(rect)) {
                    rect.width = control.bounds.width - rect.x
                }
                control.width = Math.min(rect.width, control.bounds.width)
            }

            if (heightChanged) {
                if (bottomOutOfBounds(rect)) {
                    rect.height = control.bounds.height - rect.y
                }
                control.height = Math.min(rect.height, control.bounds.height)
            }
        }
    }
}
