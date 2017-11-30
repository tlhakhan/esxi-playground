#!/bin/sh

VM_NAME=$1

if [[ $# -ne 1 ]]
then
	echo "Usage ./reset_vm.sh [ vm name ]"
	exit 1
fi

VM_ID=$(vim-cmd vmsvc/getallvms | grep "$VM_NAME" | awk '{print $1}')
LAST_SNAP_ID=$(vim-cmd vmsvc/snapshot.get $VM_ID | grep Id | tail -n 1 | awk '{print $NF}')

if [[ -z "$LAST_SNAP_ID" ]]
then
	echo "Warn:  Unable to find a snapshot on the virtual machine."
	echo "Info:  Creating an initial snapshot."
	vim-cmd vmsvc/snapshot.create $VM_ID snap0 snap0 True True
	vim-cmd vmsvc/snapshot.get $VM_ID
	exit 1	
else
	echo "Info:  Reverting VM to most recent snapshot."
	vim-cmd vmsvc/snapshot.revert $VM_ID $LAST_SNAP_ID false
fi
