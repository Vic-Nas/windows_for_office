#!/bin/bash
set -e

BOXES_DIR="$HOME/.local/share/gnome-boxes/images"
IMAGE_PATH="$BOXES_DIR/office-windows.qcow2"
BACKUP_PATH="$BOXES_DIR/office-windows.qcow2.bak"

echo ""
if [ ! -f "$IMAGE_PATH" ]; then
    echo "  Error: image not found at $IMAGE_PATH"
    exit 1
fi

if [ -f "$BACKUP_PATH" ]; then
    echo "  Backup already exists at $BACKUP_PATH"
    read -p "  Overwrite? (y/N): " -n 1 -r
    echo
    [[ ! $REPLY =~ ^[Yy]$ ]] && echo "  Aborted." && exit 0
fi

echo "  Backing up image (this may take a while)..."
cp "$IMAGE_PATH" "$BACKUP_PATH"
echo "  Backup saved to: $BACKUP_PATH"
echo ""