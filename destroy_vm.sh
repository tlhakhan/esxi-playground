#!/bin/sh

DATASTORE=$1
VM_NAME=$2

# check if folder already exists
if [[ ! -d /vmfs/volumes/"$DATASTORE"/"$VM_NAME" ]]
then
        echo "Error:  Virtual machine does not exists."
        exit 1
fi

VM_ID=$(vim-cmd vmsvc/getallvms | grep "$VM_NAME" | awk '{print $1}')

if [[ ! -z "$VM_ID" ]] 
then
	vim-cmd vmsvc/power.off $VM_ID
	vim-cmd vmsvc/unregister $VM_ID 
	if [[ $? -eq 0 ]]
	then
		echo "Info:  Successfully unregistered $VM_NAME"
		rm -rf /vmfs/volumes/"$DATASTORE"/"$VM_NAME" && echo "Info: Successfully destroyed $VM_NAME"
	fi
else
	echo "Error:  Unable to find $VM_NAME"
	exit 1
fi
