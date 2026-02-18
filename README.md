# Lean Windows 11 Office VM for GNOME Boxes

A minimal Windows 11 installation (based on tiny11) optimized for office work only. Cleaned and compressed to ~24GB.

## What's Included
- Windows 11 (tiny11 base)
- Microsoft Office (Click-to-Run installation)
- SPICE Guest Tools (for VM integration)

## What's Been Removed
- Windows Store apps and UWP packages
- Windows Mail/Calendar
- Game DVR and Xbox components
- Media Player
- Windows Defender definition cache
- Temporary files and update caches
- Recovery partition

## Specifications
- Virtual disk size: 27GB
- Actual disk usage: ~24GB (compressed qcow2)
- C:\ partition: 26GB (with ~10GB free for user data)

## Installation

Run the install script:
```bash
chmod +x install.sh
./install.sh
```

Or manually:
```bash
# Install GNOME Boxes
sudo apt install gnome-boxes

# Download the image
wget -O ~/.local/share/gnome-boxes/images/office-windows.qcow2 \
  https://archive.org/download/windows11-office-lean/office-windows.qcow2

# Create symlink for GNOME Boxes
ln -s office-windows.qcow2 \
  ~/.local/share/gnome-boxes/images/boxes-unknown-2

# Launch GNOME Boxes
gnome-boxes
```

## First Boot
- Default user: Flash
- Office is pre-installed and ready to use
- Recommended: Activate Windows and Office with your licenses

## Expanding Storage
If you need more space in the future:

1. Boot the VM
2. Open PowerShell as Administrator:
```powershell
# Check maximum available space
Get-PartitionSupportedSize -DriveLetter C

# Expand to maximum (example: 50GB)
Resize-Partition -DriveLetter C -Size 50GB
```

3. Shut down the VM
4. Expand the qcow2 virtual disk from Linux:
```bash
qemu-img resize ~/.local/share/gnome-boxes/images/office-windows.qcow2 +23G
```

## Maintenance
To keep the image lean:
- Regularly clear `C:\Windows\Temp`
- Run Disk Cleanup occasionally
- Avoid installing unnecessary software

## Technical Details
- Base: tiny11 (minimal Windows 11)
- Format: qcow2 with zlib compression
- Boot: BIOS/MBR (not UEFI)
- Filesystem: NTFS

---
Created: February 2026
