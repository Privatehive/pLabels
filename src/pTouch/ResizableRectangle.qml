import QtQuick
import pTouch

FocusScope {

    id: control

    readonly property size grabberSize: Qt.size(20, 20)
    readonly property int minWidth: grabberSize.width * 3
    readonly property int minHeight: grabberSize.height * 3
    property rect bounds: Qt.rect(0, 0, 300, 300)
    property bool activated: false

    readonly property var xAboutToChange: null
    readonly property var yAboutToChange: null
    readonly property var widthAboutToChange: null
    readonly property var heightAboutToChange: null

    onActiveFocusChanged: {
        activated = activeFocus
    }

    Rectangle {
        anchors.fill: parent
        border.width: control.activated ? 2 : 1
        border.color: control.activated ? "blue" : "black"
        color: "transparent"
    }

    // all
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

        function apply(rect) {

            const xChanged = rect.x !== control.x
            const yChanged = rect.y !== control.y
            const widthChanged = rect.width !== control.width
            const heightChanged = rect.height !== control.height

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

            const leftOutOfBounds = rect.x < control.bounds.x
            const topOutOfBounds = rect.y < control.bounds.y
            const bottomOutOfBounds = rect.y + rect.height > control.bounds.height
            const rightOutOfBounds = rect.x + rect.width > control.bounds.width

            if (xChanged) {
                if (leftOutOfBounds) {
                    control.x = control.bounds.x
                    if (widthChanged) {
                        rect.width -= control.bounds.x - rect.x
                    }
                } else if (rightOutOfBounds) {
                    control.x = control.bounds.width - control.width
                } else {
                    control.x = rect.x
                }
            }

            if (yChanged) {
                if (topOutOfBounds) {
                    control.y = control.bounds.y
                    if (heightChanged) {
                        rect.height -= control.bounds.y - rect.y
                    }
                } else if (bottomOutOfBounds) {
                    control.y = control.bounds.height - control.height
                } else {
                    control.y = rect.y
                }
            }

            if (widthChanged) {
                if (rightOutOfBounds) {
                    control.width = control.bounds.width - rect.x
                } else {
                    control.width = rect.width
                }
            }

            if (heightChanged) {
                if (bottomOutOfBounds) {
                    control.height = control.bounds.height - rect.y
                } else {
                    control.height = rect.height
                }
            }
        }
    }
}
