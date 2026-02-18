#!/bin/bash
set -e

BOXES_DIR="$HOME/.local/share/gnome-boxes/images"
IMAGE_NAME="office-windows.qcow2"
IMAGE_PATH="$BOXES_DIR/$IMAGE_NAME"
IMAGE_URL="https://archive.org/download/windows11-office-lean/office-windows.qcow2"

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
virsh --connect qemu+unix:///session managedsave-remove WindowsOffice 2>/dev/null || true
virsh --connect qemu+unix:///session destroy WindowsOffice 2>/dev/null || true
virsh --connect qemu+unix:///session undefine WindowsOffice --nvram 2>/dev/null || true
virsh --connect qemu+unix:///session undefine WindowsOffice 2>/dev/null || true

VM_XML=$(mktemp /tmp/windows-office-XXXX.xml)

python3 -c "
import os
image_path = os.path.expandvars(os.path.expanduser(os.environ.get('IMAGE_PATH', '$HOME/.local/share/gnome-boxes/images/office-windows.qcow2')))
xml = open('/dev/stdin').read().replace('__IMAGE_PATH__', image_path)
open(os.environ['VM_XML'], 'w').write(xml)
" << 'XMLEOF'
<domain type='kvm'>
  <name>WindowsOffice</name>
  <metadata>
    <libosinfo:libosinfo xmlns:libosinfo="http://libosinfo.org/xmlns/libvirt/domain/1.0">
      <libosinfo:os id="http://microsoft.com/win/11"/>
    </libosinfo:libosinfo>
  </metadata>
  <memory unit='KiB'>4194304</memory>
  <currentMemory unit='KiB'>4194304</currentMemory>
  <vcpu placement='static'>2</vcpu>
  <os>
    <type arch='x86_64' machine='pc-i440fx-noble'>hvm</type>
    <boot dev='hd'/>
  </os>
  <features>
    <acpi/>
    <apic/>
    <hyperv mode='custom'>
      <relaxed state='on'/>
      <vapic state='on'/>
      <spinlocks state='on' retries='8191'/>
    </hyperv>
    <vmport state='off'/>
  </features>
  <cpu mode='host-passthrough' check='none' migratable='on'/>
  <clock offset='localtime'>
    <timer name='rtc' tickpolicy='catchup'/>
    <timer name='pit' tickpolicy='delay'/>
    <timer name='hpet' present='no'/>
    <timer name='hypervclock' present='yes'/>
  </clock>
  <on_poweroff>destroy</on_poweroff>
  <on_reboot>restart</on_reboot>
  <on_crash>destroy</on_crash>
  <pm>
    <suspend-to-mem enabled='no'/>
    <suspend-to-disk enabled='no'/>
  </pm>
  <devices>
    <emulator>/usr/bin/qemu-system-x86_64</emulator>
    <disk type='file' device='disk'>
      <driver name='qemu' type='qcow2'/>
      <source file='__IMAGE_PATH__'/>
      <target dev='sda' bus='ide'/>
    </disk>
    <controller type='usb' index='0' model='qemu-xhci' ports='15'/>
    <controller type='pci' index='0' model='pci-root'/>
    <controller type='ide' index='0'/>
    <controller type='virtio-serial' index='0'/>
    <interface type='user'>
      <model type='e1000e'/>
    </interface>
    <serial type='pty'>
      <target type='isa-serial' port='0'>
        <model name='isa-serial'/>
      </target>
    </serial>
    <console type='pty'>
      <target type='serial' port='0'/>
    </console>
    <channel type='spicevmc'>
      <target type='virtio' name='com.redhat.spice.0'/>
    </channel>
    <input type='tablet' bus='usb'/>
    <input type='mouse' bus='ps2'/>
    <input type='keyboard' bus='ps2'/>
    <graphics type='spice'>
      <listen type='none'/>
      <image compression='off'/>
      <gl enable='no'/>
    </graphics>
    <sound model='ich6'/>
    <audio id='1' type='spice'/>
    <video>
      <model type='qxl' ram='65536' vram='65536' vgamem='16384' heads='1' primary='yes'>
        <acceleration accel3d='no'/>
      </model>
    </video>
    <memballoon model='virtio'/>
  </devices>
</domain>
XMLEOF

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