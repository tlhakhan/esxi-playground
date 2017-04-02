#!/bin/sh

VM_NAME=$1
VM_ID=$(vim-cmd vmsvc/getallvms | grep $1 | awk '{print $1}')

if [[ ! -z "$VM_ID" ]] 
then
	vim-cmd vmsvc/power.off $VM_ID
	vim-cmd vmsvc/unregister $VM_ID 
	if [[ $? -eq 0 ]]
	then
		echo "Successfully unregistered $VM_NAME"
		rm -rf $VM_NAME && echo "Successfully destroyed $VM_NAME"
	fi
else
	echo "Error: unable to find $VM_NAME"
	exit 1
fi
