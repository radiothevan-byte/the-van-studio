// THE VAN STUDIO [AI-generated, start]
// Live broadcasting (Icecast/Shoutcast) settings for the QML (tablet)
// interface. Written by an AI assistant (Claude). Backed by
// Mixxx.StudioSettings (src/qml/qmlstudiosettingsproxy.cpp), which edits the
// first broadcast connection profile.
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

    property var bitrateValues: []
    property bool dirty: false
    property var formatValues: []
    property var serverTypeValues: []

    function load() {
        const s = Mixxx.StudioSettings.broadcastSettings();
        if (!s.serverTypes) {
            message.color = "#D96B6B";
            message.text = "Live broadcasting is not available in this build";
            return;
        }
        root.serverTypeValues = s.serverTypes.map(o => o.value);
        serverTypeInput.model = s.serverTypes.map(o => o.label);
        serverTypeInput.currentIndex = Math.max(0, root.serverTypeValues.indexOf(s.serverType));
        hostInput.text = s.host;
        portInput.text = String(s.port);
        mountInput.text = s.mountpoint;
        loginInput.text = s.login;
        passwordInput.text = s.password;
        root.formatValues = s.formats.map(o => o.value);
        formatInput.model = s.formats.map(o => o.label);
        formatInput.currentIndex = Math.max(0, root.formatValues.indexOf(s.format));
        root.bitrateValues = s.bitrates;
        bitrateInput.model = s.bitrates.map(b => b + " kbps");
        bitrateInput.currentIndex = Math.max(0, root.bitrateValues.indexOf(s.bitrate));
        channelsInput.selected = s.channels === 1 ? "mono" : "stereo";
        streamNameInput.text = s.streamName;
        streamDescInput.text = s.streamDesc;
        streamGenreInput.text = s.streamGenre;
        streamWebsiteInput.text = s.streamWebsite;
        streamPublicInput.selected = s.streamPublic ? "on" : "off";
        metadataInput.selected = s.enableMetadata ? "on" : "off";
        metadataFormatInput.text = s.metadataFormat;
        reconnectInput.selected = s.enableReconnect ? "on" : "off";
        firstDelayInput.text = String(s.noDelayFirstReconnect ? 0 : s.reconnectFirstDelay);
        periodInput.text = String(s.reconnectPeriod);
        unlimitedInput.selected = s.limitReconnects ? "off" : "on";
        retriesInput.text = String(s.maximumRetries);
        message.text = "";
        root.dirty = false;
    }
    function save() {
        const firstDelay = Number(firstDelayInput.text) || 0;
        const error = Mixxx.StudioSettings.saveBroadcastSettings({
            "serverType": root.serverTypeValues[serverTypeInput.currentIndex],
            "host": hostInput.text,
            "port": Number(portInput.text),
            "mountpoint": mountInput.text,
            "login": loginInput.text,
            "password": passwordInput.text,
            "format": root.formatValues[formatInput.currentIndex],
            "bitrate": root.bitrateValues[bitrateInput.currentIndex],
            "channels": channelsInput.selected === "mono" ? 1 : 2,
            "streamName": streamNameInput.text,
            "streamDesc": streamDescInput.text,
            "streamGenre": streamGenreInput.text,
            "streamWebsite": streamWebsiteInput.text,
            "streamPublic": streamPublicInput.selected === "on",
            "enableMetadata": metadataInput.selected === "on",
            "metadataFormat": metadataFormatInput.text,
            "enableReconnect": reconnectInput.selected === "on",
            "noDelayFirstReconnect": firstDelay <= 0,
            "reconnectFirstDelay": firstDelay,
            "reconnectPeriod": Number(periodInput.text) || 5,
            "limitReconnects": unlimitedInput.selected !== "on",
            "maximumRetries": Number(retriesInput.text) || 10
        });
        if (error) {
            message.color = "#D96B6B";
            message.text = error;
            return false;
        }
        root.load();
        message.color = "#7DBF7D";
        message.text = broadcastEnabled.value > 0 ? "Saved. Changes apply on the next reconnection." : "Saved";
        return true;
    }

    label: "Broadcast"

    Component.onCompleted: root.load()

    component FieldLabel: Mixxx.SettingParameter {
        Layout.alignment: Qt.AlignVCenter
        Layout.preferredHeight: 44
        Layout.preferredWidth: 220

        Text {
            anchors.verticalCenter: parent.verticalCenter
            color: Theme.white
            font.pixelSize: 16
            text: parent.label
        }
    }
    component FieldInput: Skin.TextField {
        Layout.fillWidth: true
        Layout.preferredHeight: 44
        font.pixelSize: 16
        inputMethodHints: Qt.ImhNoAutoUppercase | Qt.ImhNoPredictiveText
    }
    component NumberInput: Skin.TextField {
        Layout.preferredHeight: 44
        Layout.preferredWidth: 120
        font.pixelSize: 16
        inputMethodHints: Qt.ImhDigitsOnly
    }
    component SectionTitle: Text {
        Layout.fillWidth: true
        Layout.topMargin: 10
        color: Theme.white
        font.bold: true
        font.pixelSize: 18
    }

    Mixxx.ControlProxy {
        id: broadcastEnabled

        group: "[Shoutcast]"
        key: "enabled"
    }
    Mixxx.ControlProxy {
        id: broadcastStatus

        group: "[Shoutcast]"
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
            spacing: 14

            SectionTitle {
                text: "Server"
            }
            RowLayout {
                spacing: 12

                FieldLabel {
                    label: "Server type"
                }
                Skin.ComboBox {
                    id: serverTypeInput

                    Layout.preferredHeight: 44
                    Layout.preferredWidth: 280
                    font.pixelSize: 16

                    onActivated: root.dirty = true
                }
            }
            RowLayout {
                spacing: 12

                FieldLabel {
                    label: "Host"
                }
                FieldInput {
                    id: hostInput

                    placeholderText: "stream.example.com"

                    onTextEdited: root.dirty = true
                }
            }
            RowLayout {
                spacing: 12

                FieldLabel {
                    label: "Port"
                }
                NumberInput {
                    id: portInput

                    validator: IntValidator {
                        bottom: 1
                        top: 65535
                    }

                    onTextEdited: root.dirty = true
                }
            }
            RowLayout {
                spacing: 12
                visible: root.serverTypeValues[serverTypeInput.currentIndex] !== "Shoutcast"

                FieldLabel {
                    label: "Mount point"
                }
                FieldInput {
                    id: mountInput

                    placeholderText: "/live"

                    onTextEdited: root.dirty = true
                }
            }
            RowLayout {
                spacing: 12

                FieldLabel {
                    label: "Login"
                }
                FieldInput {
                    id: loginInput

                    placeholderText: "source"

                    onTextEdited: root.dirty = true
                }
            }
            RowLayout {
                spacing: 12

                FieldLabel {
                    label: "Password"
                }
                FieldInput {
                    id: passwordInput

                    echoMode: showPassword.checked ? TextInput.Normal : TextInput.Password
                    inputMethodHints: Qt.ImhNoAutoUppercase | Qt.ImhNoPredictiveText | Qt.ImhSensitiveData

                    onTextEdited: root.dirty = true
                }
                CheckBox {
                    id: showPassword

                    text: "Show"

                    contentItem: Text {
                        color: Theme.white
                        font.pixelSize: 15
                        leftPadding: showPassword.indicator.width + 6
                        text: showPassword.text
                        verticalAlignment: Text.AlignVCenter
                    }
                }
            }
            SectionTitle {
                text: "Stream"
            }
            RowLayout {
                spacing: 12

                FieldLabel {
                    label: "Format"
                }
                Skin.ComboBox {
                    id: formatInput

                    Layout.preferredHeight: 44
                    Layout.preferredWidth: 280
                    font.pixelSize: 16

                    onActivated: root.dirty = true
                }
            }
            RowLayout {
                spacing: 12

                FieldLabel {
                    label: "Bitrate"
                }
                Skin.ComboBox {
                    id: bitrateInput

                    Layout.preferredHeight: 44
                    Layout.preferredWidth: 280
                    font.pixelSize: 16

                    onActivated: root.dirty = true
                }
            }
            RowLayout {
                spacing: 12

                FieldLabel {
                    label: "Channels"
                }
                SettingComponents.RatioChoice {
                    id: channelsInput

                    options: ["stereo", "mono"]

                    onSelectedChanged: root.dirty = true
                }
            }
            SectionTitle {
                text: "Station information"
            }
            RowLayout {
                spacing: 12

                FieldLabel {
                    label: "Station name"
                }
                FieldInput {
                    id: streamNameInput

                    onTextEdited: root.dirty = true
                }
            }
            RowLayout {
                spacing: 12

                FieldLabel {
                    label: "Description"
                }
                FieldInput {
                    id: streamDescInput

                    onTextEdited: root.dirty = true
                }
            }
            RowLayout {
                spacing: 12

                FieldLabel {
                    label: "Genre"
                }
                FieldInput {
                    id: streamGenreInput

                    onTextEdited: root.dirty = true
                }
            }
            RowLayout {
                spacing: 12

                FieldLabel {
                    label: "Website"
                }
                FieldInput {
                    id: streamWebsiteInput

                    onTextEdited: root.dirty = true
                }
            }
            RowLayout {
                spacing: 12

                FieldLabel {
                    label: "List in public directory"
                }
                SettingComponents.RatioChoice {
                    id: streamPublicInput

                    options: ["off", "on"]

                    onSelectedChanged: root.dirty = true
                }
            }
            SectionTitle {
                text: "Song titles (metadata)"
            }
            RowLayout {
                spacing: 12

                FieldLabel {
                    label: "Send song titles"
                }
                SettingComponents.RatioChoice {
                    id: metadataInput

                    options: ["off", "on"]

                    onSelectedChanged: root.dirty = true
                }
            }
            RowLayout {
                spacing: 12

                FieldLabel {
                    label: "Title format"
                }
                FieldInput {
                    id: metadataFormatInput

                    placeholderText: "$artist - $title"

                    onTextEdited: root.dirty = true
                }
            }
            SectionTitle {
                text: "Automatic reconnection"
            }
            RowLayout {
                spacing: 12

                FieldLabel {
                    label: "Reconnect automatically"
                }
                SettingComponents.RatioChoice {
                    id: reconnectInput

                    options: ["off", "on"]

                    onSelectedChanged: root.dirty = true
                }
            }
            RowLayout {
                spacing: 12
                visible: reconnectInput.selected === "on"

                FieldLabel {
                    label: "First attempt after (s)"
                }
                NumberInput {
                    id: firstDelayInput

                    validator: IntValidator {
                        bottom: 0
                        top: 3600
                    }

                    onTextEdited: root.dirty = true
                }
            }
            RowLayout {
                spacing: 12
                visible: reconnectInput.selected === "on"

                FieldLabel {
                    label: "Retry every (s)"
                }
                NumberInput {
                    id: periodInput

                    validator: IntValidator {
                        bottom: 1
                        top: 3600
                    }

                    onTextEdited: root.dirty = true
                }
            }
            RowLayout {
                spacing: 12
                visible: reconnectInput.selected === "on"

                FieldLabel {
                    label: "Keep trying forever"
                }
                SettingComponents.RatioChoice {
                    id: unlimitedInput

                    options: ["off", "on"]

                    onSelectedChanged: root.dirty = true
                }
            }
            RowLayout {
                spacing: 12
                visible: reconnectInput.selected === "on" && unlimitedInput.selected !== "on"

                FieldLabel {
                    label: "Maximum attempts"
                }
                NumberInput {
                    id: retriesInput

                    validator: IntValidator {
                        bottom: 1
                        top: 100000
                    }

                    onTextEdited: root.dirty = true
                }
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
            id: statusText

            color: broadcastStatus.value === 2 ? "#D96B6B" : Theme.textColor
            font.bold: broadcastStatus.value === 2
            font.pixelSize: 15
            text: {
                if (broadcastEnabled.value <= 0)
                    return "Off air";
                switch (broadcastStatus.value) {
                case 1:
                    return "Connecting…";
                case 2:
                    return "● ON AIR";
                case 3:
                    return "Connection failed";
                case 4:
                    return "ON AIR (with warnings)";
                default:
                    return "Enabled";
                }
            }
        }
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
            backgroundColor: "#3B7D4A"
            enabled: root.dirty
            opacity: enabled ? 1.0 : 0.5
            text: "Save"

            onPressed: root.save()
        }
        SettingComponents.FormButton {
            Layout.preferredHeight: 44
            Layout.preferredWidth: 140
            backgroundColor: broadcastEnabled.value > 0 ? Theme.liveColor : Theme.accentDimColor
            enabled: Mixxx.StudioSettings.broadcastAvailable
            text: broadcastEnabled.value > 0 ? "Stop broadcast" : "Go live"

            onPressed: {
                if (broadcastEnabled.value > 0) {
                    broadcastEnabled.value = 0;
                    return;
                }
                if (root.dirty && !root.save())
                    return;
                broadcastEnabled.value = 1;
            }
        }
    }
}
