# VM TOOLS

A thin later around virsh to allow one to setup a host for running vms

## vminstall.sh

On the host where vms will run you can use the vminstall.sh script to create a base vm from which you can create independent
vm instances.  By default it creates vm's installed with fedora release on to a bootable disk.

## vmsave.sh

On the host where you have created your base vm, with `vminstall.sh`, you can save the base vm image with `vmsave.sh`. This script will
create a tar file that you can store to allow others to directly use the `vmload.sh` script rather than having to install their own.

## vmload.sh

On the host where you plan to run vm's you can use the vmload script to create the base vm from a saved image of it hosted on a webserver.

## Commands to create, start and access vm's

These scripts can be run anywhere.  They will ssh their commands to the VM host for you to get access to them.

### vmnew <name>

You can use this on any host to create a new vm, of the name specified, on the vmhost.  This will clone a new independent version of the basevm for you. Eg. `newvm dev`

You can then use the `vm` command to access it.

## vm [name]

This is the main daily command you will use.  With no arguments it will list your vm's that you have created with `vmnew` on the vm host.  If you pass it the name of one of these vm's it will start it, if needed, and attach to the console.

## vmssh [name]

This coammand will ssh to the specified vm on the vmhost.

## vmip [name]

This attempts to determine the ip address of the specified vm assuming it has an interfaced attached to virbr0 (default network)

