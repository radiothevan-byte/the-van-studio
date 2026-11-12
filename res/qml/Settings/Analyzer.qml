// THE VAN STUDIO [AI-generated, start]
// Analyzer settings for the QML interface (replaces the upstream
// placeholder). Written by an AI assistant (Claude). Backed by
// Mixxx.StudioSettings.analyzerSettings()/saveAnalyzerSettings(), which use
// the same [BPM], [Key] and [ReplayGain] settings as the desktop preferences.
// Changes are saved immediately.
// [AI-generated, end]
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Mixxx 1.0 as Mixxx
import "." as SettingComponents
import "../Theme"

Category {
    id: root

    function load() {
        const s = Mixxx.StudioSettings.analyzerSettings();
        bpmEnabled.checked = s.bpmEnabled === true;
        bpmFixedTempo.checked = s.bpmFixedTempo === true;
        bpmFast.checked = s.bpmFast === true;
        keyEnabled.checked = s.keyEnabled === true;
        keyFast.checked = s.keyFast === true;
        replayGainEnabled.checked = s.replayGainEnabled === true;
        message.text = "";
    }
    function saveValue(name, value) {
        let settings = {};
        settings[name] = value;
        const error = Mixxx.StudioSettings.saveAnalyzerSettings(settings);
        message.color = error ? "#ff6b6b" : Theme.textDimColor;
        message.text = error ? error : qsTr("Saved. Applies to tracks analyzed from now on.");
    }

    label: qsTr("Analyzer")

    Component.onCompleted: root.load()

    Flickable {
        anchors.fill: parent
        clip: true
        contentHeight: content.implicitHeight + 32

        ColumnLayout {
            id: content

            anchors.left: parent.left
            anchors.right: parent.right
            anchors.rightMargin: 8
            anchors.top: parent.top
            anchors.topMargin: 12
            spacing: 10

            Text {
                Layout.fillWidth: true
                color: Theme.textDimColor
                font.pixelSize: 14
                text: qsTr("Tracks are analyzed when they are loaded into a deck. Turning analysis off saves battery and CPU on the phone during a live show.")
                wrapMode: Text.WordWrap
            }
            Text {
                Layout.topMargin: 6
                color: Theme.accentColor
                font.bold: true
                font.letterSpacing: 1
                font.pixelSize: 13
                text: qsTr("BEATS (BPM)")
            }
            SettingComponents.StudioToggle {
                id: bpmEnabled

                description: qsTr("Detect the tempo and beat grid of each track.")
                title: qsTr("Detect BPM")

                onToggled: checked => root.saveValue("bpmEnabled", checked)
            }
            SettingComponents.StudioToggle {
                id: bpmFixedTempo

                description: qsTr("Most music has a steady tempo. Turn off for live recordings.")
                title: qsTr("Assume constant tempo")

                onToggled: checked => root.saveValue("bpmFixedTempo", checked)
            }
            SettingComponents.StudioToggle {
                id: bpmFast

                description: qsTr("Analyze only the first minute. Faster, less accurate.")
                title: qsTr("Fast BPM analysis")

                onToggled: checked => root.saveValue("bpmFast", checked)
            }
            Text {
                Layout.topMargin: 6
                color: Theme.accentColor
                font.bold: true
                font.letterSpacing: 1
                font.pixelSize: 13
                text: qsTr("MUSICAL KEY")
            }
            SettingComponents.StudioToggle {
                id: keyEnabled

                title: qsTr("Detect key")

                onToggled: checked => root.saveValue("keyEnabled", checked)
            }
            SettingComponents.StudioToggle {
                id: keyFast

                description: qsTr("Analyze only the first minute. Faster, less accurate.")
                title: qsTr("Fast key analysis")

                onToggled: checked => root.saveValue("keyFast", checked)
            }
            Text {
                Layout.topMargin: 6
                color: Theme.accentColor
                font.bold: true
                font.letterSpacing: 1
                font.pixelSize: 13
                text: qsTr("LOUDNESS")
            }
            SettingComponents.StudioToggle {
                id: replayGainEnabled

                description: qsTr("Measure the loudness of each track (ReplayGain) so songs play at an even volume on air.")
                title: qsTr("Analyze loudness")

                onToggled: checked => root.saveValue("replayGainEnabled", checked)
            }
            Text {
                id: message

                Layout.fillWidth: true
                color: Theme.textDimColor
                font.pixelSize: 13
                wrapMode: Text.WordWrap
            }
        }
    }
}
