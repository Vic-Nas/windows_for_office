#!/bin/bash
set -e

BOXES_DIR="$HOME/.local/share/gnome-boxes/images"
IMAGE_PATH="$BOXES_DIR/office-windows.qcow2"
TMP_PATH="$BOXES_DIR/office-windows-compressed.qcow2"

echo ""
echo "  Make sure the VM is shut down before continuing."
read -p "  Continue? (y/N): " -n 1 -r
echo
[[ ! $REPLY =~ ^[Yy]$ ]] && echo "  Aborted." && exit 0

echo "  Recompressing image..."
qemu-img convert -O qcow2 -c "$IMAGE_PATH" "$TMP_PATH"

OLD_SIZE=$(du -sh "$IMAGE_PATH" | cut -f1)
NEW_SIZE=$(du -sh "$TMP_PATH" | cut -f1)

mv "$TMP_PATH" "$IMAGE_PATH"

echo ""
echo "  Done! $OLD_SIZE → $NEW_SIZE"
echo ""