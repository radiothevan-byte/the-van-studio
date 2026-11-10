#!/usr/bin/env python3
# THE VAN STUDIO [AI-generated, start]
# Written by an AI assistant (Claude).
#
# Lists dynamic symbols used by the native libraries of the APK that are not
# provided by the Android system libraries of a given API level (default 33)
# nor by another bundled library. Such symbols make the app crash on start
# ("cannot locate symbol ...") on older Android versions.
#
# Usage: check_android_api_level.py <libs dir> <ndk root> [api level]
# [AI-generated, end]
import glob
import os
import subprocess
import sys

SYSTEM_LIBS = [
    "libc.so", "libm.so", "libdl.so", "liblog.so", "libandroid.so",
    "libEGL.so", "libGLESv1_CM.so", "libGLESv2.so", "libGLESv3.so",
    "libOpenSLES.so", "libz.so", "libmediandk.so", "libaaudio.so",
    "libvulkan.so", "libjnigraphics.so", "libnativewindow.so", "libsync.so",
    "libamidi.so", "libbinder_ndk.so", "libcamera2ndk.so", "libicu.so",
]


def symbols(nm, path, defined):
    flag = "--defined-only" if defined else "--undefined-only"
    out = subprocess.run([nm, "-D", flag, path], capture_output=True, text=True)
    result = set()
    for line in out.stdout.splitlines():
        parts = line.split()
        if not parts:
            continue
        if not defined and parts[0] in ("w", "v"):
            continue  # weak undefined symbols may be missing
        name = parts[-1].split("@")[0]
        result.add(name)
    return result


def main():
    libs_dir, ndk = sys.argv[1], sys.argv[2]
    api = sys.argv[3] if len(sys.argv) > 3 else "33"
    prebuilt = glob.glob(os.path.join(ndk, "toolchains/llvm/prebuilt/*"))[0]
    nm = os.path.join(prebuilt, "bin/llvm-nm")
    stub_dir = os.path.join(prebuilt, "sysroot/usr/lib/aarch64-linux-android", api)
    provided = set()
    for lib in SYSTEM_LIBS:
        path = os.path.join(stub_dir, lib)
        if os.path.exists(path):
            provided |= symbols(nm, path, True)
    bundled = sorted(glob.glob(os.path.join(libs_dir, "*.so")))
    for lib in bundled:
        provided |= symbols(nm, lib, True)
    problems = 0
    for lib in bundled:
        missing = sorted(symbols(nm, lib, False) - provided)
        if missing:
            problems += len(missing)
            print(f"::warning::{os.path.basename(lib)} needs symbols missing on API {api}: "
                  + ", ".join(missing))
    print(f"Checked {len(bundled)} libraries against API {api}: "
          f"{problems} missing symbol(s)")
    return 1 if problems else 0


if __name__ == "__main__":
    sys.exit(main())
