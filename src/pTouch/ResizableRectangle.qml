import QtQuick
import pTouch

FocusScope {

    id: control

    readonly property size grabberSize: Qt.size(20, 20)
    readonly property int minWidth: grabberSize.width * 2 + 2
    readonly property int minHeight: grabberSize.height * 2 + 2
    property rect bounds: Qt.rect(0, 0, parent ? parent.width : 999999, parent ? parent.height : 999999)
    property bool activated: false

    readonly property var xAboutToChange: null
    readonly property var yAboutToChange: null
    readonly property var widthAboutToChange: null
    readonly property var heightAboutToChange: null

    Component.onCompleted: {
        priv.apply(Qt.rect(control.x, control.y, control.width, control.height), true)
    }

    onActiveFocusChanged: {
        activated = activeFocus
    }

    Rectangle {
        anchors.fill: parent
        border.width: control.activated ? 2 : 1
        border.color: control.activated ? "blue" : "black"
        color: "transparent"
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

    // left
    ResizeGrabber {
        width: grabberSize.width
        height: grabberSize.height
        anchors.verticalCenter: parent.verticalCenter
        anchors.horizontalCenter: parent.left
        border.width: 2
        border.color: "blue"
        cursorShape: Qt.SizeHorCursor
        target: control
        invertWidth: true
        onResized: rect => {
                       priv.apply(Qt.rect(rect.x, control.y, rect.width, control.height))
                   }
    }

    // topleft
    ResizeGrabber {
        width: grabberSize.width
        height: grabberSize.height
        anchors.verticalCenter: parent.top
        anchors.horizontalCenter: parent.left
        border.width: 2
        border.color: "blue"
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
        width: grabberSize.width
        height: grabberSize.height
        anchors.verticalCenter: parent.top
        anchors.horizontalCenter: parent.horizontalCenter
        border.width: 2
        border.color: "blue"
        cursorShape: Qt.SizeVerCursor
        target: control
        invertHeight: true
        onResized: rect => {
                       priv.apply(Qt.rect(control.x, rect.y, control.width, rect.height))
                   }
    }

    // topright
    ResizeGrabber {
        width: grabberSize.width
        height: grabberSize.height
        anchors.verticalCenter: parent.top
        anchors.horizontalCenter: parent.right
        border.width: 2
        border.color: "blue"
        cursorShape: Qt.SizeBDiagCursor
        target: control
        invertHeight: true
        onResized: rect => {
                       priv.apply(Qt.rect(control.x, rect.y, rect.width, rect.height))
                   }
    }

    // right
    ResizeGrabber {
        width: grabberSize.width
        height: grabberSize.height
        anchors.verticalCenter: parent.verticalCenter
        anchors.horizontalCenter: parent.right
        border.width: 2
        border.color: "blue"
        cursorShape: Qt.SizeHorCursor
        target: control
        invertHeight: true
        onResized: rect => {
                       priv.apply(Qt.rect(control.x, control.y, rect.width, control.height))
                   }
    }

    // bottomright
    ResizeGrabber {
        width: grabberSize.width
        height: grabberSize.height
        anchors.verticalCenter: parent.bottom
        anchors.horizontalCenter: parent.right
        border.width: 2
        border.color: "blue"
        cursorShape: Qt.SizeFDiagCursor
        target: control
        onResized: rect => {
                       priv.apply(Qt.rect(control.x, control.y, rect.width, rect.height))
                   }
    }

    // bottom
    ResizeGrabber {
        width: grabberSize.width
        height: grabberSize.height
        anchors.verticalCenter: parent.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        border.width: 2
        border.color: "blue"
        cursorShape: Qt.SizeVerCursor
        target: control
        onResized: rect => {
                       priv.apply(Qt.rect(control.x, control.y, control.width, rect.height))
                   }
    }

    // bottomleft
    ResizeGrabber {
        width: grabberSize.width
        height: grabberSize.height
        anchors.verticalCenter: parent.bottom
        anchors.horizontalCenter: parent.left
        border.width: 2
        border.color: "blue"
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

            const xChanged = rect.x !== control.x || forceChange
            const yChanged = rect.y !== control.y || forceChange
            const widthChanged = rect.width !== control.width || forceChange
            const heightChanged = rect.height !== control.height || forceChange

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
