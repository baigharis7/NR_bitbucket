#!/usr/bin/env bash
# Test runner shortcuts for nutrenaissance_flutter.
#
# Usage:
#   tools/test.sh              # fast: compact reporter, no coverage
#   tools/test.sh full         # capture all output to /tmp/flutter_test_full.txt
#   tools/test.sh fast-skip-slow  # exclude tests tagged 'slow'
#   tools/test.sh <path>       # run a specific file or directory with compact output
#
# Flutter binary is hardcoded because Flutter is not on PATH on this machine
# (per MEMORY.md). Override by setting FLUTTER=/path/to/flutter.
#
# Defaults (compact reporter, 30s timeout) come from dart_test.yaml — no flags
# needed for everyday use.

set -euo pipefail

FLUTTER="${FLUTTER:-/home/irfanahm3d/flutter/bin/flutter}"
MODE="${1:-fast}"

case "$MODE" in
  fast)
    exec "$FLUTTER" test
    ;;
  full)
    # Capture everything for later grep / analysis. Uses `script` so colors
    # and progress are preserved. Output goes to /tmp/flutter_test_full.txt.
    exec script -q -c "$FLUTTER test --reporter=expanded" /tmp/flutter_test_full.txt
    ;;
  fast-skip-slow)
    # Honors @Tags(['slow']) annotations, declared in dart_test.yaml.
    exec "$FLUTTER" test --exclude-tags=slow
    ;;
  *)
    # Treat the argument as a path/glob for a focused run.
    exec "$FLUTTER" test "$MODE"
    ;;
esac
