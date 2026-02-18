#!/bin/bash
set -e

BOXES_DIR="$HOME/.local/share/gnome-boxes/images"
IMAGE_NAME="office-windows.qcow2"
IMAGE_PATH="$BOXES_DIR/$IMAGE_NAME"
IMAGE_URL="https://archive.org/download/windows11-office-lean/office-windows.qcow2"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo ""
echo "  Lean Windows 11 Office VM - Installer"
echo ""

sudo -v

if ! command -v gnome-boxes &> /dev/null || ! command -v virsh &> /dev/null; then
    echo "[1/3] Installing GNOME Boxes and dependencies..."
    sudo apt update || true
    sudo apt install -y gnome-boxes virtinst qemu-utils
else
    echo "[1/3] Dependencies already installed ✓"
fi

mkdir -p "$BOXES_DIR"

if [ -f "$IMAGE_PATH" ]; then
    echo "[2/3] Image already exists at $IMAGE_PATH — skipping download ✓"
else
    echo "[2/3] Downloading image (~15GB, this will take a while)..."
    wget --progress=bar:force -O "$IMAGE_PATH" "$IMAGE_URL"
fi

echo "[3/3] Registering VM..."
mkdir -p ~/.config/libvirt/qemu/lib
virsh --connect qemu+unix:///session managedsave-remove WindowsOffice 2>/dev/null || true
virsh --connect qemu+unix:///session destroy WindowsOffice 2>/dev/null || true
virsh --connect qemu+unix:///session undefine WindowsOffice --nvram 2>/dev/null || true
virsh --connect qemu+unix:///session undefine WindowsOffice 2>/dev/null || true

VM_XML=$(mktemp /tmp/windows-office-XXXX.xml)
sed "s|__IMAGE_PATH__|$IMAGE_PATH|g" "$SCRIPT_DIR/vm.xml" > "$VM_XML"
virsh --connect qemu+unix:///session define "$VM_XML"
rm "$VM_XML"

echo ""
echo "  Done! Image is at: $IMAGE_PATH"
echo ""
echo "  Open GNOME Boxes — the VM is ready to start."
echo "  Default user: Flash"
echo ""
echo "  Need more space? Boot the VM and run in PowerShell (Admin):"
echo "    Resize-Partition -DriveLetter C -Size <size>GB"
echo ""