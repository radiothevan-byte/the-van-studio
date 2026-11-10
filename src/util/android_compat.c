// THE VAN STUDIO [AI-generated, start]
// Written by an AI assistant (Claude).
//
// Compatibility shim for Android 13 (API 33). The prebuilt Qt 6 libraries
// shipped in the Mixxx build environment are built for API 35 and reference
// libc functions that only exist from Android 14. Without them the dynamic
// linker refuses to load libQt6Core and the app crashes on start.
// The build adds this library as a dependency of libQt6Core (see
// CMakeLists.txt), so the symbols are found here on older devices. On newer
// devices libc's own implementation is found first.
// [AI-generated, end]
#include <errno.h>
#include <sys/syscall.h>
#include <sys/types.h>
#include <unistd.h>

#define VAN_EXPORT __attribute__((visibility("default")))

// Added to bionic in API 34. The kernel syscall exists since Linux 4.5.
VAN_EXPORT ssize_t copy_file_range(int fd_in,
        off64_t* off_in,
        int fd_out,
        off64_t* off_out,
        size_t len,
        unsigned int flags) {
#ifdef __NR_copy_file_range
    return (ssize_t)syscall(__NR_copy_file_range, fd_in, off_in, fd_out, off_out, len, flags);
#else
    (void)fd_in;
    (void)off_in;
    (void)fd_out;
    (void)off_out;
    (void)len;
    (void)flags;
    errno = ENOSYS;
    return -1;
#endif
}
