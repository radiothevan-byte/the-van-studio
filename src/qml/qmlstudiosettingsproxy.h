#pragma once

// THE VAN STUDIO [AI-generated, start]
// QML singleton "Mixxx.StudioSettings" that exposes the Live Broadcasting and
// Recording preferences to the QML (Android/tablet) interface. The desktop
// widget dialogs (DlgPrefBroadcast, DlgPrefRecord) are not available there.
//
// The broadcast part edits the first broadcast profile ("Connection 1"),
// which is enough for a single radio station. Changes are written to the
// profile file and are used on the next (re)connection.
// [AI-generated, end]

#include <QJSEngine>
#include <QObject>
#include <QQmlEngine>
#include <QString>
#include <QVariantList>
#include <QVariantMap>

#include "preferences/usersettings.h"
#ifdef __BROADCAST__
#include "preferences/broadcastsettings.h"
#endif

namespace mixxx {
namespace qml {

class QmlStudioSettingsProxy : public QObject {
    Q_OBJECT
    QML_NAMED_ELEMENT(StudioSettings)
    QML_SINGLETON
    Q_PROPERTY(bool broadcastAvailable READ broadcastAvailable CONSTANT)

  public:
    explicit QmlStudioSettingsProxy(QObject* parent = nullptr);

    static QmlStudioSettingsProxy* create(QQmlEngine* pQmlEngine, QJSEngine* pJsEngine);

    /// Called once by QmlApplication before the QML engine is created.
    /// Also fills in sensible defaults (e.g. the recording folder).
    static void initialize(UserSettingsPointer pConfig
#ifdef __BROADCAST__
            ,
            BroadcastSettingsPointer pBroadcastSettings
#endif
    );
    static void shutdown();

    bool broadcastAvailable() const;

    // ---- Recording ----
    /// Keys: directory, encoding, formats [{label, value}], splitOptions
    /// [{label, value}], fileSize, freeSpaceText
    Q_INVOKABLE QVariantMap recordingSettings() const;
    /// Quality choices for an encoding: {available, values: [labels], index}
    Q_INVOKABLE QVariantMap recordingQuality(const QString& encoding) const;
    /// Returns an empty string on success, otherwise an error message.
    Q_INVOKABLE QString saveRecordingSettings(const QVariantMap& settings);
    Q_INVOKABLE QString defaultRecordingDirectory() const;

    // ---- Analyzer ----
    /// Keys: bpmEnabled, bpmFixedTempo, bpmFast, keyEnabled, keyFast,
    /// replayGainEnabled
    Q_INVOKABLE QVariantMap analyzerSettings() const;
    /// Same keys as analyzerSettings(). Returns an empty string on success.
    Q_INVOKABLE QString saveAnalyzerSettings(const QVariantMap& settings);

    // ---- Android screen and storage ----
    /// Screen area to keep free (camera cutout), in device independent
    /// pixels: {left, top, right, bottom}. All zero on other platforms.
    Q_INVOKABLE QVariantMap safeAreaInsets() const;
    /// True if the music library can read any folder. Always true on
    /// platforms without Android's "All files access" permission.
    Q_INVOKABLE bool hasAllFilesAccess() const;
    /// Opens the Android settings screen for "All files access".
    Q_INVOKABLE void openAllFilesAccessSettings() const;

    // ---- Live broadcasting ----
    /// All fields of the first broadcast profile (see the .cpp for keys).
    Q_INVOKABLE QVariantMap broadcastSettings() const;
    /// Returns an empty string on success, otherwise an error message.
    Q_INVOKABLE QString saveBroadcastSettings(const QVariantMap& settings);

  private:
    static inline UserSettingsPointer s_pConfig;
#ifdef __BROADCAST__
    static inline BroadcastSettingsPointer s_pBroadcastSettings;
#endif
};

} // namespace qml
} // namespace mixxx
