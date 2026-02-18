#!/bin/bash

BOXES_DIR="$HOME/.local/share/gnome-boxes/images"
IMAGE_PATH="$BOXES_DIR/office-windows.qcow2"
DELETE_IMAGE="${1:-0}"

echo ""
echo "  This will remove the VM, GNOME Boxes, and all configs."
if [ "$DELETE_IMAGE" = "1" ]; then
    echo "  The image file ($IMAGE_PATH) will also be deleted."
fi
echo ""
read -p "  Continue? (y/N): " -n 1 -r
echo
[[ ! $REPLY =~ ^[Yy]$ ]] && echo "  Aborted." && exit 0

# Remove storage pool
virsh --connect qemu+unix:///session pool-destroy gnome-boxes 2>/dev/null || true
virsh --connect qemu+unix:///session pool-undefine gnome-boxes 2>/dev/null || true

# Remove VM definition
echo "  Removing VM..."
virsh --connect qemu+unix:///session managedsave-remove WindowsOffice 2>/dev/null || true
virsh --connect qemu+unix:///session destroy WindowsOffice 2>/dev/null || true
virsh --connect qemu+unix:///session undefine WindowsOffice --nvram 2>/dev/null || true
virsh --connect qemu+unix:///session undefine WindowsOffice 2>/dev/null || true

# Uninstall packages
echo "  Uninstalling packages..."
sudo apt remove --purge gnome-boxes virtinst -y

# Remove configs and caches
echo "  Removing configs..."
# Back up image to temp location before wiping directory
if [ "$DELETE_IMAGE" != "1" ] && [ -f "$IMAGE_PATH" ]; then
    TMP_IMAGE=$(mktemp /tmp/office-windows-XXXX.qcow2)
    mv "$IMAGE_PATH" "$TMP_IMAGE"
fi

rm -rf ~/.local/share/gnome-boxes
rm -rf ~/.config/gnome-boxes
rm -rf ~/.config/libvirt
rm -rf ~/.local/share/libvirt

# Restore image if not deleting
if [ "$DELETE_IMAGE" != "1" ] && [ -n "$TMP_IMAGE" ] && [ -f "$TMP_IMAGE" ]; then
    mkdir -p "$(dirname "$IMAGE_PATH")"
    mv "$TMP_IMAGE" "$IMAGE_PATH"
fi

echo ""
echo "  Done. Everything has been removed."
if [ "$DELETE_IMAGE" != "1" ] && [ -f "$IMAGE_PATH" ]; then
    echo "  Image kept at: $IMAGE_PATH"
    echo "  To also delete it, run: make uninstall IMAGE=1"
fi
echo ""