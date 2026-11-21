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
        // THE VAN STUDIO [AI-generated]: load the Android 13 compatibility shim
        // before Qt loads its libraries. It is linked with DF_1_GLOBAL, so the
        // symbols it provides (e.g. copy_file_range, API 34+) are found by
        // libQt6Core and the other prebuilt libraries on Android 13.
        try {
            System.loadLibrary("vanstudio_compat");
        } catch (Throwable t) {
            Log.e(TAG, "Could not load the compatibility library", t);
        }
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
        // Save the log of the previous run in the background. Mixxx's own
        // log file is read now, before Qt starts and rotates it.
        final String previousMixxxLog = readPreviousMixxxLog();
        new Thread(() -> saveLog("start", previousMixxxLog), "VanStudioLog").start();
    }

    // Summary of Mixxx's log file from the previous run (files/mixxx.log).
    // The full log is mostly debug timing messages, so keep the Info,
    // Warning and Critical lines (without the most repetitive ones, which
    // are counted instead) and the last raw lines.
    private String readPreviousMixxxLog() {
        java.io.File file = new java.io.File(getFilesDir(), "mixxx.log");
        if (!file.isFile()) {
            return null;
        }
        final int maxImportant = 4000;
        final int maxTail = 200;
        final String[] noisy = {
            "underflowHappened", "outdated position request", "Failed to start frame",
            "Failed to make context current", "Detected anchors on an item"};
        java.util.ArrayDeque<String> important = new java.util.ArrayDeque<>();
        java.util.ArrayDeque<String> tail = new java.util.ArrayDeque<>();
        java.util.TreeMap<String, Integer> noisyCounts = new java.util.TreeMap<>();
        long lines = 0;
        try (java.io.BufferedReader in = new java.io.BufferedReader(new java.io.InputStreamReader(
                 new java.io.FileInputStream(file), StandardCharsets.UTF_8))) {
            String line;
            while ((line = in.readLine()) != null) {
                lines++;
                tail.addLast(line);
                if (tail.size() > maxTail) {
                    tail.removeFirst();
                }
                boolean isImportant = line.contains(" Info [") || line.contains(" Warning [")
                    || line.contains(" Critical [") || line.contains(" Fatal [")
                    // Debug lines about recording and sound devices too.
                    || line.contains("Recording") || line.contains("record")
                    || line.contains("SoundManager") || line.contains("SoundDevice")
                    || line.contains("Microphone") || line.contains("EngineSideChain");
                if (!isImportant) {
                    continue;
                }
                String noisyKey = null;
                for (String pattern : noisy) {
                    if (line.contains(pattern)) {
                        noisyKey = pattern;
                        break;
                    }
                }
                if (noisyKey != null) {
                    if (noisyKey.equals("underflowHappened")) {
                        int index = line.indexOf("code:");
                        noisyKey = index >= 0 ? "underflowHappened " + line.substring(index).trim()
                                              : noisyKey;
                    }
                    noisyCounts.merge(noisyKey, 1, Integer::sum);
                    continue;
                }
                important.addLast(line);
                if (important.size() > maxImportant) {
                    important.removeFirst();
                }
            }
        } catch (Exception e) {
            return "Could not read the previous Mixxx log: " + e;
        }
        StringBuilder text = new StringBuilder();
        text.append("===== Mixxx log of the previous run: ").append(lines).append(" lines, ").append(file.length() / 1024).append(" KB =====\n");
        text.append("--- Repeated messages (count) ---\n");
        for (java.util.Map.Entry<String, Integer> entry : noisyCounts.entrySet()) {
            text.append(entry.getValue()).append("  ").append(entry.getKey()).append('\n');
        }
        text.append("--- Info, warnings and errors (last ").append(maxImportant).append(") ---\n");
        for (String line : important) {
            text.append(line).append('\n');
        }
        text.append("--- Last ").append(maxTail).append(" lines ---\n");
        for (String line : tail) {
            text.append(line).append('\n');
        }
        text.append("===== end of Mixxx log =====");
        return text.toString();
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
                    new String[] {"logcat", "-d", "-v", "threadtime", "-t", "20000"});
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
