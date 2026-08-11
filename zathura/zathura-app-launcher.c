#include <errno.h>
#include <limits.h>
#include <mach-o/dyld.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>

int main(int argc, char **argv) {
  char launcher_path[PATH_MAX];
  uint32_t launcher_path_size = sizeof(launcher_path);

  if (_NSGetExecutablePath(launcher_path, &launcher_path_size) != 0) {
    fputs("Zathura launcher: executable path is too long\n", stderr);
    return 1;
  }

  char *last_slash = strrchr(launcher_path, '/');
  if (last_slash == NULL) {
    fputs("Zathura launcher: invalid bundle executable path\n", stderr);
    return 1;
  }
  strcpy(last_slash + 1, "zathura-bin");

  char **child_argv = calloc((size_t)argc + 2, sizeof(*child_argv));
  if (child_argv == NULL) {
    perror("Zathura launcher: calloc");
    return 1;
  }

  child_argv[0] = launcher_path;
  child_argv[1] = "--no-titlebar";
  for (int i = 1; i < argc; ++i) {
    child_argv[i + 1] = argv[i];
  }

  execv(launcher_path, child_argv);
  fprintf(stderr, "Zathura launcher: execv failed: %s\n", strerror(errno));
  free(child_argv);
  return 1;
}
