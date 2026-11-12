import Qt5Compat.GraphicalEffects
import QtQuick 2
import QtQuick.Controls 2
import "Theme"

AbstractButton {
    id: root

    property color activeColor: Theme.buttonActiveColor
    property bool highlight: false
    property color normalColor: Theme.buttonNormalColor
    property color pressedColor: activeColor

    implicitHeight: 26
    implicitWidth: 52

    // THE VAN STUDIO [AI-generated, start]: flat rounded buttons in the
    // THE VAN RADIO style (dark surface, thin border, cyan when active).
    background: Rectangle {
        id: backgroundImage

        anchors.fill: parent
        border.color: Theme.borderColor
        border.width: 1
        color: Theme.surface2Color
        radius: Math.min(8, height / 2)
    }
    // [AI-generated, end]
    contentItem: Item {
        anchors.fill: parent

        Glow {
            id: labelGlow

            anchors.fill: parent
            color: label.color
            radius: 1
            source: label
            spread: 0.1
        }
        Label {
            id: label

            anchors.fill: parent
            color: root.normalColor
            font.bold: true
            font.capitalization: Font.AllUppercase
            font.family: Theme.fontFamily
            font.pixelSize: Theme.buttonFontPixelSize
            horizontalAlignment: Text.AlignHCenter
            text: root.text
            verticalAlignment: Text.AlignVCenter
            visible: root.text != null
        }
        Image {
            id: image

            anchors.centerIn: parent
            asynchronous: true
            fillMode: Image.PreserveAspectFit
            height: icon.height
            source: icon.source
            visible: false
            width: icon.width
        }
        ColorOverlay {
            anchors.fill: image
            antialiasing: true
            color: root.normalColor
            source: image
            visible: icon.source != null
        }
    }
    states: [
        State {
            name: "pressed"
            when: root.pressed

            PropertyChanges {
                color: Theme.accentDimColor
                target: backgroundImage
            }
            PropertyChanges {
                color: root.pressedColor
                target: label
            }
            PropertyChanges {
                target: labelGlow
                visible: true
            }
        },
        State {
            name: "active"
            when: (root.highlight || root.checked) && !root.pressed

            PropertyChanges {
                color: Theme.accentColor
                target: backgroundImage
            }
            PropertyChanges {
                color: Theme.onAccentTextColor
                target: label
            }
            PropertyChanges {
                target: labelGlow
                visible: true
            }
        },
        State {
            name: "inactive"
            when: !root.checked && !root.highlight && !root.pressed

            PropertyChanges {
                color: root.normalColor
                target: label
            }
            PropertyChanges {
                target: labelGlow
                visible: false
            }
        }
    ]
}
