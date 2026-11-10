// THE VAN STUDIO [AI-generated, start]
// See androidstudioservice.h.
// [AI-generated, end]
#include "util/androidstudioservice.h"

#include <QCoreApplication>
#include <QJniObject>
#include <QtCore/qcoreapplication_platform.h>

#include "broadcast/defs_broadcast.h"
#include "control/controlproxy.h"
#include "moc_androidstudioservice.cpp"
#include "recording/defs_recording.h"

namespace mixxx {

namespace {
// Values of [Shoutcast],status (see BroadcastManager::StatusCOStates)
constexpr int kBroadcastConnecting = 1;
constexpr int kBroadcastConnected = 2;
constexpr int kBroadcastFailure = 3;
constexpr int kBroadcastWarning = 4;
} // namespace

AndroidStudioService::AndroidStudioService(QObject* parent)
        : QObject(parent),
          m_pBroadcastEnabled(make_parented<ControlProxy>(
                  QStringLiteral(BROADCAST_PREF_KEY),
                  QStringLiteral("enabled"),
                  this,
                  ControlFlag::NoAssertIfMissing)),
          m_pBroadcastStatus(make_parented<ControlProxy>(
                  QStringLiteral(BROADCAST_PREF_KEY),
                  QStringLiteral("status"),
                  this,
                  ControlFlag::NoAssertIfMissing)),
          m_pRecordingStatus(make_parented<ControlProxy>(
                  QStringLiteral(RECORDING_PREF_KEY),
                  QStringLiteral("status"),
                  this,
                  ControlFlag::NoAssertIfMissing)) {
    m_pBroadcastEnabled->connectValueChanged(this, &AndroidStudioService::slotUpdate);
    m_pBroadcastStatus->connectValueChanged(this, &AndroidStudioService::slotUpdate);
    m_pRecordingStatus->connectValueChanged(this, &AndroidStudioService::slotUpdate);
    slotUpdate();
}

AndroidStudioService::~AndroidStudioService() = default;

QString AndroidStudioService::statusText() const {
    QString text;
    if (m_pBroadcastEnabled->toBool()) {
        switch (static_cast<int>(m_pBroadcastStatus->get())) {
        case kBroadcastConnected:
            text = QStringLiteral("ON AIR");
            break;
        case kBroadcastConnecting:
            text = QStringLiteral("Connecting to server…");
            break;
        case kBroadcastWarning:
            text = QStringLiteral("ON AIR (some connections failed)");
            break;
        case kBroadcastFailure:
            text = QStringLiteral("Broadcast error, check the connection");
            break;
        default:
            text = QStringLiteral("Broadcast enabled");
            break;
        }
    }
    const double rec = m_pRecordingStatus->get();
    if (rec == RECORD_ON || rec == RECORD_SPLIT_CONTINUE) {
        if (!text.isEmpty()) {
            text += QStringLiteral(" · ");
        }
        text += QStringLiteral("Recording");
    }
    if (text.isEmpty()) {
        text = QStringLiteral("Studio ready");
    }
    return text;
}

void AndroidStudioService::slotUpdate() {
    const QString status = statusText();
    if (status == m_lastStatus) {
        return;
    }
    m_lastStatus = status;
    QJniObject context = QNativeInterface::QAndroidApplication::context();
    if (!context.isValid()) {
        return;
    }
    QJniObject::callStaticMethod<void>("org/mixxx/StudioService",
            "updateStatus",
            "(Landroid/content/Context;Ljava/lang/String;)V",
            context.object(),
            QJniObject::fromString(status).object<jstring>());
}

} // namespace mixxx
