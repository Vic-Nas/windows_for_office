#!/bin/bash
set -e

echo "=========================================="
echo "Lean Windows 11 Office VM Installer"
echo "=========================================="
echo ""

# Check if GNOME Boxes is installed
if ! command -v gnome-boxes &> /dev/null; then
    echo "[1/4] Installing GNOME Boxes..."
    sudo apt update
    sudo apt install -y gnome-boxes
else
    echo "[1/4] GNOME Boxes already installed ✓"
fi

# Create directory if it doesn't exist
BOXES_DIR="$HOME/.local/share/gnome-boxes/images"
mkdir -p "$BOXES_DIR"

# Download the image
IMAGE_URL="https://archive.org/download/windows11-office-lean/office-windows.qcow2"
IMAGE_PATH="$BOXES_DIR/office-windows.qcow2"

if [ -f "$IMAGE_PATH" ]; then
    echo "[2/4] Image already exists at $IMAGE_PATH"
    read -p "    Overwrite? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "    Skipping download."
    else
        echo "    Downloading image (this may take a while)..."
        wget -O "$IMAGE_PATH" "$IMAGE_URL"
    fi
else
    echo "[2/4] Downloading Windows image (~24GB, this will take a while)..."
    wget --progress=bar:force -O "$IMAGE_PATH" "$IMAGE_URL"
fi

# Create symlink for GNOME Boxes
SYMLINK_PATH="$BOXES_DIR/boxes-unknown-2"
echo "[3/4] Creating GNOME Boxes symlink..."
if [ -L "$SYMLINK_PATH" ]; then
    rm "$SYMLINK_PATH"
fi
ln -s office-windows.qcow2 "$SYMLINK_PATH"

echo "[4/4] Setup complete!"
echo ""
echo "=========================================="
echo "Installation finished!"
echo "=========================================="
echo ""
echo "You can now launch GNOME Boxes and start using Windows 11."
echo ""
echo "To start GNOME Boxes, run:"
echo "  gnome-boxes"
echo ""
echo "Or search for 'Boxes' in your application menu."
echo ""
