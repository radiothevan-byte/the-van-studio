// THE VAN STUDIO [AI-generated, start]
// Written by an AI assistant (Claude).
// A touch-friendly settings row: title, optional description and a switch.
// [AI-generated, end]
import QtQuick
import QtQuick.Layouts
import "../Theme"

Rectangle {
    id: root

    property bool checked: false
    property string description: ""
    property string title: ""

    signal toggled(bool checked)

    Layout.fillWidth: true
    border.color: Theme.borderColor
    color: Theme.surfaceColor
    implicitHeight: Math.max(60, textColumn.implicitHeight + 24)
    radius: 14

    ColumnLayout {
        id: textColumn

        anchors.left: parent.left
        anchors.leftMargin: 16
        anchors.right: switchTrack.left
        anchors.rightMargin: 16
        anchors.verticalCenter: parent.verticalCenter
        spacing: 2

        Text {
            Layout.fillWidth: true
            color: Theme.textColor
            font.pixelSize: 16
            font.weight: Font.DemiBold
            text: root.title
            wrapMode: Text.WordWrap
        }
        Text {
            Layout.fillWidth: true
            color: Theme.textDimColor
            font.pixelSize: 13
            text: root.description
            visible: text.length > 0
            wrapMode: Text.WordWrap
        }
    }
    Rectangle {
        id: switchTrack

        anchors.right: parent.right
        anchors.rightMargin: 16
        anchors.verticalCenter: parent.verticalCenter
        border.color: root.checked ? Theme.accentColor : Theme.borderColor
        color: root.checked ? Theme.accentColor : Theme.surface2Color
        height: 30
        radius: 15
        width: 54

        Rectangle {
            color: root.checked ? Theme.onAccentTextColor : Theme.textDimColor
            height: 22
            radius: 11
            width: 22
            x: root.checked ? parent.width - width - 4 : 4
            y: 4

            Behavior on x {
                NumberAnimation {
                    duration: 120
                }
            }
        }
    }
    TapHandler {
        onTapped: {
            root.checked = !root.checked;
            root.toggled(root.checked);
        }
    }
}
