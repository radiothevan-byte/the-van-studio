import "." as Skin
import Mixxx 1.0 as Mixxx
import QtQuick 2.12
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Window
import QtQuick.Shapes
import Qt5Compat.GraphicalEffects
import "Theme"

Item {
    id: root

    required property ApplicationWindow applicationWindow
    property alias menuBar: nativeApplicationMenuLoader.item

    property alias editDeck: editDeckButton.checked
    property var focusedDeck: null
    property alias maximizeLibrary: maximizeLibraryButton.checked
    readonly property int numDecks: 4
    readonly property int numPreviewDecks: 1
    readonly property int numSamplers: 16
    readonly property int waveformOverviewTypeRgb: 2
    readonly property bool show4decks: show4DecksButton.checked && show4DecksButton.visible
    property alias showEffects: showEffectsButton.checked
    property alias showSamplers: showSamplersButton.checked
    // THE VAN STUDIO [AI-generated]: tighter studio bar on phone screens
    readonly property bool compactBar: width < 1000

    Loader {
        id: nativeApplicationMenuLoader

        active: Qt.platform.os === "osx" || (Mixxx.Application.supportsGlobalMenuBar && root.applicationWindow.visibility !== Window.FullScreen)

        sourceComponent: Skin.MainMenuBar {
            actions: applicationMenuActions
        }
    }
    Skin.ApplicationMenuCommands {
        id: applicationMenuCommands

        applicationWindow: root.applicationWindow

        onShowDeveloperToolsRequested: {
            devToolsWindow.show();
            devToolsWindow.raise();
            devToolsWindow.requestActivate();
        }
    }
    Skin.ApplicationMenuActions {
        id: applicationMenuActions

        applicationWindow: root.applicationWindow
        commands: applicationMenuCommands
        numberOfDecks: root.show4decks ? root.numDecks : 2

        onFocusLibrarySearchRequested: {
            if (library.item) {
                library.item.focusSearch();
            }
        }
    }
    Skin.LibraryScanSummaryDialog {
    }
    Mixxx.ControlProxy {
        group: "[App]"
        key: "num_decks"

        onInitializedChanged: {
            value = root.numDecks;
        }
    }
    Mixxx.ControlProxy {
        group: "[App]"
        key: "num_samplers"

        onInitializedChanged: {
            value = root.numSamplers;
        }
    }
    Mixxx.ControlProxy {
        group: "[App]"
        key: "num_preview_decks"

        onInitializedChanged: {
            value = root.numPreviewDecks;
        }
    }
    Mixxx.ControlProxy {
        group: "[Waveform]"
        key: "WaveformOverviewType"

        onInitializedChanged: {
            value = root.waveformOverviewTypeRgb;
        }
    }
    Column {
        id: content

        anchors.fill: parent

        move: Transition {
            NumberAnimation {
                duration: 150
                properties: "x,y"
            }
        }

        Rectangle {
            id: toolbar

            color: Theme.toolbarBackgroundColor
            height: 56
            radius: 1
            width: parent.width

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 10
                anchors.rightMargin: 10
                spacing: 8

                // THE VAN STUDIO [AI-generated, start]: brand and the
                // ON AIR / REC controls on the left. Stopping either needs a
                // press-and-hold (see StudioHoldButton.qml). The MIC button is
                // deliberately on the opposite (right) end of this bar so it
                // cannot be hit by mistake next to ON AIR / REC.
                Column {
                    Layout.alignment: Qt.AlignVCenter
                    Layout.rightMargin: 6

                    Text {
                        color: Theme.accentColor
                        font.bold: true
                        font.family: Theme.fontFamily
                        font.letterSpacing: 2
                        font.pixelSize: 9
                        text: "RADIO ON WHEELS"
                    }
                    Text {
                        color: Theme.textColor
                        font.bold: true
                        font.family: Theme.fontFamily
                        font.pixelSize: root.compactBar ? 14 : 17
                        text: "THE VAN STUDIO"
                    }
                }
                Skin.StudioHoldButton {
                    id: onAirButton

                    Layout.alignment: Qt.AlignVCenter
                    active: studioBroadcastEnabled.value > 0
                    compact: root.compactBar
                    text: active ? "● ON AIR" : "● " + qsTr("GO LIVE")
                    visible: Mixxx.Application.liveBroadcastingAvailable

                    onStartRequested: studioBroadcastEnabled.value = 1
                    onStopRequested: studioBroadcastEnabled.value = 0

                    Mixxx.ControlProxy {
                        id: studioBroadcastEnabled

                        group: "[Shoutcast]"
                        key: "enabled"
                    }
                }
                Skin.StudioHoldButton {
                    id: recordButton

                    Layout.alignment: Qt.AlignVCenter
                    active: studioRecordingStatus.value === 2
                    compact: root.compactBar
                    text: "● REC"

                    onStartRequested: studioRecordingToggle.trigger()
                    onStopRequested: studioRecordingToggle.trigger()

                    Mixxx.ControlProxy {
                        id: studioRecordingStatus

                        group: "[Recording]"
                        key: "status"
                    }
                    Mixxx.ControlProxy {
                        id: studioRecordingToggle

                        group: "[Recording]"
                        key: "toggle_recording"
                    }
                }
                Item {
                    Layout.preferredWidth: root.compactBar ? 4 : 16
                }
                // [AI-generated, end]
                Skin.Button {
                    id: show4DecksButton

                    implicitHeight: 40 // THE VAN STUDIO [AI-generated]: finger-sized
                    activeColor: Theme.white
                    checkable: true
                    text: "4 Decks"
                    visible: root.height > 515
                }
                Skin.Button {
                    id: maximizeLibraryButton

                    implicitHeight: 40 // THE VAN STUDIO [AI-generated]: finger-sized
                    activeColor: Theme.white
                    checkable: true
                    text: "Library"

                    onCheckedChanged: () => {
                        showMaximizedLibrary.value = this.checked;
                    }

                    Mixxx.ControlProxy {
                        id: showMaximizedLibrary

                        group: "[Skin]"
                        key: "show_maximized_library"

                        onValueChanged: () => {
                            maximizeLibraryButton.checked = this.value;
                        }
                    }
                }
                Skin.Button {
                    id: showEffectsButton

                    implicitHeight: 40 // THE VAN STUDIO [AI-generated]: finger-sized
                    activeColor: Theme.white
                    checkable: true
                    text: "Effects"

                    // THE VAN STUDIO [AI-generated]: one panel at a time
                    onCheckedChanged: if (checked)
                        showSamplersButton.checked = false
                }
                Skin.Button {
                    id: showAuxButton

                    implicitHeight: 40 // THE VAN STUDIO [AI-generated]: finger-sized
                    activeColor: Theme.white
                    checkable: true
                    text: "Aux"
                    // THE VAN STUDIO [AI-generated]: nothing is connected to
                    // this button yet in the QML skin, so do not show it.
                    visible: false
                }
                Skin.Button {
                    id: showSamplersButton

                    implicitHeight: 40 // THE VAN STUDIO [AI-generated]: finger-sized
                    activeColor: Theme.white
                    checkable: true
                    text: "Sampler"

                    // THE VAN STUDIO [AI-generated]: one panel at a time
                    onCheckedChanged: if (checked)
                        showEffectsButton.checked = false
                }
                Item {
                    Layout.fillWidth: true
                }
                Skin.Button {
                    id: editDeckButton

                    implicitHeight: 40 // THE VAN STUDIO [AI-generated]: finger-sized
                    activeColor: Theme.white
                    checkable: true
                    text: "Edit"
                    visible: root.width > 960 // THE VAN STUDIO [AI-generated]: room for MIC on phones
                }
                Skin.Button {
                    id: showDevToolsButton

                    implicitHeight: 40 // THE VAN STUDIO [AI-generated]: finger-sized
                    activeColor: Theme.white
                    checkable: true
                    checked: devToolsWindow.visible
                    text: "Develop"
                    visible: root.width > 1100 // THE VAN STUDIO [AI-generated]: room for MIC on phones

                    onClicked: {
                        if (devToolsWindow.visible)
                            devToolsWindow.close();
                        else
                            devToolsWindow.show();
                    }

                    DeveloperToolsWindow {
                        id: devToolsWindow

                        height: 480
                        width: 640
                    }
                }
                Skin.Button {
                    id: showPreferencesButton

                    implicitHeight: 40 // THE VAN STUDIO [AI-generated]: finger-sized
                    activeColor: Theme.white
                    checked: settingsPopup.opened
                    icon.height: 22
                    icon.source: "images/gear.svg"
                    icon.width: 22
                    implicitWidth: implicitHeight

                    onClicked: {
                        if (!settingsPopup.opened) {
                            settingsPopup.open();
                        }
                    }
                    onPressAndHold: {
                        Mixxx.PreferencesDialog.show();
                    }
                }
                // THE VAN STUDIO [AI-generated, start]: microphone on/off
                // (talkover of the first microphone input), far from ON AIR.
                Rectangle {
                    id: micButton

                    readonly property bool micOn: studioMicTalkover.value > 0

                    Layout.alignment: Qt.AlignVCenter
                    Layout.leftMargin: root.compactBar ? 12 : 24
                    border.color: Theme.yellow
                    border.width: 2
                    color: micOn ? Theme.yellow : Theme.surface2Color
                    implicitHeight: 44
                    implicitWidth: root.compactBar ? 88 : 120
                    radius: 14

                    Text {
                        anchors.centerIn: parent
                        color: micButton.micOn ? Theme.onAccentTextColor : Theme.textColor
                        font.bold: true
                        font.family: Theme.fontFamily
                        font.pixelSize: root.compactBar ? 14 : 16
                        // "NO MIC": no sound input is routed to Microphone 1
                        text: studioMicConfigured.value > 0 ? (micButton.micOn ? "MIC ON" : "MIC") : "NO MIC"
                    }
                    Rectangle {
                        // Live microphone level, so it is visible whether
                        // the phone delivers any sound from the microphone.
                        anchors.bottom: parent.bottom
                        anchors.bottomMargin: 5
                        anchors.left: parent.left
                        anchors.leftMargin: 10
                        color: micButton.micOn ? Theme.onAccentTextColor : Theme.accentColor
                        height: 4
                        radius: 2
                        visible: studioMicConfigured.value > 0
                        width: (parent.width - 20) * Math.min(1, Math.max(0, studioMicVu.value))
                    }
                    Mixxx.ControlProxy {
                        id: studioMicConfigured

                        group: "[Microphone]"
                        key: "input_configured"
                    }
                    Mixxx.ControlProxy {
                        id: studioMicVu

                        group: "[Microphone]"
                        key: "vu_meter"
                    }
                    MouseArea {
                        anchors.fill: parent

                        onClicked: studioMicTalkover.value = micButton.micOn ? 0 : 1
                    }
                    Mixxx.ControlProxy {
                        id: studioMicTalkover

                        group: "[Microphone]"
                        key: "talkover"
                    }
                }
                // [AI-generated, end]
            }
        }
        SplitView {
            id: splitView

            height: parent.height - y
            orientation: Qt.Vertical
            width: parent.width

            handle: Rectangle {
                id: handleDelegate

                property color handleColor: SplitHandle.pressed || SplitHandle.hovered ? Theme.libraryPanelSplitterHandleActive : Theme.libraryPanelSplitterHandle
                property int handleSize: SplitHandle.pressed || SplitHandle.hovered ? 6 : 3

                clip: true
                color: Theme.libraryPanelSplitterBackground
                implicitHeight: 4
                implicitWidth: 8

                containmentMask: Item {
                    height: 8
                    width: splitView.width
                    x: (handleDelegate.width - width) / 2
                }

                RowLayout {
                    anchors.centerIn: parent

                    Repeater {
                        model: 3

                        Rectangle {
                            color: handleColor
                            height: handleSize
                            radius: handleSize
                            width: handleSize
                        }
                    }
                }
            }

            Item {
                id: waveforms

                SplitView.fillHeight: !library.active
                SplitView.preferredHeight: library.active ? 120 : undefined
                visible: !root.maximizeLibrary

                FadeBehavior on visible {
                    fadeTarget: waveforms
                }

                Loader {
                    id: deck3waveform

                    readonly property string group: "[Channel3]"

                    active: root.show4decks
                    anchors.top: parent.top
                    height: parent.height / 4
                    width: root.width

                    sourceComponent: Component {
                        Skin.WaveformDisplay {
                            group: deck3waveform.group

                            FadeBehavior on visible {
                                fadeTarget: deck3waveform
                            }
                        }
                    }
                }
                Skin.WaveformDisplay {
                    id: deck1waveform

                    anchors.top: root.show4decks ? deck3waveform.bottom : parent.top
                    group: "[Channel1]"
                    height: parent.height / (root.show4decks ? 4 : 2)
                    width: root.width
                }
                Skin.WaveformDisplay {
                    id: deck2waveform

                    anchors.bottom: root.show4decks ? deck4waveform.top : parent.bottom
                    group: "[Channel2]"
                    height: parent.height / (root.show4decks ? 4 : 2)
                    width: root.width
                }
                Loader {
                    id: deck4waveform

                    readonly property string group: "[Channel4]"

                    active: root.show4decks
                    anchors.bottom: parent.bottom
                    height: parent.height / 4
                    width: root.width

                    sourceComponent: Component {
                        Skin.WaveformDisplay {
                            group: deck4waveform.group

                            FadeBehavior on visible {
                                fadeTarget: deck4waveform
                            }
                        }
                    }
                }
                Rectangle {
                    width: 125

                    gradient: Gradient {
                        orientation: Gradient.Horizontal

                        GradientStop {
                            color: Theme.darkGray
                            position: 0
                        }
                        GradientStop {
                            color: 'transparent'
                            position: 1
                        }
                    }

                    anchors {
                        bottom: parent.bottom
                        left: parent.left
                        top: parent.top
                    }
                }
                Rectangle {
                    width: 125

                    gradient: Gradient {
                        orientation: Gradient.Horizontal

                        GradientStop {
                            color: 'transparent'
                            position: 0
                        }
                        GradientStop {
                            color: Theme.darkGray
                            position: 1
                        }
                    }

                    anchors {
                        bottom: parent.bottom
                        right: parent.right
                        top: parent.top
                    }
                }
            }
            Item {
                SplitView.fillHeight: library.active
                SplitView.maximumHeight: library.active ? undefined : mixer.height
                SplitView.minimumHeight: mixer.height

                Deck {
                    id: deck1

                    editMode: root.editDeck
                    group: "[Channel1]"
                    height: root.maximizeLibrary ? 80 : root.show4decks ? mixer.height / 2 : mixer.height
                    minimized: root.maximizeLibrary

                    Behavior on height {
                        SpringAnimation {
                            id: deck1HeightAnimation

                            damping: 0.2
                            duration: 500
                            spring: 2
                        }
                    }
                    states: [
                        State {
                            when: root.maximizeLibrary

                            AnchorChanges {
                                anchors.right: parent.horizontalCenter
                                target: deck1
                            }
                        }
                    ]

                    onToggleFocus: {
                        root.focusedDeck = (root.focusedDeck === deck1) ? null : deck1;
                    }

                    anchors {
                        left: parent.left
                        right: mixer.left
                        top: parent.top
                    }
                }
                Mixer {
                    id: mixer

                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.top: parent.top
                    groups: [deck1.group, deck2.group, deck3.group, deck4.group]
                    show4decks: root.show4decks
                    visible: !root.maximizeLibrary

                    Behavior on height {
                        SpringAnimation {
                            id: mixerHeightAnimation

                            damping: 0.2
                            duration: 500
                            spring: 2
                        }
                    }
                    states: [
                        State {
                            when: root.focusedDeck === deck1 && root.width < 1400 && !root.maximizeLibrary

                            AnchorChanges {
                                anchors.horizontalCenter: parent.right
                                target: mixer
                            }
                            PropertyChanges {
                                target: deck1
                                width: root.width - (mixer.width / 2)
                            }
                        },
                        State {
                            when: root.focusedDeck === deck2 && root.width < 1400 && !root.maximizeLibrary

                            AnchorChanges {
                                anchors.horizontalCenter: parent.left
                                target: mixer
                            }
                            PropertyChanges {
                                target: deck2
                                width: root.width - (mixer.width / 2)
                            }
                        },
                        State {
                            when: (!root.focusedDeck || root.width > 1400) && !root.maximizeLibrary

                            AnchorChanges {
                                anchors.horizontalCenter: parent.horizontalCenter
                                target: mixer
                            }
                            PropertyChanges {
                                target: deck1
                                width: (root.width - mixer.width) / 2
                            }
                            PropertyChanges {
                                target: deck2
                                width: (root.width - mixer.width) / 2
                            }
                        },
                        State {
                            when: root.maximizeLibrary

                            AnchorChanges {
                                anchors.horizontalCenter: parent.horizontalCenter
                                target: mixer
                            }
                            PropertyChanges {
                                target: deck1
                                width: root.width / 2
                            }
                            PropertyChanges {
                                target: deck2
                                width: root.width / 2
                            }
                        }
                    ]
                    transitions: Transition {
                        AnchorAnimation {
                            duration: 200
                        }
                    }
                    FadeBehavior on visible {
                        fadeTarget: mixer
                    }
                }
                Deck {
                    id: deck2

                    editMode: root.editDeck
                    group: "[Channel2]"
                    height: root.maximizeLibrary ? 80 : root.show4decks ? mixer.height / 2 : mixer.height
                    minimized: root.maximizeLibrary

                    Behavior on height {
                        SpringAnimation {
                            id: deck2HeightAnimation

                            damping: 0.2
                            duration: 500
                            spring: 2
                        }
                    }
                    states: [
                        State {
                            when: root.maximizeLibrary

                            AnchorChanges {
                                anchors.left: parent.horizontalCenter
                                target: deck2
                            }
                        }
                    ]

                    onToggleFocus: {
                        root.focusedDeck = (root.focusedDeck === deck2) ? null : deck2;
                    }

                    anchors {
                        left: mixer.right
                        right: parent.right
                        top: parent.top
                    }
                }
                Loader {
                    id: deck3

                    readonly property string group: "[Channel3]"

                    active: root.show4decks
                    height: active ? (root.maximizeLibrary ? 80 : mixer.height / 2) : 0

                    Behavior on height {
                        SpringAnimation {
                            id: deck3HeightAnimation

                            damping: 0.2
                            duration: 500
                            spring: 2
                        }
                    }
                    sourceComponent: Component {
                        Deck {
                            anchors.bottom: parent.bottom
                            anchors.left: parent.left
                            editMode: root.editDeck
                            group: deck3.group
                            minimized: root.maximizeLibrary
                        }
                    }
                    states: [
                        State {
                            when: root.maximizeLibrary

                            AnchorChanges {
                                anchors.right: parent.horizontalCenter
                                target: deck3
                            }
                        }
                    ]

                    anchors {
                        left: parent.left
                        right: mixer.left
                        top: deck1.bottom
                    }
                }
                Loader {
                    id: deck4

                    readonly property string group: "[Channel4]"

                    active: root.show4decks
                    height: active ? (root.maximizeLibrary ? 80 : mixer.height / 2) : 0

                    Behavior on height {
                        SpringAnimation {
                            id: deck4HeightAnimation

                            damping: 0.2
                            duration: 500
                            spring: 2
                        }
                    }
                    sourceComponent: Component {
                        Deck {
                            anchors.bottom: parent.bottom
                            anchors.right: parent.right
                            editMode: root.editDeck
                            group: deck4.group
                            minimized: root.maximizeLibrary
                        }
                    }
                    states: [
                        State {
                            when: root.maximizeLibrary

                            AnchorChanges {
                                anchors.left: parent.horizontalCenter
                                target: deck4
                            }
                        }
                    ]

                    anchors {
                        left: mixer.right
                        right: parent.right
                        top: deck2.bottom
                    }
                }

                // Skin.SamplerRow {
                //     id: samplers
                //     visible: root.showSamplers
                //     width: parent.width

                //     Skin.FadeBehavior on visible {
                //         fadeTarget: samplers
                //     }
                // }
                // Skin.EffectRow {
                //     id: effects
                //     visible: root.showEffects
                //     width: parent.width

                //     Skin.FadeBehavior on visible {
                //         fadeTarget: effects
                //     }
                // }
                Loader {
                    id: library

                    active: root.maximizeLibrary || root.height - mixer.height >= 400
                    width: parent.width

                    sourceComponent: Component {
                        Skin.Library {
                            anchors.fill: parent
                        }
                    }
                    states: [
                        State {
                            when: root.maximizeLibrary && root.show4decks

                            AnchorChanges {
                                anchors.top: deck4.bottom
                                target: library
                            }
                        },
                        State {
                            when: root.maximizeLibrary && !root.show4decks

                            AnchorChanges {
                                anchors.top: deck1.bottom
                                target: library
                            }
                        },
                        State {
                            when: !root.maximizeLibrary && root.height - mixer.height < 400

                            PropertyChanges {
                                target: library
                                visible: false
                            }
                        }
                    ]

                    anchors {
                        bottom: parent.bottom
                        top: mixer.bottom
                    }
                }
            }
        }
    }
    // THE VAN STUDIO [AI-generated, start]
    // Effects and Sampler panels. The upstream QML skin has these rows
    // commented out of the main layout; on a phone they open as a panel over
    // the lower part of the screen instead, so the decks keep their size.
    component StudioBottomPanel: Popup {
        id: panel

        property Component content
        property bool shown: false
        property string title: ""

        signal closeRequested

        closePolicy: Popup.CloseOnEscape
        height: Math.min(parent.height * 0.62, Math.max(220, panelLoader.implicitHeight + 64))
        modal: false
        padding: 0
        width: parent.width
        x: 0
        y: parent.height - height

        background: Rectangle {
            border.color: Theme.borderColor
            color: Theme.backgroundColor
            radius: 18
        }
        contentItem: Item {
            Text {
                id: panelTitle

                anchors.left: parent.left
                anchors.leftMargin: 18
                anchors.top: parent.top
                anchors.topMargin: 14
                color: Theme.accentColor
                font.bold: true
                font.letterSpacing: 1
                font.pixelSize: 14
                text: panel.title
            }
            Rectangle {
                anchors.right: parent.right
                anchors.rightMargin: 12
                anchors.top: parent.top
                anchors.topMargin: 6
                border.color: Theme.borderColor
                color: Theme.surface2Color
                height: 40
                radius: 20
                width: 40

                Text {
                    anchors.centerIn: parent
                    color: Theme.textColor
                    font.pixelSize: 18
                    text: "✕"
                }
                TapHandler {
                    onTapped: panel.closeRequested()
                }
            }
            Flickable {
                anchors.bottom: parent.bottom
                anchors.left: parent.left
                anchors.margins: 8
                anchors.right: parent.right
                anchors.top: parent.top
                anchors.topMargin: 52
                clip: true
                contentHeight: panelLoader.implicitHeight
                contentWidth: width

                Loader {
                    id: panelLoader

                    active: panel.shown
                    sourceComponent: panel.content
                    width: parent.width
                }
            }
        }

        onClosed: panel.closeRequested()
        onShownChanged: panel.shown ? panel.open() : panel.close()
    }

    StudioBottomPanel {
        shown: root.showEffects
        title: qsTr("EFFECTS")

        content: Component {
            Skin.EffectRow {
            }
        }

        onCloseRequested: showEffectsButton.checked = false
    }
    StudioBottomPanel {
        shown: root.showSamplers
        title: qsTr("SAMPLER")

        content: Component {
            Skin.SamplerRow {
                columns: 4
            }
        }

        onCloseRequested: showSamplersButton.checked = false
    }
    // [AI-generated, end]
    Skin.Settings {
        id: settingsPopup

        height: Math.min(840, parent.height)
        modal: true
        width: Math.min(1400, parent.width)
        x: Math.round((parent.width - width) / 2)
        y: Math.round((parent.height - height) / 2)

        Overlay.modal: Rectangle {
            id: overlayModal

            readonly property bool hasHardwareAcceleration: Mixxx.Config.useAcceleration
            property real radius: 12

            anchors.fill: parent
            color: Qt.alpha('#00000010', hasHardwareAcceleration ? 1.0 : 0.6)

            Repeater {
                model: hasHardwareAcceleration ? 1 : 0

                GaussianBlur {
                    anchors.fill: overlayModal
                    deviation: 4
                    radius: Math.max(0, overlayModal.radius)
                    samples: 16
                    source: content
                }
            }
        }
    }
}
