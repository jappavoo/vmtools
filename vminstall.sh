#!/bin/bash

scriptdir=$(dirname $(realpath $0))
configdir=$scriptdir/config

# defaults for launching vms from the created image
[[ -z $VMMEM ]] && [[ -a $configdir/VMMEM ]] && VMMEM=$(cat $configdir/VMMEM);
VMMEM=${VMMEM:-8G}
[[ -z $VMCPUS ]] && [[ -a $configdir/VMCPUS ]] && VMCPUS=$(cat $configdir/VMCPUS);
VMCPUS=${VMCPUS:-4}
[[ -z $VMDISKSIZE ]] && [[ -a $configdir/VMDISKSIZE ]] && VMDISKSIZE=$(cat $configdir/VMDISKSIZE);
VMDISKSIZE=${VMDISKSIZE:-200}


total_memory=$(free -m | awk '/^Mem:/{print $2}')
# try to do the install using 1/4 of the free memory
# install_ram_allocation=$((total_memory * 1 / 4))
# default to do the install with the same amount of memory the VM default memory
# size will be
install_ram_allocation=${VMMEM}
# try go do the install using 1/2 of the cores
# default to do the install with the same amount of memory the VM default memory
# size will be
# install_total_cores=$(($(nproc)/2))
#install_total_cores=$(($(nproc)/2))
install_total_cores=${VMCPUS}



ARCH=$(uname -i)
DOMAIN=${1:-basevm-$ARCH}
VMUSER=${2:-user}
VMPASSWD=${3:-user}
FEDORARELEASE=38
VMSDIR=vms

LOCATION=${LOCATION:-"https://download.fedoraproject.org/pub/fedora/linux/releases/$FEDORARELEASE/Everything/$(uname -i)/os/"}

info() {
    echo configdir:$configdir VMMEM:$VMMEM VMCPUS:$VMCPUS VMDISKSIZE:$VMDISKSIZE
    echo    Install using: memory:$install_ram_allocation cpus:$install_total_cores
    echo    ARCH:$ARCH DOMAIN:$DOMAIN VMUSER:$VMUSER VMPASSWD:$VMPASSWD
    echo    FEDORARELEASE:$FEDORARELEASE
    echo    FEDORAURL:$LOCATION
    echo    VMSDIR:$VMSDIR DOMAIN: $DOMAIN
}

if [[ -z $DOMAIN ]]; then
    echo "USAGE: $0 <DOMAIN NAME>"
    exit -1
fi

info

if [[ ! -d $VMSDIR ]]; then
    mkdir ${VMSDIR}
fi

if [[ ! -a $DOMAIN.ks ]]; then
# create $DOMAIN.ks
cat >$DOMAIN.ks <<EOF
#version=DEVEL
# System authorization information
# auth --enableshadow --passalgo=sha512

# Use the Fedora installation media
url --url="$LOCATION"

# Run the setup agent on first boot
firstboot --enable

# Use network installation
network --bootproto=dhcp --device=link --onboot=on --activate

# Set the hostname
# hostname --static=$DOMAIN.localdomain

# Set the timezone
timezone --utc America/New_York

# Set the bootloader options
bootloader --append="crashkernel=auto" --location=mbr

# Clear the Master Boot Record
zerombr

# Partition layout
clearpart --all --initlabel
autopart --type=lvm

# clearpart --all --initlabel
# autopart --type=lvm --fstype="ext4" --lvmpvopts="--metadatasize=128M" --lvmlvopts="--thinpool --metadatasize=128M" --grow

# clearpart --all --initlabel
# part /boot --fstype=xfs --size=1024
# part pv.01 --size=1 --grow
# volgroup myvg pv.01
# logvol / --fstype=ext4 --vgname=myvg --size=1 --grow --thin --name=lv_root
# logvol /home --fstype=ext4 --vgname=myvg --size=1 --grow --thin --name=lv_home


# Set the root password
rootpw --plaintext root

# Enable firewall
firewall --enabled --service=ssh

# Enable SELinux
selinux --enforcing

# Do not configure X Window System
skipx

# System services
services --enabled="chronyd"

# System language
lang en_US.UTF-8

# Keyboard layout
keyboard --vckeymap=us --xlayouts='us'

# System timezone
timezone America/New_York --utc

user --name=${VMUSER} --password=${VMPASSWD} --gecos="${VMUSER}" --groups=wheel

# Reboot after installation
reboot

# Add your desired packages
%packages
git
make
%end

%post
# Add any post-installation scripts here
%end

EOF
fi


virt-install \
  --name $DOMAIN \
  --memory="memory=$install_ram_allocation" \
  --disk path="$(pwd)/${VMSDIR}/$DOMAIN.qcow2,size=${VMDISKSIZE},format=qcow2" \
  --check disk_size=off \
  --vcpus $install_total_cores \
  --network bridge=virbr0 \
  --graphics none \
  --console pty,target_type=serial \
  --location $LOCATION \
  --initrd-inject="$(pwd)/$DOMAIN.ks" \
  --extra-args "inst.ks=file:/$DOMAIN.ks console=ttyS0,115200n8" \
  --wait -1
