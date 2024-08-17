import QtQuick
import QtQuick.Controls

Container {

    id: control

    contentItem: Item {

        width: control.width
        implicitWidth: flow.implicitWidth
        implicitHeight: flow.implicitHeight

        ToolBar {

            width: parent.width

            Flow {
                id: flow
                width: parent.width
                Repeater {
                    model: control.contentModel
                }
            }
        }
    }
}
