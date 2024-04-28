import QtQuick
import QtQuick.Controls

Item {

    id: control

    property real snapDistanceHorizontal: 10
    property real snapDistanceVertical: 10

    // onChildrenRectChanged doesn't get triggered. This is a woraround
    readonly property rect childrenRectWorkaround: control.childrenRect

    implicitWidth: control.childrenRectWorkaround.x + control.childrenRectWorkaround.width
    implicitHeight: control.childrenRectWorkaround.y + control.childrenRectWorkaround.height

    function grabImage(callback) {

        control.grabToImage(result => {
                                callback(result)
                            })
    }

    function snapLeft(item, left) {

        let snapLine = left
        let snapDiff = control.snapDistanceHorizontal
        for (var i = 0; i < control.children.length; i++) {
            if (control.children[i] !== item) {
                if (Math.abs(control.children[i].x - left) <= snapDiff) {
                    snapLine = control.children[i].x
                    snapDiff = Math.abs(control.children[i].x - left)
                }
                if (Math.abs(control.children[i].x + control.children[i].width - left) <= snapDiff) {
                    snapLine = control.children[i].x + control.children[i].width
                    snapDiff = Math.abs(control.children[i].x + control.children[i].width - left)
                }
            }
        }
        return snapLine
    }

    function snapRight(item, right) {

        let snapLine = right
        let snapDiff = control.snapDistanceHorizontal
        for (var i = 0; i < control.children.length; i++) {
            if (control.children[i] !== item) {
                if (Math.abs(control.children[i].x - right) <= snapDiff) {
                    snapLine = control.children[i].x
                    snapDiff = Math.abs(control.children[i].x - right)
                }
                if (Math.abs(control.children[i].x + control.children[i].width - right) <= snapDiff) {
                    snapLine = control.children[i].x + control.children[i].width
                    snapDiff = Math.abs(control.children[i].x + control.children[i].width - right)
                }
            }
        }
        return snapLine
    }

    function snapTop(item, top) {

        let snapLine = top
        let snapDiff = control.snapDistanceVertical
        for (var i = 0; i < control.children.length; i++) {
            if (control.children[i] !== item) {
                if (Math.abs(control.children[i].y - top) <= snapDiff) {
                    snapLine = control.children[i].y
                    snapDiff = Math.abs(control.children[i].y - top)
                }
                if (Math.abs(control.children[i].y + control.children[i].height - top) <= snapDiff) {
                    snapLine = control.children[i].y + control.children[i].height
                    snapDiff = Math.abs(control.children[i].y + control.children[i].height - top)
                }
            }
        }
        return snapLine
    }

    function snapBottom(item, bottom) {

        let snapLine = bottom
        let snapDiff = control.snapDistanceVertical
        for (var i = 0; i < control.children.length; i++) {
            if (control.children[i] !== item) {
                if (Math.abs(control.children[i].y - bottom) <= snapDiff) {
                    snapLine = control.children[i].y
                    snapDiff = Math.abs(control.children[i].y - bottom)
                }
                if (Math.abs(control.children[i].y + control.children[i].height - bottom) <= snapDiff) {
                    snapLine = control.children[i].y + control.children[i].height
                    snapDiff = Math.abs(control.children[i].y + control.children[i].height - bottom)
                }
            }
        }
        return snapLine
    }
}
