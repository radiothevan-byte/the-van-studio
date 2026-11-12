// THE VAN STUDIO [AI-generated, start]
// Recording settings for the QML (tablet) interface.
// Written by an AI assistant (Claude). Backed by Mixxx.StudioSettings
// (src/qml/qmlstudiosettingsproxy.cpp).
// [AI-generated, end]
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Mixxx 1.0 as Mixxx
import "." as SettingComponents
import ".." as Skin
import "../Theme"

Category {
    id: root

    property bool dirty: false
    property var formatValues: []
    property var splitValues: []

    function load() {
        const s = Mixxx.StudioSettings.recordingSettings();
        directoryInput.text = s.directory || Mixxx.StudioSettings.defaultRecordingDirectory();
        root.formatValues = (s.formats || []).map(f => f.value);
        formatInput.model = (s.formats || []).map(f => f.label);
        formatInput.currentIndex = Math.max(0, root.formatValues.indexOf(s.encoding));
        root.splitValues = (s.splitOptions || []).map(o => o.value);
        splitInput.model = (s.splitOptions || []).map(o => o.label);
        splitInput.currentIndex = Math.max(0, root.splitValues.indexOf(s.fileSize));
        freeSpace.text = s.freeSpaceText || "";
        root.loadQuality();
        message.text = "";
        root.dirty = false;
    }
    function loadQuality() {
        const encoding = root.formatValues[formatInput.currentIndex];
        const q = Mixxx.StudioSettings.recordingQuality(encoding || "");
        qualityRow.visible = q.available === true;
        if (q.available) {
            qualityInput.model = q.values;
            qualityInput.currentIndex = q.index;
        }
    }
    function save() {
        const settings = {
            "directory": directoryInput.text,
            "encoding": root.formatValues[formatInput.currentIndex],
            "fileSize": root.splitValues[splitInput.currentIndex]
        };
        if (qualityRow.visible)
            settings.qualityIndex = qualityInput.currentIndex;
        const error = Mixxx.StudioSettings.saveRecordingSettings(settings);
        if (error) {
            message.color = "#ff6b6b";
            message.text = error;
            return;
        }
        root.load();
        message.color = Theme.accentColor;
        message.text = "Saved";
    }

    label: "Recording"

    Component.onCompleted: root.load()

    component FieldLabel: Mixxx.SettingParameter {
        Layout.alignment: Qt.AlignVCenter
        Layout.preferredHeight: 44
        Layout.preferredWidth: root.width < 700 ? 150 : 220

        Text {
            anchors.verticalCenter: parent.verticalCenter
            color: Theme.white
            font.pixelSize: 16
            text: parent.label
        }
    }

    Mixxx.ControlProxy {
        id: recordingStatus

        group: "[Recording]"
        key: "status"
    }
    Flickable {
        anchors.bottom: buttonRow.top
        anchors.bottomMargin: 12
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        clip: true
        contentHeight: content.implicitHeight + 40

        ColumnLayout {
            id: content

            anchors.left: parent.left
            anchors.leftMargin: 20
            anchors.right: parent.right
            anchors.rightMargin: 20
            anchors.top: parent.top
            anchors.topMargin: 20
            spacing: 18

            Text {
                Layout.fillWidth: true
                color: Theme.textColor
                font.pixelSize: 14
                text: recordingStatus.value >= 2 ? "● Recording in progress. Changes apply to the next recording." : "Records the full main mix (music and microphone)."
                wrapMode: Text.WordWrap
            }
            RowLayout {
                spacing: 12

                FieldLabel {
                    label: "Recording folder"
                }
                Skin.TextField {
                    id: directoryInput

                    Layout.fillWidth: true
                    Layout.preferredHeight: 44
                    font.pixelSize: 16
                    inputMethodHints: Qt.ImhNoAutoUppercase | Qt.ImhNoPredictiveText

                    onTextEdited: root.dirty = true
                }
                SettingComponents.FormButton {
                    Layout.preferredHeight: 44
                    Layout.preferredWidth: 110
                    text: "Default"

                    onPressed: {
                        directoryInput.text = Mixxx.StudioSettings.defaultRecordingDirectory();
                        root.dirty = true;
                    }
                }
            }
            RowLayout {
                spacing: 12

                FieldLabel {
                    label: "Free space"
                }
                Text {
                    id: freeSpace

                    color: Theme.textColor
                    font.pixelSize: 16
                }
            }
            RowLayout {
                spacing: 12

                FieldLabel {
                    label: "File format"
                }
                Skin.ComboBox {
                    id: formatInput

                    Layout.preferredHeight: 44
                    Layout.fillWidth: root.width < 700
                    Layout.preferredWidth: 280
                    font.pixelSize: 16

                    onActivated: {
                        root.loadQuality();
                        root.dirty = true;
                    }
                }
            }
            RowLayout {
                id: qualityRow

                spacing: 12

                FieldLabel {
                    label: "Quality"
                }
                Skin.ComboBox {
                    id: qualityInput

                    Layout.preferredHeight: 44
                    Layout.fillWidth: root.width < 700
                    Layout.preferredWidth: 280
                    font.pixelSize: 16

                    onActivated: root.dirty = true
                }
            }
            RowLayout {
                spacing: 12

                FieldLabel {
                    label: "Split file every"
                }
                Skin.ComboBox {
                    id: splitInput

                    Layout.preferredHeight: 44
                    Layout.fillWidth: root.width < 700
                    Layout.preferredWidth: 280
                    font.pixelSize: 16

                    onActivated: root.dirty = true
                }
            }
            Text {
                Layout.fillWidth: true
                color: Theme.textColor
                font.pixelSize: 13
                text: "Tip: splitting keeps each file small, so an interruption only affects the current part. WAV uses about 600 MB per hour, MP3 at 192 kbps about 85 MB per hour."
                wrapMode: Text.WordWrap
            }
        }
    }
    RowLayout {
        id: buttonRow

        anchors.bottom: parent.bottom
        anchors.bottomMargin: 10
        anchors.left: parent.left
        anchors.leftMargin: 20
        anchors.right: parent.right
        anchors.rightMargin: 20
        spacing: 12

        Text {
            id: message

            Layout.fillWidth: true
            color: "#7DBF7D"
            elide: Text.ElideRight
            font.pixelSize: 15
        }
        SettingComponents.FormButton {
            Layout.preferredHeight: 44
            Layout.preferredWidth: 120
            enabled: root.dirty
            opacity: enabled ? 1.0 : 0.5
            text: "Cancel"

            onPressed: root.load()
        }
        SettingComponents.FormButton {
            Layout.preferredHeight: 44
            Layout.preferredWidth: 120
            backgroundColor: Theme.accentColor
            enabled: root.dirty
            opacity: enabled ? 1.0 : 0.5
            text: "Save"

            onPressed: root.save()
        }
    }
}
