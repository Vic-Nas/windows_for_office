# Lean Windows 11 Office VM for GNOME Boxes

A minimal Windows 11 installation optimized for office work. Ships at **~15GB** — the smallest it can get while keeping Windows + Office functional.

## What's Included
- Windows 11 (tiny11 base)
- Microsoft Office (Click-to-Run)
- SPICE Guest Tools (VM integration)

## What's Been Removed
- Windows Store and UWP apps
- Mail, Calendar, Xbox, Game DVR
- Media Player
- Defender definition cache
- Temp files, update caches, recovery partition

## Specs
- Virtual disk: 40GB (sparse — only real data takes space on your drive)
- Actual disk usage: ~15GB
- C:\ partition: ~17GB (2GB headroom above Windows + Office)

## Install

```bash
make install
```

That's it. The image will be downloaded to `~/.local/share/gnome-boxes/images/` and registered with GNOME Boxes automatically. You'll be told where it lives in case you have other uses for it.

Then launch GNOME Boxes — the VM will appear ready to start.

**Default user:** Flash  
**First thing to do:** Activate Windows and Office with your licenses.

## Maintenance

After Windows updates or running Disk Cleanup inside the VM, recompress to reclaim space:

```bash
make compress
```

Remove backups and temp files:

```bash
make clean
```

Before anything risky, back up the image:

```bash
make backup
```

## Need More Space?

The virtual disk is already set to 40GB, but C:\ only uses ~17GB of it. To expand whenever you need room, open PowerShell inside Windows as Administrator:

```powershell
# See how much you can expand
Get-PartitionSupportedSize -DriveLetter C

# Expand (example: to 35GB)
Resize-Partition -DriveLetter C -Size 35GB
```

No changes needed outside the VM — the sparse qcow2 will grow on demand.

## Technical Details
- Base: tiny11 (minimal Windows 11)
- Format: qcow2 with zlib compression
- Boot: BIOS/MBR
- Filesystem: NTFS

---
Created: February 2026