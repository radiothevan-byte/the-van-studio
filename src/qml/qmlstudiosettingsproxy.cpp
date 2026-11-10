// THE VAN STUDIO [AI-generated, start]
// See qmlstudiosettingsproxy.h. Written by an AI assistant (Claude).
// [AI-generated, end]
#include "qml/qmlstudiosettingsproxy.h"

#include <QDir>
#include <QStandardPaths>
#include <QStorageInfo>

#include "encoder/encoder.h"
#include "encoder/encoderrecordingsettings.h"
#include "moc_qmlstudiosettingsproxy.cpp"
#include "recording/defs_recording.h"
#ifdef __BROADCAST__
#include "broadcast/defs_broadcast.h"
#include "preferences/broadcastprofile.h"
#endif

namespace mixxx {
namespace qml {

namespace {

const ConfigKey kDirectoryKey(QStringLiteral(RECORDING_PREF_KEY), QStringLiteral("Directory"));
const ConfigKey kEncodingKey(QStringLiteral(RECORDING_PREF_KEY), QStringLiteral("Encoding"));
const ConfigKey kFileSizeKey(QStringLiteral(RECORDING_PREF_KEY), QStringLiteral("FileSize"));

bool isFormatUsable(const QString& internalName) {
#if defined(Q_OS_ANDROID)
    // AAC needs libfdk-aac at runtime, which is not shipped on Android.
    return internalName != QStringLiteral(ENCODING_AAC) &&
            internalName != QStringLiteral(ENCODING_HEAAC) &&
            internalName != QStringLiteral(ENCODING_HEAACV2);
#else
    Q_UNUSED(internalName);
    return true;
#endif
}

QVariantMap option(const QString& label, const QVariant& value) {
    return QVariantMap{{QStringLiteral("label"), label}, {QStringLiteral("value"), value}};
}

QString defaultDirectory() {
#if defined(Q_OS_ANDROID)
    return QStringLiteral("/storage/emulated/0/Music/THE VAN STUDIO");
#else
    const QString musicDir = QStandardPaths::writableLocation(QStandardPaths::MusicLocation);
    return QDir(musicDir + QStringLiteral("/Mixxx/Recordings")).absolutePath();
#endif
}

QString formatBytes(qint64 bytes) {
    if (bytes < 0) {
        return QStringLiteral("unknown");
    }
    const double gb = static_cast<double>(bytes) / (1024.0 * 1024.0 * 1024.0);
    return QStringLiteral("%1 GB").arg(gb, 0, 'f', 1);
}

} // namespace

QmlStudioSettingsProxy::QmlStudioSettingsProxy(QObject* parent)
        : QObject(parent) {
}

QmlStudioSettingsProxy* QmlStudioSettingsProxy::create(
        QQmlEngine* pQmlEngine,
        [[maybe_unused]] QJSEngine* pJsEngine) {
    return new QmlStudioSettingsProxy(pQmlEngine);
}

void QmlStudioSettingsProxy::initialize(UserSettingsPointer pConfig
#ifdef __BROADCAST__
        ,
        BroadcastSettingsPointer pBroadcastSettings
#endif
) {
    s_pConfig = pConfig;
#ifdef __BROADCAST__
    s_pBroadcastSettings = pBroadcastSettings;
#endif
    if (!s_pConfig) {
        return;
    }
    // Without a directory the recording cannot start. The desktop sets it in
    // DlgPrefRecord, which does not exist in the QML interface.
    if (s_pConfig->getValueString(kDirectoryKey).isEmpty()) {
        s_pConfig->setValue(kDirectoryKey, defaultDirectory());
    }
    if (s_pConfig->getValueString(kEncodingKey).isEmpty()) {
        s_pConfig->setValue(kEncodingKey, QStringLiteral(ENCODING_MP3));
    }
    if (s_pConfig->getValueString(kFileSizeKey).isEmpty()) {
        // Splitting keeps files small, so a crash or a killed app loses at
        // most the current part of a long show.
        s_pConfig->setValue(kFileSizeKey, QStringLiteral(SPLIT_60MIN));
    }
}

void QmlStudioSettingsProxy::shutdown() {
    s_pConfig.reset();
#ifdef __BROADCAST__
    s_pBroadcastSettings.reset();
#endif
}

bool QmlStudioSettingsProxy::broadcastAvailable() const {
#ifdef __BROADCAST__
    return !s_pBroadcastSettings.isNull();
#else
    return false;
#endif
}

QString QmlStudioSettingsProxy::defaultRecordingDirectory() const {
    return defaultDirectory();
}

QVariantMap QmlStudioSettingsProxy::recordingSettings() const {
    QVariantMap result;
    if (!s_pConfig) {
        return result;
    }
    const QString directory = s_pConfig->getValueString(kDirectoryKey);
    result.insert(QStringLiteral("directory"), directory);
    result.insert(QStringLiteral("encoding"),
            EncoderFactory::getFactory().getSelectedFormat(s_pConfig).internalName);
    result.insert(QStringLiteral("fileSize"), s_pConfig->getValueString(kFileSizeKey));

    QVariantList formats;
    const QList<Encoder::Format> allFormats = EncoderFactory::getFactory().getFormats();
    for (const auto& format : allFormats) {
        if (isFormatUsable(format.internalName)) {
            formats.append(option(format.label, format.internalName));
        }
    }
    result.insert(QStringLiteral("formats"), formats);

    QVariantList splitOptions;
    splitOptions.append(option(QStringLiteral("60 minutes"), QStringLiteral(SPLIT_60MIN)));
    splitOptions.append(option(QStringLiteral("120 minutes"), QStringLiteral(SPLIT_120MIN)));
    splitOptions.append(option(QStringLiteral("1 GB"), QStringLiteral(SPLIT_1024MB)));
    splitOptions.append(option(QStringLiteral("2 GB"), QStringLiteral(SPLIT_2048MB)));
    splitOptions.append(option(QStringLiteral("4 GB"), QStringLiteral(SPLIT_4096MB)));
    splitOptions.append(option(QStringLiteral("No splitting"), QStringLiteral(SPLIT_NONE)));
    result.insert(QStringLiteral("splitOptions"), splitOptions);

    QStorageInfo storage(QDir(directory).exists() ? directory : QDir::rootPath());
    result.insert(QStringLiteral("freeSpaceText"),
            storage.isValid() ? formatBytes(storage.bytesAvailable()) : QStringLiteral("unknown"));
    return result;
}

QVariantMap QmlStudioSettingsProxy::recordingQuality(const QString& encoding) const {
    QVariantMap result{{QStringLiteral("available"), false}};
    if (!s_pConfig) {
        return result;
    }
    const Encoder::Format format = EncoderFactory::getFactory().getFormatFor(encoding);
    if (format.internalName.isEmpty()) {
        return result;
    }
    const auto pSettings =
            EncoderFactory::getFactory().getEncoderRecordingSettings(format, s_pConfig);
    if (!pSettings || !pSettings->usesQualitySlider()) {
        return result;
    }
    QVariantList labels;
    const QList<int> qualityValues = pSettings->getQualityValues();
    for (int value : qualityValues) {
        labels.append(QStringLiteral("%1 kbps").arg(value));
    }
    result.insert(QStringLiteral("available"), !labels.isEmpty());
    result.insert(QStringLiteral("values"), labels);
    result.insert(QStringLiteral("index"), pSettings->getQualityIndex());
    return result;
}

QString QmlStudioSettingsProxy::saveRecordingSettings(const QVariantMap& settings) {
    if (!s_pConfig) {
        return QStringLiteral("Settings are not available");
    }
    const QString directory = settings.value(QStringLiteral("directory")).toString().trimmed();
    if (directory.isEmpty()) {
        return QStringLiteral("Please choose a recording folder");
    }
    QDir dir(directory);
    if (!dir.exists() && !dir.mkpath(dir.absolutePath())) {
        return QStringLiteral("The folder cannot be created: %1").arg(directory);
    }
    const QString encoding = settings.value(QStringLiteral("encoding")).toString();
    const Encoder::Format format = EncoderFactory::getFactory().getFormatFor(encoding);
    if (format.internalName.isEmpty() || !isFormatUsable(format.internalName)) {
        return QStringLiteral("Unsupported recording format: %1").arg(encoding);
    }

    s_pConfig->setValue(kDirectoryKey, dir.absolutePath());
    s_pConfig->setValue(kEncodingKey, format.internalName);
    const QString fileSize = settings.value(QStringLiteral("fileSize")).toString();
    if (!fileSize.isEmpty()) {
        s_pConfig->setValue(kFileSizeKey, fileSize);
    }
    if (settings.contains(QStringLiteral("qualityIndex"))) {
        const auto pSettings =
                EncoderFactory::getFactory().getEncoderRecordingSettings(format, s_pConfig);
        const int qualityIndex = settings.value(QStringLiteral("qualityIndex")).toInt();
        if (pSettings && pSettings->usesQualitySlider() && qualityIndex >= 0 &&
                qualityIndex < pSettings->getQualityValues().size()) {
            pSettings->setQualityByIndex(qualityIndex);
        }
    }
    s_pConfig->save();
    return QString();
}

QVariantMap QmlStudioSettingsProxy::broadcastSettings() const {
    QVariantMap result;
#ifdef __BROADCAST__
    if (!s_pBroadcastSettings) {
        return result;
    }
    BroadcastProfilePtr pProfile = s_pBroadcastSettings->profileAt(0);
    if (!pProfile) {
        return result;
    }
    result.insert(QStringLiteral("profileName"), pProfile->getProfileName());
    result.insert(QStringLiteral("serverType"), pProfile->getServertype());
    result.insert(QStringLiteral("host"), pProfile->getHost());
    result.insert(QStringLiteral("port"), pProfile->getPort());
    result.insert(QStringLiteral("mountpoint"), pProfile->getMountpoint());
    result.insert(QStringLiteral("login"), pProfile->getLogin());
    result.insert(QStringLiteral("password"), pProfile->getPassword());
    result.insert(QStringLiteral("format"), pProfile->getFormat());
    result.insert(QStringLiteral("bitrate"), pProfile->getBitrate());
    result.insert(QStringLiteral("channels"), pProfile->getChannels());
    result.insert(QStringLiteral("streamName"), pProfile->getStreamName());
    result.insert(QStringLiteral("streamDesc"), pProfile->getStreamDesc());
    result.insert(QStringLiteral("streamGenre"), pProfile->getStreamGenre());
    result.insert(QStringLiteral("streamWebsite"), pProfile->getStreamWebsite());
    result.insert(QStringLiteral("streamPublic"), pProfile->getStreamPublic());
    result.insert(QStringLiteral("enableMetadata"), pProfile->getEnableMetadata());
    result.insert(QStringLiteral("metadataFormat"), pProfile->getMetadataFormat());
    result.insert(QStringLiteral("enableReconnect"), pProfile->getEnableReconnect());
    result.insert(QStringLiteral("noDelayFirstReconnect"), pProfile->getNoDelayFirstReconnect());
    result.insert(QStringLiteral("reconnectFirstDelay"), pProfile->getReconnectFirstDelay());
    result.insert(QStringLiteral("reconnectPeriod"), pProfile->getReconnectPeriod());
    result.insert(QStringLiteral("limitReconnects"), pProfile->getLimitReconnects());
    result.insert(QStringLiteral("maximumRetries"), pProfile->getMaximumRetries());

    QVariantList serverTypes;
    serverTypes.append(option(QStringLiteral("Icecast 2"), QStringLiteral(BROADCAST_SERVER_ICECAST2)));
    serverTypes.append(option(QStringLiteral("Shoutcast 1/2"), QStringLiteral(BROADCAST_SERVER_SHOUTCAST)));
    serverTypes.append(option(QStringLiteral("Icecast 1"), QStringLiteral(BROADCAST_SERVER_ICECAST1)));
    result.insert(QStringLiteral("serverTypes"), serverTypes);

    QVariantList formats;
    formats.append(option(QStringLiteral("MP3"), QStringLiteral(ENCODING_MP3)));
    formats.append(option(QStringLiteral("Ogg Vorbis"), QStringLiteral(ENCODING_OGG)));
    formats.append(option(QStringLiteral("Opus"), QStringLiteral(ENCODING_OPUS)));
    result.insert(QStringLiteral("formats"), formats);

    QVariantList bitrates;
    for (int kbps : {320, 256, 224, 192, 160, 128, 112, 96, 80, 64, 48, 32}) {
        bitrates.append(kbps);
    }
    result.insert(QStringLiteral("bitrates"), bitrates);
#endif
    return result;
}

QString QmlStudioSettingsProxy::saveBroadcastSettings(const QVariantMap& settings) {
#ifdef __BROADCAST__
    if (!s_pBroadcastSettings) {
        return QStringLiteral("Live broadcasting is not available");
    }
    BroadcastProfilePtr pProfile = s_pBroadcastSettings->profileAt(0);
    if (!pProfile) {
        return QStringLiteral("No broadcast connection profile found");
    }
    auto text = [&settings](const char* key) {
        return settings.value(QString::fromLatin1(key)).toString().trimmed();
    };

    const QString host = text("host");
    if (host.isEmpty()) {
        return QStringLiteral("Please enter the server address");
    }
    bool portOk = false;
    const int port = settings.value(QStringLiteral("port")).toInt(&portOk);
    if (!portOk || port < 1 || port > 65535) {
        return QStringLiteral("The port must be a number between 1 and 65535");
    }
    const QString password = settings.value(QStringLiteral("password")).toString();
    if (!BroadcastProfile::validPassword(password)) {
        return QStringLiteral("The password is empty or contains invalid characters");
    }
    const QString serverType = text("serverType");
    QString mountpoint = text("mountpoint");
    if (serverType != QStringLiteral(BROADCAST_SERVER_SHOUTCAST)) {
        if (mountpoint.isEmpty()) {
            return QStringLiteral("Please enter the mount point (e.g. /live)");
        }
        if (!mountpoint.startsWith(QLatin1Char('/'))) {
            mountpoint.prepend(QLatin1Char('/'));
        }
    }
    const QString format = text("format");
    if (format != QStringLiteral(ENCODING_MP3) && format != QStringLiteral(ENCODING_OGG) &&
            format != QStringLiteral(ENCODING_OPUS)) {
        return QStringLiteral("Unsupported stream format: %1").arg(format);
    }

    pProfile->setEnabled(true);
    pProfile->setServertype(serverType);
    pProfile->setHost(host);
    pProfile->setPort(port);
    pProfile->setMountPoint(mountpoint);
    pProfile->setLogin(text("login"));
    pProfile->setPassword(password);
    pProfile->setFormat(format);
    pProfile->setBitrate(settings.value(QStringLiteral("bitrate")).toInt());
    pProfile->setChannels(settings.value(QStringLiteral("channels")).toInt() == 1 ? 1 : 2);
    pProfile->setStreamName(text("streamName"));
    pProfile->setStreamDesc(text("streamDesc"));
    pProfile->setStreamGenre(text("streamGenre"));
    pProfile->setStreamWebsite(text("streamWebsite"));
    pProfile->setStreamPublic(settings.value(QStringLiteral("streamPublic")).toBool());
    pProfile->setEnableMetadata(settings.value(QStringLiteral("enableMetadata")).toBool());
    const QString metadataFormat = text("metadataFormat");
    if (!metadataFormat.isEmpty()) {
        pProfile->setMetadataFormat(metadataFormat);
    }
    // Keep the title in Ogg streams up to date as well
    pProfile->setOggDynamicUpdate(true);
    pProfile->setEnableReconnect(settings.value(QStringLiteral("enableReconnect")).toBool());
    pProfile->setNoDelayFirstReconnect(
            settings.value(QStringLiteral("noDelayFirstReconnect")).toBool());
    pProfile->setReconnectFirstDelay(
            qMax(0.0, settings.value(QStringLiteral("reconnectFirstDelay")).toDouble()));
    pProfile->setReconnectPeriod(
            qMax(1.0, settings.value(QStringLiteral("reconnectPeriod")).toDouble()));
    pProfile->setLimitReconnects(settings.value(QStringLiteral("limitReconnects")).toBool());
    pProfile->setMaximumRetries(
            qMax(1, settings.value(QStringLiteral("maximumRetries")).toInt()));

    if (!s_pBroadcastSettings->saveProfile(pProfile.data())) {
        return QStringLiteral("The settings could not be written to storage");
    }
    return QString();
#else
    Q_UNUSED(settings);
    return QStringLiteral("Live broadcasting is not available in this build");
#endif
}

} // namespace qml
} // namespace mixxx
