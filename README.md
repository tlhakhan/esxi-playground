# Repo: esxi-playground 
- Scripts to create a vm playground on esxi hypervisors

## Script: ./deploy_vm.sh
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

# plans

done:
* got vm deploy script working - easily create templatized centos vms for home lab
* got vm destroy script working
* got snapshot revert - go back to last working good vm state, good for ansible script testing.

todo:
* get ipxe server setup for net-install
* create centos 7 mirror
* create pkgsrc mirror

ideas:
* zfs + snapshot + torrent
* zfs on linux