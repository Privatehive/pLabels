import QtQuick
import QtQuick.Controls

Rectangle {
    id: control
    color: "red"
    property alias cursorShape: ma.cursorShape
    property Item target: Item {}
    signal resized(rect rect)
    signal doubleClicked
    property bool invertWidth: false
    property bool invertHeight: false

    MouseArea {
        id: ma
        anchors.fill: parent
        cursorShape: Qt.SizeHorCursor
        property size backupSize: Qt.size(0, 0)
        property point pressOrigin: Qt.point(0, 0)
        property point pressOriginGlobal: Qt.point(0, 0)
        onPressed: mouse => {
                       backupSize = Qt.size(control.target.width, control.target.height)
                       pressOrigin = Qt.point(control.x + mouse.x, control.y + mouse.y)
                       pressOriginGlobal = mapToItem(control.target.parent, Qt.point(mouse.x - pressOrigin.x,
                                                                                     mouse.y - pressOrigin.y))
                       mouse.accepted = true
                   }
        onPositionChanged: mouse => {
                               const newXy = mapToItem(control.target.parent, Qt.point(mouse.x - pressOrigin.x,
                                                                                       mouse.y - pressOrigin.y))
                               let newWidth
                               if (!control.invertWidth) {
                                   newWidth = backupSize.width + newXy.x - pressOriginGlobal.x
                               } else {
                                   newWidth = backupSize.width + pressOriginGlobal.x - newXy.x
                               }

                               let newHeight
                               if (!control.invertHeight) {
                                   newHeight = backupSize.height + newXy.y - pressOriginGlobal.y
                               } else {
                                   newHeight = backupSize.height + pressOriginGlobal.y - newXy.y
                               }

                               control.resized(Qt.rect(newXy.x, newXy.y, newWidth, newHeight))
                               mouse.accepted = true
                           }
        onDoubleClicked: {
            control.doubleClicked()
        }
    }
}
