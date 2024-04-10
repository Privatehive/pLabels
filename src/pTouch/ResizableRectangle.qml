import QtQuick

FocusScope {

    id: control

    readonly property size grabberSize: Qt.size(10, 10)
    readonly property int minWidth: grabberSize.width * 3
    readonly property int minHeight: grabberSize.height * 3
    readonly property int minX: 0
    readonly property int minY: 0

    property bool activated: false

    onActiveFocusChanged: {
        activated = activeFocus
    }

    DragHandler {
        id: dh
        dragThreshold: 0
        enabled: !control.activated
    }

    TapHandler {
        gesturePolicy: TapHandler.WithinBounds
        onTapped: {
            control.activated = !control.activated
        }
    }

    Rectangle {
        anchors.fill: parent
        border.width: control.activated ? 2 : 1
        border.color: control.activated ? "blue" : "black"
        color: "transparent"
    }

    Rectangle {
        id: leftEdge
        width: grabberSize.width
        height: grabberSize.height
        border.width: 2
        border.color: "green"
        anchors.verticalCenter: parent.verticalCenter
        anchors.horizontalCenter: parent.left
        DragHandler {
            target: null
            dragThreshold: 0
            xAxis.onActiveValueChanged: delta => {
                                            priv.apply(
                                                Qt.rect(control.x + delta,
                                                        control.y,
                                                        control.width - delta,
                                                        control.height))
                                        }
        }
    }

    Rectangle {
        id: leftTopCorner
        width: grabberSize.width
        height: grabberSize.height
        border.width: 2
        border.color: "blue"
        anchors.verticalCenter: parent.top
        anchors.horizontalCenter: parent.left
        visible: !control.activated
        DragHandler {
            target: null
            dragThreshold: 0
            xAxis.onActiveValueChanged: delta => {
                                            priv.apply(
                                                Qt.rect(control.x + delta,
                                                        control.y,
                                                        control.width - delta,
                                                        control.height))
                                        }
            yAxis.onActiveValueChanged: delta => {
                                            priv.apply(
                                                Qt.rect(control.x,
                                                        control.y + delta,
                                                        control.width,
                                                        control.height - delta))
                                        }
        }
    }

    Rectangle {
        id: topEdge
        width: grabberSize.width
        height: grabberSize.height
        border.width: 2
        border.color: "red"
        anchors.verticalCenter: parent.top
        anchors.horizontalCenter: parent.horizontalCenter
        DragHandler {
            target: null
            dragThreshold: 0
            yAxis.onActiveValueChanged: delta => {
                                            priv.apply(
                                                Qt.rect(control.x,
                                                        control.y + delta,
                                                        control.width,
                                                        control.height - delta))
                                        }
        }
    }

    Rectangle {
        id: topRightCorner
        width: grabberSize.width
        height: grabberSize.height
        border.width: 2
        border.color: "yellow"
        anchors.verticalCenter: parent.top
        anchors.horizontalCenter: parent.right
        DragHandler {
            target: null
            dragThreshold: 0
            xAxis.onActiveValueChanged: delta => {
                                            priv.apply(
                                                Qt.rect(control.x, control.y,
                                                        control.width + delta,
                                                        control.height))
                                        }
            yAxis.onActiveValueChanged: delta => {
                                            priv.apply(
                                                Qt.rect(control.x,
                                                        control.y + delta,
                                                        control.width,
                                                        control.height - delta))
                                        }
        }
    }

    Rectangle {
        id: rightEdge
        width: grabberSize.width
        height: grabberSize.height
        border.width: 2
        border.color: "pink"
        anchors.verticalCenter: parent.verticalCenter
        anchors.horizontalCenter: parent.right
        DragHandler {
            target: null
            dragThreshold: 0
            xAxis.onActiveValueChanged: delta => {
                                            priv.apply(
                                                Qt.rect(control.x, control.y,
                                                        control.width + delta,
                                                        control.height))
                                        }
        }
    }

    Rectangle {
        id: rightBottomCorner
        width: grabberSize.width
        height: grabberSize.height
        border.width: 2
        border.color: "grey"
        anchors.verticalCenter: parent.bottom
        anchors.horizontalCenter: parent.right
        DragHandler {
            target: null
            dragThreshold: 0
            xAxis.onActiveValueChanged: delta => {
                                            priv.apply(
                                                Qt.rect(control.x, control.y,
                                                        control.width + delta,
                                                        control.height))
                                        }
            yAxis.onActiveValueChanged: delta => {
                                            priv.apply(
                                                Qt.rect(control.x, control.y,
                                                        control.width,
                                                        control.height + delta))
                                        }
        }
    }

    Rectangle {
        id: bottomEdge
        width: grabberSize.width
        height: grabberSize.height
        border.width: 2
        border.color: "magenta"
        anchors.verticalCenter: parent.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        DragHandler {
            target: null
            dragThreshold: 0
            yAxis.onActiveValueChanged: delta => {
                                            priv.apply(
                                                Qt.rect(control.x, control.y,
                                                        control.width,
                                                        control.height + delta))
                                        }
        }
    }

    Rectangle {
        id: bottomLeftCorner
        width: grabberSize.width
        height: grabberSize.height
        border.width: 2
        border.color: "black"
        anchors.verticalCenter: parent.bottom
        anchors.horizontalCenter: parent.left
        DragHandler {
            target: null
            dragThreshold: 0
            xAxis.onActiveValueChanged: delta => {
                                            priv.apply(
                                                Qt.rect(control.x + delta,
                                                        control.y,
                                                        control.width - delta,
                                                        control.height))
                                        }
            yAxis.onActiveValueChanged: delta => {
                                            priv.apply(
                                                Qt.rect(control.x, control.y,
                                                        control.width,
                                                        control.height + delta))
                                        }
        }
    }

    QtObject {

        id: priv

        property var rect: Qt.rect(control.x, control.y, control.width,
                                   control.height)

        function apply(rect) {

            // clamp width
            if (rect.width !== control.width) {
                if (rect.width > control.minWidth) {
                    control.width = rect.width
                } else {
                    control.width = control.minWidth
                }
            }

            // clamp height
            if (rect.height !== control.height) {
                if (rect.height > control.minHeight) {
                    control.height = rect.height
                } else {
                    control.height = control.minHeight
                }
            }

            if (rect.x !== control.x && rect.x > control.minX) {
                if (rect.x > control.minX) {
                    control.x = rect.x
                } else {
                    control.x = control.minX
                }
            }

            if (rect.y !== control.y) {
                if (rect.y > control.minY) {
                    control.y = rect.y
                } else {
                    control.y = control.minY
                }
            }

            priv.rect = rect
        }
    }
}
