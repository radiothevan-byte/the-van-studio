import "." as Skin
import Mixxx 1.0 as Mixxx
import QtQuick 2.12
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Shapes
import Qt5Compat.GraphicalEffects
import "Theme"
import "Settings" as Settings

Popup {
    id: root

    property var activeCategory: null
    // THE VAN STUDIO [AI-generated, start]: phone layout. On narrow screens
    // the category list and the selected page take the full width in turn,
    // with a back button, like a phone settings app.
    readonly property bool compact: width < 1000
    property bool pageOpen: false
    readonly property bool showList: !compact || !pageOpen
    readonly property bool showPage: !compact || pageOpen
    // [AI-generated, end]
    property alias activeCategoryIndex: categoryList.currentIndex
    readonly property var manager: managerItem
    property alias sections: managerItem.data

    function updateActiveCategory() {
        root.activeCategory?.deactivated();
        root.activeCategory = managerItem.data[categoryList.currentIndex] ?? null;
        root.activeCategory?.activated();
    }

    horizontalPadding: compact ? 8 : 20
    verticalPadding: compact ? 8 : 20

    onOpened: root.pageOpen = false

    background: Rectangle {
        anchors.fill: parent
        border.color: Theme.borderColor
        border.width: 1
        color: Theme.backgroundColor
        opacity: parent.radius < 0 ? Math.max(0.1, 1 + parent.radius / 8) : 1
        radius: root.compact ? 0 : 18
    }
    contentItem: Item {
        anchors.centerIn: parent
        height: parent.height - 2 * root.verticalPadding
        width: parent.width - 2 * root.horizontalPadding

        // THE VAN STUDIO [AI-generated, start]: header with back and close
        RowLayout {
            id: settingsHeader

            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top
            height: 48
            spacing: 8

            Rectangle {
                Layout.preferredHeight: 44
                Layout.preferredWidth: backLabel.implicitWidth + 28
                border.color: Theme.borderColor
                color: Theme.surface2Color
                radius: 22
                visible: root.compact && root.pageOpen

                Text {
                    id: backLabel

                    anchors.centerIn: parent
                    color: Theme.textColor
                    font.bold: true
                    font.pixelSize: 15
                    text: "‹ " + qsTr("Back")
                }
                TapHandler {
                    onTapped: root.pageOpen = false
                }
            }
            Text {
                Layout.fillWidth: true
                color: Theme.textColor
                elide: Text.ElideRight
                font.bold: true
                font.family: Theme.fontFamily
                font.pixelSize: 20
                text: root.compact && root.pageOpen && root.activeCategory ? root.activeCategory.label : qsTr("Settings")
            }
            Rectangle {
                Layout.preferredHeight: 44
                Layout.preferredWidth: 44
                border.color: Theme.borderColor
                color: Theme.surface2Color
                radius: 22

                Text {
                    anchors.centerIn: parent
                    color: Theme.textColor
                    font.pixelSize: 20
                    text: "✕"
                }
                TapHandler {
                    onTapped: root.close()
                }
            }
        }
        // [AI-generated, end]

        RowLayout {
            anchors.bottom: parent.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: settingsHeader.bottom
            anchors.topMargin: 8
            spacing: root.compact ? 0 : 16

            Rectangle {
                Layout.fillHeight: true
                Layout.fillWidth: root.compact
                Layout.preferredWidth: root.compact ? -1 : 280
                color: Theme.surfaceColor
                radius: 14
                visible: root.showList

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 8
                    spacing: 6

                    Rectangle {
                        id: searchSetting

                        property bool active: false
                        property alias input: searchInput

                        Layout.fillWidth: true
                        border.color: Theme.borderColor
                        color: Theme.surface2Color
                        height: 44
                        radius: 22

                        Text {
                            id: searchInputPlaceholder

                            anchors.left: parent.left
                            anchors.leftMargin: 16
                            anchors.verticalCenter: parent.verticalCenter
                            color: Theme.textDimColor
                            font.pixelSize: 15
                            text: qsTr('Search...')
                            visible: !parent.active
                        }
                        TextInput {
                            id: searchInput

                            anchors.left: parent.left
                            anchors.leftMargin: 16
                            anchors.right: parent.right
                            anchors.rightMargin: 16
                            anchors.verticalCenter: parent.verticalCenter
                            color: Theme.textColor
                            font.pixelSize: 15
                            visible: parent.active

                            onActiveFocusChanged: {
                                parent.active = activeFocus;
                            }
                            onTextEdited: {
                                root.manager.search(text);
                            }
                        }
                        TapHandler {
                            onTapped: {
                                parent.active = true;
                                searchInput.forceActiveFocus();
                            }
                        }
                    }
                    ListView {
                        id: categoryList

                        Layout.fillHeight: true
                        Layout.fillWidth: true
                        clip: true
                        currentIndex: 0
                        focus: true
                        model: sectionProperties
                        visible: !searchSetting.active

                        delegate: Rectangle {
                            required property int index
                            required property var label

                            color: ListView.isCurrentItem && !root.compact ? Theme.surface2Color : "transparent"
                            height: root.compact ? 54 : 46
                            radius: 10
                            width: ListView.view.width

                            Rectangle {
                                // THE VAN STUDIO [AI-generated]: accent marker on the selected category
                                anchors.left: parent.left
                                anchors.verticalCenter: parent.verticalCenter
                                color: Theme.accentColor
                                height: parent.height - 16
                                radius: 2
                                visible: parent.ListView.isCurrentItem && !root.compact
                                width: 4
                            }
                            Rectangle {
                                anchors.bottom: parent.bottom
                                anchors.left: parent.left
                                anchors.right: parent.right
                                color: Theme.borderColor
                                height: 1
                                visible: root.compact
                            }
                            Text {
                                anchors.right: parent.right
                                anchors.rightMargin: 12
                                anchors.verticalCenter: parent.verticalCenter
                                color: Theme.textDimColor
                                font.pixelSize: 22
                                text: "›"
                                visible: root.compact
                            }

                            Image {
                                id: handleImage

                                anchors.left: parent.left
                                anchors.leftMargin: 14
                                anchors.verticalCenter: parent.verticalCenter
                                fillMode: Image.PreserveAspectFit
                                height: 22
                                source: "images/gear.svg"
                                visible: false
                            }
                            ColorOverlay {
                                anchors.fill: handleImage
                                antialiasing: true
                                color: parent.ListView.isCurrentItem ? Theme.accentColor : Theme.textDimColor
                                source: handleImage
                            }
                            Text {
                                anchors.left: handleImage.right
                                anchors.leftMargin: 12
                                anchors.verticalCenter: parent.verticalCenter
                                color: Theme.textColor
                                font.bold: parent.ListView.isCurrentItem
                                font.pixelSize: root.compact ? 17 : 15
                                text: label
                            }
                            TapHandler {
                                onTapped: {
                                    categoryList.currentIndex = index;
                                    root.pageOpen = true;
                                }
                            }
                        }
                    }
                    ListView {
                        id: settingResultList

                        Layout.fillHeight: true
                        Layout.fillWidth: true
                        clip: true
                        focus: true
                        model: root.manager.model
                        visible: searchSetting.active

                        delegate: Rectangle {
                            required property var display
                            required property int index
                            required property var toolTip
                            required property var whatsThis

                            color: "transparent"
                            height: 52
                            width: ListView.view.width

                            ColumnLayout {
                                anchors.fill: parent
                                anchors.margins: 4

                                Text {
                                    Layout.fillWidth: true
                                    Layout.preferredHeight: implicitHeight
                                    color: Theme.white
                                    text: searchSetting.input.text ? display.replace(searchSetting.input.text, `<b>${searchSetting.input.text}</b>`) : display
                                    textFormat: Text.RichText
                                }
                                Text {
                                    Layout.fillWidth: true
                                    Layout.preferredHeight: implicitHeight
                                    color: Theme.textDimColor
                                    font.pixelSize: 11
                                    text: searchSetting.input.text ? whatsThis.replace(searchSetting.input.text, `<b>${searchSetting.input.text}</b>`) : whatsThis
                                    textFormat: Text.RichText
                                }
                            }
                            TapHandler {
                                onTapped: {
                                    for (let setting of toolTip) {
                                        setting.activated();
                                    }
                                    root.pageOpen = true;
                                    parent.forceActiveFocus();
                                }
                            }
                        }
                    }
                }
            }
            ColumnLayout {
                Layout.fillHeight: true
                Layout.fillWidth: true
                visible: root.showPage

                Rectangle {
                    id: tabBar

                    readonly property int selectedIndex: root.activeCategory?.selectedIndex ?? 0
                    readonly property var tabs: root.activeCategory?.tabs ?? []

                    Layout.fillWidth: true
                    Layout.preferredHeight: 48
                    color: Theme.surfaceColor
                    radius: 12
                    visible: tabs?.length > 0

                    RowLayout {
                        anchors.fill: parent

                        Repeater {
                            model: tabBar.tabs

                            Skin.Button {
                                required property int index
                                required property string modelData

                                Layout.alignment: Qt.AlignHCenter
                                Layout.preferredHeight: 38
                                Layout.preferredWidth: parent.width / (tabBar.tabs.length + (root.compact ? 0.5 : 2))
                                activeColor: Theme.white
                                checked: tabBar.selectedIndex == index
                                text: modelData

                                onPressed: {
                                    if (root.activeCategory?.selectedIndex || root.activeCategory?.selectedIndex === 0) {
                                        root.activeCategory.selectedIndex = index;
                                    }
                                }
                            }
                        }
                    }
                }
                Mixxx.SettingParameterManager {
                    id: managerItem

                    Layout.fillHeight: true
                    Layout.fillWidth: true
                    Layout.leftMargin: root.compact ? 0 : 8

                    Component.onCompleted: {
                        let activateBuilder = index => function () {
                                categoryList.currentIndex = index;
                            };
                        let visibleBuilder = index => function () {
                                return categoryList.currentIndex == index;
                            };
                        for (let index = 0; index < data.length; index++) {
                            let child = data[index];
                            if (!child.label)
                                continue;
                            sectionProperties.append({
                                label: child.label
                            });
                            child.visible = Qt.binding(visibleBuilder(index));
                            child.activated.connect(activateBuilder(index));
                            child.anchors.fill = this;
                        }
                        // This is needed to ensure the right category is displayed.
                        // It would seems there is a bug, where the component's layout appears out of date.
                        // Setting the value to its current one seems to be triggering a component update which help fixing the layout
                        root.activeCategoryIndex = root.activeCategoryIndex;
                    }

                    Settings.SoundHardware {
                    }
                    Settings.Library {
                    }
                    Settings.Controller {
                    }
                    Settings.Interface {
                    }
                    Settings.Waveform {
                    }
                    Settings.MixerEffect {
                    }
                    Settings.AutoDJ {
                    }
                    Settings.Broadcast {
                    }
                    Settings.Recording {
                    }
                    Settings.Analyzer {
                    }
                    Settings.StatsPerformance {
                    }
                }
            }
        }
    }

    onActiveCategoryIndexChanged: updateActiveCategory()
    onSectionsChanged: updateActiveCategory()

    ListModel {
        id: sectionProperties

    }
}
