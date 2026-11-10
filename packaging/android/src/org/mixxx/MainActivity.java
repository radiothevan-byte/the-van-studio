package org.mixxx;

import android.Manifest;
import android.content.pm.PackageManager;
import android.os.Bundle;
import android.view.WindowManager;
import androidx.core.view.ViewCompat;
import androidx.core.view.WindowCompat;
import androidx.core.view.WindowInsetsCompat;
import androidx.core.view.WindowInsetsControllerCompat;
import java.util.ArrayList;
import org.qtproject.qt.android.QtActivityBase;

public class MainActivity extends QtActivityBase {
    // THE VAN STUDIO [AI-generated, start]
    private static final int REQUEST_STUDIO_PERMISSIONS = 4712;
    // [AI-generated, end]

    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        // Disable drawing over cutout - isn't working
        WindowManager.LayoutParams lp = this.getWindow().getAttributes();
        lp.layoutInDisplayCutoutMode = WindowManager.LayoutParams.LAYOUT_IN_DISPLAY_CUTOUT_MODE_NEVER;

        // Disable system and navigation bar to prevent accidental back or app switch
        WindowInsetsControllerCompat windowInsetsController =
            WindowCompat.getInsetsController(getWindow(), getWindow().getDecorView());
        windowInsetsController.setSystemBarsBehavior(
            WindowInsetsControllerCompat.BEHAVIOR_SHOW_TRANSIENT_BARS_BY_SWIPE);
        windowInsetsController.hide(WindowInsetsCompat.Type.navigationBars());

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
        if (!missing.isEmpty()) {
            requestPermissions(missing.toArray(new String[0]), REQUEST_STUDIO_PERMISSIONS);
        }
    }
    // [AI-generated, end]
}
