#!/bin/sh
# Copy the finished SD-card image somewhere Windows can reach it, for
# Raspberry Pi Imager.
#
# Override the destination directory from the shell:
#
#   COPY_DIR=/mnt/d/tmp make
#
# The image is skipped (with a warning, not an error) if the directory is
# not mounted, so builds still work without the Windows drive present.

set -eu

BINARIES_DIR="$1"
COPY_DIR="${COPY_DIR:-/mnt/c/tmp}"
SRC="$BINARIES_DIR/sdcard.img"
DST="$COPY_DIR/sdcard-nezha.img"

if [ ! -f "$SRC" ]; then
	echo "WARNING: $SRC not found, nothing to copy" >&2
	exit 0
fi

if [ ! -d "$COPY_DIR" ]; then
	echo "WARNING: $COPY_DIR is not available; image left at $SRC" >&2
	exit 0
fi

cp -f "$SRC" "$DST"
echo "Copied $SRC -> $DST"
