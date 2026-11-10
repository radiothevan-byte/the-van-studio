// THE VAN STUDIO [AI-generated, start]
// Written by an AI assistant (Claude) for THE VAN STUDIO.
//
// Diagnostic helper for testing without a computer. On every start it saves
// the app's recent system log (logcat), which includes the log of the
// previous run, to Download/THE VAN STUDIO/ on the device. If the app crashed
// last time, the reason is in that file. Java crashes are also written
// immediately by an uncaught-exception handler.
// No permission is needed: the file is created through MediaStore.
// [AI-generated, end]
package org.mixxx;

import android.content.ContentResolver;
import android.content.ContentValues;
import android.net.Uri;
import android.os.Environment;
import android.provider.MediaStore;
import android.util.Log;
import java.io.BufferedReader;
import java.io.InputStreamReader;
import java.io.OutputStream;
import java.nio.charset.StandardCharsets;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.Locale;
import org.qtproject.qt.android.bindings.QtApplication;

public class StudioApplication extends QtApplication {
    private static final String TAG = "VanStudioLog";
    private static final String FOLDER =
            Environment.DIRECTORY_DOWNLOADS + "/THE VAN STUDIO";

    @Override
    public void onCreate() {
        super.onCreate();
        final Thread.UncaughtExceptionHandler previous =
                Thread.getDefaultUncaughtExceptionHandler();
        Thread.setDefaultUncaughtExceptionHandler((thread, error) -> {
            try {
                Log.e(TAG, "Uncaught exception in " + thread.getName(), error);
                saveLog("crash", Log.getStackTraceString(error));
            } catch (Throwable ignored) {
                // never make a crash worse
            }
            if (previous != null) {
                previous.uncaughtException(thread, error);
            }
        });
        // Save the log of the previous run in the background.
        new Thread(() -> saveLog("start", null), "VanStudioLog").start();
    }

    private void saveLog(String kind, String header) {
        StringBuilder text = new StringBuilder();
        text.append("THE VAN STUDIO diagnostic log (").append(kind).append(")\n");
        text.append("Device: ").append(android.os.Build.MANUFACTURER).append(' ')
                .append(android.os.Build.MODEL).append(", Android ")
                .append(android.os.Build.VERSION.RELEASE).append(" (API ")
                .append(android.os.Build.VERSION.SDK_INT).append(")\n\n");
        if (header != null) {
            text.append(header).append("\n\n");
        }
        try {
            Process process = Runtime.getRuntime().exec(
                    new String[] {"logcat", "-d", "-v", "threadtime", "-t", "4000"});
            try (BufferedReader reader = new BufferedReader(
                         new InputStreamReader(process.getInputStream(),
                                 StandardCharsets.UTF_8))) {
                String line;
                while ((line = reader.readLine()) != null) {
                    text.append(line).append('\n');
                }
            }
        } catch (Exception e) {
            text.append("Could not read logcat: ").append(e).append('\n');
        }
        String stamp = new SimpleDateFormat("yyyyMMdd-HHmmss", Locale.US).format(new Date());
        ContentValues values = new ContentValues();
        values.put(MediaStore.MediaColumns.DISPLAY_NAME,
                "van-studio-" + kind + "-" + stamp + ".txt");
        values.put(MediaStore.MediaColumns.MIME_TYPE, "text/plain");
        values.put(MediaStore.MediaColumns.RELATIVE_PATH, FOLDER);
        ContentResolver resolver = getContentResolver();
        try {
            Uri uri = resolver.insert(MediaStore.Downloads.EXTERNAL_CONTENT_URI, values);
            if (uri == null) {
                return;
            }
            try (OutputStream out = resolver.openOutputStream(uri)) {
                if (out != null) {
                    out.write(text.toString().getBytes(StandardCharsets.UTF_8));
                }
            }
        } catch (Exception e) {
            Log.w(TAG, "Could not save diagnostic log: " + e);
        }
    }
}
