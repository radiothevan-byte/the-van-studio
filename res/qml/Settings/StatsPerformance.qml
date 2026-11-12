// THE VAN STUDIO [AI-generated, start]
// Live audio engine statistics for the QML interface (replaces the
// upstream placeholder). Written by an AI assistant (Claude).
// Reads the engine controls [App],audio_latency_usage,
// audio_latency_overload, audio_latency_overload_count, samplerate and
// output_latency_ms. Useful to check that the phone keeps up during a show.
// [AI-generated, end]
import QtQuick
import QtQuick.Layouts
import Mixxx 1.0 as Mixxx
import "." as SettingComponents
import "../Theme"

Category {
    id: root

    label: qsTr("Stats & Performance")

    component StatCard: Rectangle {
        id: card

        property color valueColor: Theme.textColor
        property string description: ""
        property string title: ""
        property string value: ""

        Layout.fillWidth: true
        Layout.preferredWidth: 1
        border.color: Theme.borderColor
        color: Theme.surfaceColor
        implicitHeight: cardColumn.implicitHeight + 28
        radius: 14

        ColumnLayout {
            id: cardColumn

            anchors.left: parent.left
            anchors.margins: 14
            anchors.right: parent.right
            anchors.top: parent.top
            spacing: 4

            Text {
                color: Theme.textDimColor
                font.letterSpacing: 1
                font.pixelSize: 12
                text: card.title
            }
            Text {
                color: card.valueColor
                font.bold: true
                font.family: Theme.fontFamily
                font.pixelSize: 26
                text: card.value
            }
            Text {
                Layout.fillWidth: true
                color: Theme.textDimColor
                font.pixelSize: 12
                text: card.description
                visible: text.length > 0
                wrapMode: Text.WordWrap
            }
        }
    }

    Mixxx.ControlProxy {
        id: latencyUsage

        group: "[App]"
        key: "audio_latency_usage"
    }
    Mixxx.ControlProxy {
        id: overload

        group: "[App]"
        key: "audio_latency_overload"
    }
    Mixxx.ControlProxy {
        id: overloadCount

        group: "[App]"
        key: "audio_latency_overload_count"
    }
    Mixxx.ControlProxy {
        id: sampleRate

        group: "[App]"
        key: "samplerate"
    }
    Mixxx.ControlProxy {
        id: outputLatency

        group: "[App]"
        key: "output_latency_ms"
    }
    Flickable {
        id: flick

        anchors.fill: parent
        clip: true
        contentWidth: width
        contentHeight: content.implicitHeight + 32

        ColumnLayout {
            id: content

            // Fixed width, never negative, independent of the content.
            width: Math.max(200, flick.width - 8)
            y: 12
            spacing: 12

            Text {
                Layout.fillWidth: true
                color: Theme.textDimColor
                font.pixelSize: 14
                text: qsTr("Live values from the audio engine. If the load often goes above 80 % or the dropout counter keeps rising, increase the audio buffer in Sound hardware.")
                wrapMode: Text.WordWrap
            }
            GridLayout {
                Layout.fillWidth: true
                columnSpacing: 12
                columns: 2
                rowSpacing: 12

                StatCard {
                    description: qsTr("Share of the time between two audio buffers used to mix the sound.")
                    title: qsTr("AUDIO ENGINE LOAD")
                    value: Math.round(latencyUsage.value) + " %"
                    valueColor: latencyUsage.value > 80 ? "#ff6b6b" : latencyUsage.value > 60 ? Theme.yellow : Theme.accentColor
                }
                StatCard {
                    description: overload.value > 0 ? qsTr("Overloaded right now") : qsTr("Buffer underruns since start (audible clicks).")
                    title: qsTr("DROPOUTS")
                    value: Math.round(overloadCount.value).toString()
                    valueColor: overload.value > 0 ? "#ff6b6b" : overloadCount.value > 0 ? Theme.yellow : Theme.textColor
                }
                StatCard {
                    title: qsTr("SAMPLE RATE")
                    value: sampleRate.value > 0 ? (sampleRate.value / 1000).toFixed(1) + " kHz" : "–"
                }
                StatCard {
                    description: qsTr("Delay from the decks to the speakers or headphones.")
                    title: qsTr("OUTPUT LATENCY")
                    value: outputLatency.value > 0 ? outputLatency.value.toFixed(1) + " ms" : "–"
                }
            }
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 10
                color: Theme.surface2Color
                radius: 5

                Rectangle {
                    color: latencyUsage.value > 80 ? "#ff6b6b" : latencyUsage.value > 60 ? Theme.yellow : Theme.accentColor
                    height: parent.height
                    radius: 5
                    width: parent.width * Math.min(1, Math.max(0, latencyUsage.value / 100))
                }
            }
        }
    }
}
