# Lean Windows 11 Office VM for GNOME Boxes

Minimal Windows 11 + Microsoft Office, optimized for GNOME Boxes. **~15GB** on disk.

## Quickstart

```bash
make install
```

Then open GNOME Boxes. The VM will appear ready to start.

**First boot:** You may see a blue Recovery screen — this is normal. Press **Enter** to continue. Windows is just adjusting to the new VM environment.

**Default user:** Flash  
**First thing to do:** Activate Windows and Office with your licenses.

## Maintenance

```bash
make compress    # Reclaim space after Windows updates or cleanup
make backup      # Backup the image before risky operations
make clean       # Remove backups and temp files
make uninstall   # Remove VM, GNOME Boxes and configs (keeps image)
make uninstall IMAGE=1  # Also delete the image
```

## Need More Space?

The image ships with ~2GB free on C:\. To expand, open PowerShell as Administrator inside Windows:

```powershell
Get-PartitionSupportedSize -DriveLetter C   # check available space
Resize-Partition -DriveLetter C -Size 25GB  # expand to desired size
```

## What's Included
- Windows 11 (tiny11 base)
- Microsoft Office (Click-to-Run)
- SPICE Guest Tools

## Technical Details
- Format: qcow2 with zlib compression
- Boot: BIOS/MBR (not UEFI)
- Machine type: pc-i440fx

See [STEPS.md](STEPS.md) for the full process used to build this image.

---
Created: February 2026