#pragma once

// THE VAN STUDIO [AI-generated, start]
// Keeps the text of the Android "live" notification (shown by the
// org.mixxx.StudioService foreground service) in sync with the broadcast and
// recording state. The service itself is started by MainActivity.
// [AI-generated, end]

#include <QObject>
#include <QString>

#include "util/parented_ptr.h"

class ControlProxy;

namespace mixxx {

class AndroidStudioService : public QObject {
    Q_OBJECT
  public:
    explicit AndroidStudioService(QObject* parent = nullptr);
    ~AndroidStudioService() override;

  private slots:
    void slotUpdate();

  private:
    QString statusText() const;

    parented_ptr<ControlProxy> m_pBroadcastEnabled;
    parented_ptr<ControlProxy> m_pBroadcastStatus;
    parented_ptr<ControlProxy> m_pRecordingStatus;
    QString m_lastStatus;
};

} // namespace mixxx
