#!/bin/sh

# AUTHOR: tlhakhan
# DESCRIPTION:
# This script will create a virtual machine on an ESXi 6+ hypervisor.
# * It will create a VM to specification dictated from the vmx template heredoc. 
# * It will create a small thin provisioned disk with 8G as OS drive.
# * It will mount an ISO image and have the cdrom connected for OS install.
#

# USAGE:
# ./deploy_vms [datastore name] [vm name] [ iso file ] [ guest os: centos7-64 | centos-64 | ]
#

# configuration parameters
DATASTORE="$1"
VM_NAME="$2" # please no spaces
ISO_IMAGE="$3"
GUEST_OS="${4:-centos7-64}" # default is centos7-64

# check arg length is 4
if [[ $# -ne 4 ]] 
then
	echo "Usage: ./deploy_vms [datastore name] [vm name] [ iso file ] [ guest os: centos7-64 | centos-64 | ]"
	exit 1
fi

# check if folder already exists
if [[ -d /vmfs/volumes/"$DATASTORE"/"$VM_NAME" ]]
then
        echo "Error:  virtual machine already exists."
        exit 1
fi

# creating vm
echo "Info:  creating virtual machine $VM_NAME"
mkdir /vmfs/volumes/"$DATASTORE"/"$VM_NAME"

cat << EOF_vm_template > /vmfs/volumes/"$DATASTORE"/"$VM_NAME"/"$VM_NAME".vmx
sata0:0.fileName = "$(readlink -f "$ISO_IMAGE")"
scsi0:0.fileName = "$VM_NAME.vmdk"
nvram = "$VM_NAME.nvram"
guestOS = "$GUEST_OS"
displayName = "$VM_NAME"
config.version = "8"
virtualHW.version = "13"
vmci0.present = "TRUE"
floppy0.present = "FALSE"
numvcpus = "1"
memSize = "1024"
bios.bootRetry.delay = "10"
sched.cpu.units = "mhz"
sched.cpu.affinity = "all"
powerType.suspend = "soft"
tools.upgrade.policy = "manual"
scsi0.virtualDev = "pvscsi"
scsi0.present = "TRUE"
sata0.present = "TRUE"
usb.present = "TRUE"
ehci.present = "TRUE"
scsi0:0.deviceType = "scsi-hardDisk"
sched.scsi0:0.shares = "normal"
sched.scsi0:0.throughputCap = "off"
scsi0:0.present = "TRUE"
ethernet0.virtualDev = "vmxnet3"
ethernet0.networkName = "VM Network"
ethernet0.addressType = "generated"
ethernet0.wakeOnPcktRcv = "FALSE"
ethernet0.uptCompatibility = "TRUE"
ethernet0.present = "TRUE"
sata0:0.deviceType = "cdrom-image"
sata0:0.present = "TRUE"
toolScripts.afterPowerOn = "TRUE"
toolScripts.afterResume = "TRUE"
toolScripts.beforeSuspend = "TRUE"
toolScripts.beforePowerOff = "TRUE"
tools.syncTime = "FALSE"
sched.cpu.min = "0"
sched.cpu.shares = "normal"
sched.mem.min = "0"
sched.mem.minSize = "0"
sched.mem.shares = "normal"
vmci0.id = "$(randomSeed)"
cleanShutdown = "TRUE"
sata0:0.autoDetect = "TRUE"
pciBridge0.present = "TRUE"
svga.present = "TRUE"
pciBridge4.present = "TRUE"
pciBridge4.virtualDev = "pcieRootPort"
pciBridge4.functions = "8"
pciBridge5.present = "TRUE"
pciBridge5.virtualDev = "pcieRootPort"
pciBridge5.functions = "8"
pciBridge6.present = "TRUE"
pciBridge6.virtualDev = "pcieRootPort"
pciBridge6.functions = "8"
pciBridge7.present = "TRUE"
pciBridge7.virtualDev = "pcieRootPort"
pciBridge7.functions = "8"
hpet0.present = "TRUE"
RemoteDisplay.maxConnections = "-1"
sched.cpu.latencySensitivity = "normal"
numa.autosize.vcpu.maxPerVirtualNode = "2"
numa.autosize.cookie = "20001"
pciBridge0.pciSlotNumber = "17"
pciBridge4.pciSlotNumber = "21"
pciBridge5.pciSlotNumber = "22"
pciBridge6.pciSlotNumber = "23"
pciBridge7.pciSlotNumber = "24"
scsi0.pciSlotNumber = "160"
usb.pciSlotNumber = "32"
ethernet0.pciSlotNumber = "192"
ehci.pciSlotNumber = "33"
vmci0.pciSlotNumber = "34"
sata0.pciSlotNumber = "35"
ethernet0.generatedAddressOffset = "0"
monitor.phys_bits_used = "43"
vmotion.checkpointFBSize = "4194304"
vmotion.checkpointSVGAPrimarySize = "4194304"
softPowerOff = "FALSE"
usb:1.speed = "2"
usb:1.present = "TRUE"
usb:1.deviceType = "hub"
usb:1.port = "1"
usb:1.parent = "-1"
svga.guestBackedPrimaryAware = "TRUE"
usb:0.present = "TRUE"
usb:0.deviceType = "hid"
usb:0.port = "0"
usb:0.parent = "-1"
EOF_vm_template

# create virtual disks
# size: 8g, type: file, diskformat: think
echo "Info:  Making vmkd files."
vmkfstools -c 8g -W file -d thin /vmfs/volumes/"$DATASTORE"/"$VM_NAME"/"$VM_NAME".vmdk

# register vm on vsphere
echo "Info:  Registering $VM_NAME into vSphere."

VM_ID=$(vim-cmd solo/registervm /vmfs/volumes/"$DATASTORE"/"$VM_NAME"/"$VM_NAME".vmx "$VM_NAME") # successful output is VMID

# power on the vm
echo "Info:  Powering on $VM_NAME."
vim-cmd vmsvc/power.on $VM_ID
vim-cmd vmsvc/power.getstate $VM_ID

# list of all vms
echo "Info:  List of all VMs."
vim-cmd vmsvc/getallvms
