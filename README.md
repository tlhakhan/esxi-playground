## Repo: esxi-playground 
- Scripts to create a virtual machine playground on ESXi hypervisors.  Useful for homelab environments, where setting up vCenter is frowned upon and free ESXi licenses are readily available.  
- The ESXi hypervisor is of great interest to me, it is a very lightweight and purpose-built OS.  
  - There are design/architecture patterns from good OS engineers at VMware that are worth incorporating into my own thinking.
- The below scripts can be placed on your esxi hypervisor server.
  - [deploy_vm.sh](#deploy_vmsh)
  - [destroy_vm.sh](#destroy_vmsh)
  - [reset_vm.sh](#reset_vmsh)
- Please use only for development/testing.  These scripts are used for my ESXi home lab virtual machine deployments.

## deploy_vm.sh
- The `deploy_vm.sh` script will deploy a small VM to [specification listed in the heredoc template](https://github.com/tlhakhan/esxi-playground/blob/master/deploy_vm.sh#L39) inside this shell script.
- The virtual machine will automatically power on and have the given ISO file mounted.

### Usage
```
[root@vs-00:~] ./deploy_vm.sh
Usage: ./deploy_vms [datastore name] [vm name] [ iso file ] [ guest os: centos7-64 | centos-64 | other ]
```

#### Example Output:  Successful VM Creation
```bash
[root@vs-00:~] ./deploy_vm.sh vs-00-das repo-00 /vmfs/volumes/vs-00-das/image-repo/CentOS-7-x86_64-Everything-1708.iso centos7-64
Info:  creating virtual machine repo-00
Info:  Making misc files.
Info:  Making vmkd files.
Create: 100% done.
Info:  Registering repo-00 into vSphere.
Info:  Powering on repo-00.
Powering on VM:
Retrieved runtime info
Powered on
Info:  List of all VMs.
Vmid      Name                        File                         Guest OS        Version   Annotation
10     centos-00     [vs-00-das] centos-00/centos-00.vmx       centos7_64Guest     vmx-13
11     centos-01     [vs-00-das] centos-01/centos-01.vmx       centos7_64Guest     vmx-13
20     centos-02     [vs-00-das] centos-02/centos-02.vmx       centos7_64Guest     vmx-11
21     repo-00       [vs-00-das] repo-00/repo-00.vmx           centos7_64Guest     vmx-11
6      firewall-00   [vs-00-das] firewall-00/firewall-00.vmx   freebsd64Guest      vmx-13
8      smos-00       [vs-00-das] smos-00/smos-00.vmx           solaris11_64Guest   vmx-13
9      smos-01       [vs-00-das] smos-01/smos-01.vmx           solaris11_64Guest   vmx-13
```

#### Example Output:  VM Already Exists
```bash
[root@vs-00:~] ./deploy_vm.sh vs-00-das repo-00 /vmfs/volumes/vs-00-das/image-repo/CentOS-7-x86_64-Everything-1708.iso centos7-64
Error:  virtual machine already exists.
```

#### Example Output: Invalid # of Arguments
```bash
[root@vs-00:~] ./deploy_vm.sh vs-00-das repo-00 /vmfs/volumes/vs-00-das/image-repo/CentOS-7-x86_64-Everything-1708.iso
Usage: ./deploy_vms [datastore name] [vm name] [ iso file ] [ guest os: centos7-64 | centos-64 | ]
```

## destroy_vm.sh
- Given the datastore and vm name, the `destroy_vm.sh` script will unregister the virtual machine and destroy the virtual machine folder on the datastore.

### Usage:
```bash
[root@vs-00:~] ./destroy_vm.sh
Usage:  ./destroy_vm.sh [ datastore ] [vm name]
```

#### Example Output:

```bash
Info:  List of all VMs.
Vmid      Name                        File                         Guest OS        Version   Annotation
10     centos-00     [vs-00-das] centos-00/centos-00.vmx       centos7_64Guest     vmx-13
11     centos-01     [vs-00-das] centos-01/centos-01.vmx       centos7_64Guest     vmx-13
29     nagios-00     [vs-00-das] nagios-00/nagios-00.vmx       centos7_64Guest     vmx-13
30     repo-00       [vs-00-das] repo-00/repo-00.vmx           centos7_64Guest     vmx-13
31     dummy-00      [vs-00-das] dummy-00/dummy-00.vmx         centos7_64Guest     vmx-13
6      firewall-00   [vs-00-das] firewall-00/firewall-00.vmx   freebsd64Guest      vmx-13
8      smos-00       [vs-00-das] smos-00/smos-00.vmx           solaris11_64Guest   vmx-13
9      smos-01       [vs-00-das] smos-01/smos-01.vmx           solaris11_64Guest   vmx-13

[root@vs-00:~] ./destroy_vm.sh vs-00-das dummy-00
Powering off VM:
Info:  Successfully unregistered dummy-00
Info: Successfully destroyed dummy-00
```

## reset_vm.sh

### Usage:
- Given the virtual machine name, revert to the most recent snapshot.  
  - If a snapshot is not present, the `reset_vm.sh` script will create an initial snapshot with the name and description snap0.  The snapshot will retain powered on state and running memory state.

```bash
[root@vs-00:~] ./reset_vm.sh
Usage ./reset_vm.sh [ vm name ]
```

#### Example Output: VM with no snapshots
```bash
[root@vs-00:~] ./reset_vm.sh nagios-00
Warn:  Unable to find a snapshot on the virtual machine.
Info:  Creating an initial snapshot.
Create Snapshot:
Get Snapshot:
|-ROOT
--Snapshot Name        : snap0
--Snapshot Id        : 5
--Snapshot Desciption  : snap0
--Snapshot Created On  : 11/29/2017 23:59:6
--Snapshot State       : powered on
```

#### Example Output:  VM with an recent snapshot
```bash
[root@vs-00:~] ./reset_vm.sh nagios-00
Info:  Reverting VM to most recent snapshot.
Revert Snapshot:
|-ROOT
--Snapshot Name        : snap0
--Snapshot Id        : 5
--Snapshot Desciption  : snap0
--Snapshot Created On  : 11/29/2017 23:59:6
--Snapshot State       : powered on
--|-CHILD
----Snapshot Name        : finish_naigos_install
----Snapshot Id        : 6
----Snapshot Desciption  : install done
----Snapshot Created On  : 11/30/2017 0:0:4
----Snapshot State       : powered on
```
