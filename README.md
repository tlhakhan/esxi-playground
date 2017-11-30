## Repo: esxi-playground 
- Scripts to create a vm playground on esxi hypervisors
  - [deploy_vm.sh](#deploy_vmsh)
  - [destroy_vm.sh](#destroy_vmsh)
  - [reset_vm.sh](#reset_vmsh)

## deploy_vm.sh
- Use this script to automatically deploy a small VM to specification listed in the heredoc template inside this shell script.
- The VM will automatically power on and have the given ISO file mounted.

### Usage
```
[root@vs-00:~] ./deploy_vm.sh
Usage: ./deploy_vms [datastore name] [vm name] [ iso file ] [ guest os: centos7-64 | centos-64 | ]
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
- Given the datastore and vm name, this script will unregister the VM and destroy the VM.

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
- Given the virtual machine name revert to the most recent snapshot.  If a snapshot is not present, the reset_vm.sh will create an initial snapshot with the name and description snap0.

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

### Example Output:  VM with an recent snapshot
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
