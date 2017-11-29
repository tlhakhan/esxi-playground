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
.encoding = "UTF-8"
config.version = "8"
virtualHW.version = "11"
nvram = "$VM_NAME.nvram"
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
vmci0.present = "TRUE"
hpet0.present = "TRUE"
memSize = "2048"
sched.cpu.units = "mhz"
powerType.powerOff = "default"
powerType.suspend = "default"
powerType.reset = "default"
ide0:0.deviceType = "cdrom-image"
ide0:0.fileName = "$ISO_IMAGE"
ide0:0.present = "TRUE"
floppy0.present = "FALSE"
ethernet0.virtualDev = "vmxnet3"
ethernet0.networkName = "VM Network"
ethernet0.addressType = "generated"
ethernet0.uptCompatibility = "TRUE"
ethernet0.present = "TRUE"
displayName = "$VM_NAME"
guestOS = "$GUEST_OS"
toolScripts.afterPowerOn = "TRUE"
toolScripts.afterResume = "TRUE"
toolScripts.beforeSuspend = "TRUE"
toolScripts.beforePowerOff = "TRUE"
chipset.onlineStandby = "FALSE"
sched.cpu.min = "0"
sched.cpu.shares = "normal"
sched.mem.min = "0"
sched.mem.minSize = "0"
sched.mem.shares = "normal"
scsi0.virtualDev = "lsilogic"
scsi0.present = "TRUE"
scsi0:0.deviceType = "scsi-hardDisk"
scsi0:0.fileName = "$VM_NAME.vmdk"
scsi0:0.present = "TRUE"
EOF_vm_template

# create misc files
echo "Info:  Making misc files."
touch /vmfs/volumes/"$DATASTORE"/"$VM_NAME"/"$VM_NAME".vmsd

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
