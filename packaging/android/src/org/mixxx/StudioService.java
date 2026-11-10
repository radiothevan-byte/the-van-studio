// THE VAN STUDIO [AI-generated, start]
// This file was written by an AI assistant (Claude) for THE VAN STUDIO.
//
// Foreground service that keeps the studio alive while the app is in the
// background or the screen is off. Without it, Android 9+ silences the
// microphone of background apps, and Android may freeze or kill the process.
//
// - Type "microphone" keeps microphone capture running (needs RECORD_AUDIO).
// - Type "mediaPlayback" keeps audio output and streaming running.
// - A partial wake lock keeps the CPU awake while the screen is off.
// - A Wi-Fi lock keeps the Wi-Fi radio in low-latency mode for streaming.
//
// The service must be started while the activity is visible. Android 14+
// rejects starting a microphone foreground service from the background.
// [AI-generated, end]
package org.mixxx;

import android.Manifest;
import android.app.Notification;
import android.app.NotificationChannel;
import android.app.NotificationManager;
import android.app.PendingIntent;
import android.app.Service;
import android.content.Context;
import android.content.Intent;
import android.content.pm.PackageManager;
import android.content.pm.ServiceInfo;
import android.net.wifi.WifiManager;
import android.os.IBinder;
import android.os.PowerManager;
import android.util.Log;

public class StudioService extends Service {
    private static final String TAG = "VanStudioService";
    private static final String CHANNEL_ID = "van_studio_live";
    private static final int NOTIFICATION_ID = 4711;
    private static final String EXTRA_STATUS = "status";

    private static volatile String sStatusText = "Ready";
    private static volatile boolean sRunning = false;

    private PowerManager.WakeLock mWakeLock;
    private WifiManager.WifiLock mWifiLock;

    /// Starts the service, or refreshes its type if it is already running
    /// (e.g. after the microphone permission was granted). Call only while
    /// the activity is in the foreground.
    public static void start(Context context) {
        Intent intent = new Intent(context, StudioService.class);
        try {
            context.startForegroundService(intent);
        } catch (Exception e) {
            // ForegroundServiceStartNotAllowedException and friends
            Log.w(TAG, "Unable to start foreground service: " + e);
        }
    }

    /// Updates the text of the ongoing notification. Safe to call from any
    /// thread and at any time (it does nothing if the service is not running).
    public static void updateStatus(Context context, String status) {
        sStatusText = status;
        if (!sRunning) {
            return;
        }
        NotificationManager nm = context.getSystemService(NotificationManager.class);
        if (nm != null) {
            nm.notify(NOTIFICATION_ID, buildNotification(context));
        }
    }

    public static void stop(Context context) {
        context.stopService(new Intent(context, StudioService.class));
    }

    @Override
    public void onCreate() {
        super.onCreate();
        createChannel(this);
    }

    @Override
    public int onStartCommand(Intent intent, int flags, int startId) {
        int types = ServiceInfo.FOREGROUND_SERVICE_TYPE_MEDIA_PLAYBACK;
        if (checkSelfPermission(Manifest.permission.RECORD_AUDIO)
                == PackageManager.PERMISSION_GRANTED) {
            types |= ServiceInfo.FOREGROUND_SERVICE_TYPE_MICROPHONE;
        }
        try {
            startForeground(NOTIFICATION_ID, buildNotification(this), types);
            sRunning = true;
        } catch (Exception e) {
            Log.e(TAG, "startForeground failed: " + e);
            stopSelf();
            return START_NOT_STICKY;
        }
        acquireLocks();
        Log.i(TAG, "Foreground service running, types=" + types);
        // Do not let Android restart the service on its own: it would run
        // without the audio engine.
        return START_NOT_STICKY;
    }

    @Override
    public void onTaskRemoved(Intent rootIntent) {
        // The user swiped the app away: end the session cleanly.
        stopSelf();
        super.onTaskRemoved(rootIntent);
    }

    @Override
    public void onDestroy() {
        sRunning = false;
        releaseLocks();
        super.onDestroy();
    }

    @Override
    public IBinder onBind(Intent intent) {
        return null;
    }

    private void acquireLocks() {
        if (mWakeLock == null) {
            PowerManager pm = getSystemService(PowerManager.class);
            if (pm != null) {
                mWakeLock = pm.newWakeLock(
                        PowerManager.PARTIAL_WAKE_LOCK, "VanStudio:live");
                mWakeLock.setReferenceCounted(false);
            }
        }
        if (mWakeLock != null && !mWakeLock.isHeld()) {
            mWakeLock.acquire();
        }
        if (mWifiLock == null) {
            WifiManager wm = getApplicationContext().getSystemService(WifiManager.class);
            if (wm != null) {
                mWifiLock = wm.createWifiLock(
                        WifiManager.WIFI_MODE_FULL_LOW_LATENCY, "VanStudio:stream");
                mWifiLock.setReferenceCounted(false);
            }
        }
        if (mWifiLock != null && !mWifiLock.isHeld()) {
            try {
                mWifiLock.acquire();
            } catch (Exception e) {
                Log.w(TAG, "Wi-Fi lock not acquired: " + e);
            }
        }
    }

    private void releaseLocks() {
        if (mWakeLock != null && mWakeLock.isHeld()) {
            mWakeLock.release();
        }
        if (mWifiLock != null && mWifiLock.isHeld()) {
            mWifiLock.release();
        }
    }

    private static void createChannel(Context context) {
        NotificationManager nm = context.getSystemService(NotificationManager.class);
        if (nm == null || nm.getNotificationChannel(CHANNEL_ID) != null) {
            return;
        }
        NotificationChannel channel = new NotificationChannel(
                CHANNEL_ID, "Live studio", NotificationManager.IMPORTANCE_LOW);
        channel.setDescription("Shown while THE VAN STUDIO is running");
        channel.setShowBadge(false);
        nm.createNotificationChannel(channel);
    }

    private static Notification buildNotification(Context context) {
        createChannel(context);
        Intent open = new Intent(context, MainActivity.class);
        open.setFlags(Intent.FLAG_ACTIVITY_SINGLE_TOP | Intent.FLAG_ACTIVITY_REORDER_TO_FRONT);
        PendingIntent pending = PendingIntent.getActivity(context, 0, open,
                PendingIntent.FLAG_IMMUTABLE | PendingIntent.FLAG_UPDATE_CURRENT);
        // A plain system drawable: adaptive launcher icons are not reliable as
        // notification small icons.
        int icon = android.R.drawable.ic_btn_speak_now;
        return new Notification.Builder(context, CHANNEL_ID)
                .setContentTitle("THE VAN STUDIO")
                .setContentText(sStatusText)
                .setSmallIcon(icon)
                .setContentIntent(pending)
                .setOngoing(true)
                .setOnlyAlertOnce(true)
                .setCategory(Notification.CATEGORY_SERVICE)
                .setForegroundServiceBehavior(Notification.FOREGROUND_SERVICE_IMMEDIATE)
                .build();
    }
}
