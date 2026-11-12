package org.mixxx;

import android.Manifest;
import android.app.Activity;
import android.content.Intent;
import android.content.pm.PackageManager;
import android.net.Uri;
import android.os.Bundle;
import android.os.Environment;
import android.provider.Settings;
import android.view.View;
import android.view.WindowInsets;
import android.view.WindowManager;
import java.lang.ref.WeakReference;
import androidx.core.view.ViewCompat;
import androidx.core.view.WindowCompat;
import androidx.core.view.WindowInsetsCompat;
import androidx.core.view.WindowInsetsControllerCompat;
import java.util.ArrayList;
import org.qtproject.qt.android.QtActivityBase;

public class MainActivity extends QtActivityBase {
    // THE VAN STUDIO [AI-generated, start]
    private static final int REQUEST_STUDIO_PERMISSIONS = 4712;
    private static WeakReference<Activity> sActivity = new WeakReference<>(null);
    private boolean mAskedAllFilesAccess = false;

    /// Safe area (camera cutout, system bars) in physical pixels:
    /// {left, top, right, bottom}. Called from C++ (QML StudioSettings).
    public static int[] getSafeInsets() {
        int[] result = new int[] {0, 0, 0, 0};
        Activity activity = sActivity.get();
        if (activity == null) {
            return result;
        }
        View decorView = activity.getWindow().getDecorView();
        WindowInsets insets = decorView.getRootWindowInsets();
        if (insets == null) {
            return result;
        }
        android.graphics.Insets bars = insets.getInsets(
                WindowInsets.Type.systemBars() | WindowInsets.Type.displayCutout());
        result[0] = bars.left;
        result[1] = bars.top;
        result[2] = bars.right;
        result[3] = bars.bottom;
        return result;
    }

    /// True if the library can read any folder ("All files access").
    public static boolean hasAllFilesAccess() {
        return Environment.isExternalStorageManager();
    }

    /// Opens the Android screen where "All files access" is granted.
    public static void openAllFilesAccessSettings() {
        final Activity activity = sActivity.get();
        if (activity == null) {
            return;
        }
        activity.runOnUiThread(() -> {
            try {
                Intent intent = new Intent(
                        Settings.ACTION_MANAGE_APP_ALL_FILES_ACCESS_PERMISSION,
                        Uri.parse("package:" + activity.getPackageName()));
                activity.startActivity(intent);
            } catch (Exception e) {
                activity.startActivity(new Intent(
                        Settings.ACTION_MANAGE_ALL_FILES_ACCESS_PERMISSION));
            }
        });
    }
    // [AI-generated, end]

    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        // THE VAN STUDIO [AI-generated, start]
        // Use the whole screen, including the camera cutout area. When the
        // cutout was avoided, Android shrank the window but Qt still laid out
        // the UI for the full screen width, so the right edge was cut off.
        // The QML side keeps its content out of the cutout using
        // getSafeInsets().
        sActivity = new WeakReference<>(this);
        WindowManager.LayoutParams lp = getWindow().getAttributes();
        lp.layoutInDisplayCutoutMode =
                WindowManager.LayoutParams.LAYOUT_IN_DISPLAY_CUTOUT_MODE_ALWAYS;
        getWindow().setAttributes(lp);
        // [AI-generated, end]

        // Disable system and navigation bar to prevent accidental back or app switch
        WindowInsetsControllerCompat windowInsetsController =
            WindowCompat.getInsetsController(getWindow(), getWindow().getDecorView());
        windowInsetsController.setSystemBarsBehavior(
            WindowInsetsControllerCompat.BEHAVIOR_SHOW_TRANSIENT_BARS_BY_SWIPE);
        windowInsetsController.hide(WindowInsetsCompat.Type.systemBars());

        // THE VAN STUDIO [AI-generated, start]
        // Ask for the microphone (needed for the USB mic and for the
        // "microphone" foreground service type) and for notifications
        // (Android 13+, needed to show the ongoing "live" notification).
        requestStudioPermissions();
        // [AI-generated, end]
    }

    // THE VAN STUDIO [AI-generated, start]
    @Override
    public void onResume() {
        super.onResume();
        // (Re)start the foreground service while we are visible. If the
        // microphone permission was granted in the meantime, this upgrades the
        // service to the "microphone" type so Android keeps the mic open in the
        // background and with the screen off.
        StudioService.start(this);
    }

    @Override
    public void onDestroy() {
        if (isFinishing()) {
            StudioService.stop(this);
        }
        super.onDestroy();
    }

    @Override
    public void onRequestPermissionsResult(
            int requestCode, String[] permissions, int[] grantResults) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults);
        if (requestCode == REQUEST_STUDIO_PERMISSIONS) {
            StudioService.start(this);
            askAllFilesAccessOnce();
        }
    }

    private void requestStudioPermissions() {
        ArrayList<String> missing = new ArrayList<>();
        if (checkSelfPermission(Manifest.permission.RECORD_AUDIO)
                != PackageManager.PERMISSION_GRANTED) {
            missing.add(Manifest.permission.RECORD_AUDIO);
        }
        if (checkSelfPermission(Manifest.permission.POST_NOTIFICATIONS)
                != PackageManager.PERMISSION_GRANTED) {
            missing.add(Manifest.permission.POST_NOTIFICATIONS);
        }
        if (checkSelfPermission(Manifest.permission.READ_MEDIA_AUDIO)
                != PackageManager.PERMISSION_GRANTED) {
            missing.add(Manifest.permission.READ_MEDIA_AUDIO);
        }
        if (!missing.isEmpty()) {
            requestPermissions(missing.toArray(new String[0]), REQUEST_STUDIO_PERMISSIONS);
        } else {
            askAllFilesAccessOnce();
        }
    }

    // The music library needs to read whole folders. Ask once per start
    // until "All files access" is granted.
    private void askAllFilesAccessOnce() {
        if (mAskedAllFilesAccess || hasAllFilesAccess()) {
            return;
        }
        mAskedAllFilesAccess = true;
        openAllFilesAccessSettings();
    }
    // [AI-generated, end]
}
