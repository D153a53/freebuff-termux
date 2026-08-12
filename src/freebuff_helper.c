#include <stdlib.h>
#include <unistd.h>
#include <string.h>
#include <libgen.h>
#include <limits.h>
#include <stdio.h>
#include <sys/ioctl.h>

int main(int argc, char** argv) {
    unsetenv("LD_PRELOAD");
    unsetenv("LD_LIBRARY_PATH");

    setenv("GODEBUG", "netdns=cgo", 1);
    setenv("SSL_CERT_FILE", "/data/data/com.termux/files/usr/etc/tls/cert.pem", 1);

    // Enforce COLUMNS=80 if screen width is under 80 columns so full TUI logo fits without wrapping
    struct winsize ws;
    if (ioctl(STDOUT_FILENO, TIOCGWINSZ, &ws) == 0) {
        if (ws.ws_col < 80) {
            setenv("COLUMNS", "80", 1);
        }
    } else {
        setenv("COLUMNS", "80", 1);
    }

    char real_bin[] = "/data/data/com.termux/files/home/.local/share/freebuff/freebuff";

    char** new_argv = malloc((argc + 1) * sizeof(char*));
    if (!new_argv) {
        return 1;
    }

    new_argv[0] = real_bin;

    for (int i = 1; i < argc; i++) {
        new_argv[i] = argv[i];
    }
    new_argv[argc] = NULL;

    execv(real_bin, new_argv);

    perror("execv");
    free(new_argv);
    return 1;
}
