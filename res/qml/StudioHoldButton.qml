// THE VAN STUDIO [AI-generated, start]
// Written by an AI assistant (Claude).
// A large touch button for ON AIR / REC. One tap starts. When active,
// stopping needs a press-and-hold (holdDuration ms) so an accidental touch
// never takes the station off air or stops the recording. A bar fills while
// the button is held; releasing early cancels.
// [AI-generated, end]
import QtQuick
import "Theme"

Item {
    id: root

    property bool active: false
    property bool compact: false
    property color activeColor: Theme.liveColor
    property int holdDuration: 1500
    property real holdProgress: 0
    property string text: ""
    property string holdText: qsTr("Hold to stop…")

    property bool _wasActiveAtPress: false
    property bool _stoppedByHold: false

    signal startRequested
    signal stopRequested

    function cancelHold() {
        holdTimer.stop();
        fillAnimation.stop();
        root.holdProgress = 0;
    }

    implicitHeight: 44
    implicitWidth: Math.max(compact ? 92 : 112, label.implicitWidth + (compact ? 24 : 36))

    Rectangle {
        id: background

        anchors.fill: parent
        border.color: root.active ? root.activeColor : Theme.borderColor
        border.width: 1
        clip: true
        color: root.active ? root.activeColor : Theme.surfaceColor
        radius: height / 2

        Rectangle {
            anchors.bottom: parent.bottom
            anchors.left: parent.left
            anchors.top: parent.top
            color: Qt.rgba(1, 1, 1, 0.35)
            width: parent.width * root.holdProgress
        }
        Text {
            id: label

            anchors.centerIn: parent
            color: root.active ? "#ffffff" : Theme.textColor
            font.bold: true
            font.family: Theme.fontFamily
            font.letterSpacing: 1
            font.pixelSize: root.compact ? 13 : 15
            text: root.holdProgress > 0 ? root.holdText : root.text
        }
    }
    NumberAnimation {
        id: fillAnimation

        duration: root.holdDuration
        from: 0
        property: "holdProgress"
        target: root
        to: 1
    }
    Timer {
        id: holdTimer

        interval: root.holdDuration

        onTriggered: {
            root.cancelHold();
            root._stoppedByHold = true;
            root.stopRequested();
        }
    }
    MouseArea {
        anchors.fill: parent

        onCanceled: root.cancelHold()
        onClicked: {
            if (root._stoppedByHold) {
                root._stoppedByHold = false;
                return;
            }
            if (!root._wasActiveAtPress && !root.active) {
                root.startRequested();
            }
        }
        onPressed: {
            root._stoppedByHold = false;
            root._wasActiveAtPress = root.active;
            if (root.active) {
                fillAnimation.restart();
                holdTimer.restart();
            }
        }
        onReleased: root.cancelHold()
    }
}
