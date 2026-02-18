# Build Process: Lean Windows 11 Office VM

This documents the full process used to shrink a Windows 11 + Office VM from ~30GB to ~15GB, and the issues encountered along the way.

## Starting Point

A working tiny11-based Windows 11 VM with Microsoft Office installed, running in GNOME Boxes. Initial compressed qcow2 size: ~30GB.

## Goal

Smallest possible image that still runs Windows 11 + Office reliably in GNOME Boxes.

## Step 1: Prep Windows for Shrinking

Remove all useless softwares and files found.

Inside the VM, before touching partition size:

```powershell
# Disable hibernation (removes hiberfil.sys, frees several GB)
powercfg /h off

# Disable page file
# Control Panel → System → Advanced → Performance → Virtual Memory
# Set to "No paging file"

# Delete shadow copies
vssadmin delete shadows /all /quiet

# Run Disk Cleanup including system files
```

Windows' built-in Disk Management would only offer ~1.2GB of shrink due to immovable files — not worth it.

## Step 2: Shrink Partition with GParted

Windows tools can't move immovable files. GParted can.

1. Download GParted Live ISO on the host
2. Attach as CD in GNOME Boxes VM settings
3. Boot from it (GNOME Boxes supports ISO boot)
4. At keyboard config prompt: select **Don't touch keymap**
5. Shrink C:\ leaving ~2GB free above used space (not to absolute minimum — Windows needs breathing room)
6. Shut down, detach ISO

**Why not EaseUS/MiniTool?** GParted is free, no paywalled features, works outside the OS.

## Step 3: Find Partition End and Truncate

After shrinking the partition, the qcow2 virtual disk still allocates the full original size. We need to truncate it.

```bash
# Convert to raw to inspect partition layout
qemu-img convert -O raw office-windows.qcow2 office-windows.raw

# Find where the last partition ends
fdisk -l office-windows.raw
# Note the End sector of the last partition (e.g. 35022847)

# Truncate raw image to just past the last partition
truncate -s $((35022848 * 512)) office-windows.raw

# Recompress back to qcow2
qemu-img convert -O qcow2 -c office-windows.raw office-windows-trimmed.qcow2
```

Result: **15GB** — down from 30GB.

### Why not just qemu-img convert?

Running `qemu-img convert -O qcow2 -c` alone without truncating first doesn't help — it recompresses what's there, but empty partition space still occupies the virtual disk. The truncate step is what actually removes it.

## Step 4: Verify and Clean Up

```bash
# Boot the trimmed image and confirm Windows + Office work
# Then clean up
rm office-windows.raw office-windows-small.qcow2
```

## Errors Encountered

### `qemu-img resize` breaks Windows boot
Running `qemu-img resize image.qcow2 40G` on an already-configured image causes Windows to panic on next boot with error `0xc0000225`. The virtual disk geometry changes and Windows can't find its boot device.

**Fix:** Never resize the qcow2 from outside while Windows has a configured boot record. Expanding C:\ should always be done from inside Windows using `Resize-Partition`.

### GNOME Boxes shows "no KVM" on import
When manually importing a qcow2 via GNOME Boxes GUI, it may show a "no KVM" error even when KVM is available and the user is in the kvm group. This is misleading — the real issue is GNOME Boxes defaulting to UEFI for Windows 11, but the image is BIOS/MBR.

**Fix:** Register the VM via `virsh define` with an explicit BIOS/MBR XML config (see `scripts/vm.xml`).

### virt-install defaults to UEFI for win11
`virt-install --os-variant win11` automatically enables UEFI, secure boot, and TPM. The `--boot bios` flag doesn't exist in older versions.

**Fix:** Use `virsh define` with a hand-crafted XML using `machine='pc-i440fx-noble'` and no firmware/loader/nvram entries.

### First boot Recovery screen
After a fresh `virsh define`, Windows shows a blue Recovery screen (`0xc0000225`) on first boot. This is Windows detecting changed hardware (new VM device IDs) and running a recovery check.

**Fix:** Press **Enter** to try again. It boots normally on the second attempt.

### Symlink approach unreliable
The original approach of placing the qcow2 in `~/.local/share/gnome-boxes/images/` with a symlink named `boxes-unknown-2` worked on some setups but not others. GNOME Boxes needs a proper libvirt domain definition, not just a file in the images directory.

**Fix:** Use `virsh define` instead.

## Final Image Specs

- Virtual disk: matches partition end (~17GB virtual, 15GB actual)
- Actual qcow2 size: ~15GB
- C:\ used: ~14.6GB
- C:\ free: ~2GB
- Format: qcow2 zlib compressed
- Boot: BIOS/MBR, machine type pc-i440fx