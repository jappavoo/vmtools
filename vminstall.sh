total_memory=${VMMEMORY:-$(free -m | awk '/^Mem:/{print $2}')}
ram_allocation=${VMRAM:-$((total_memory * 3 / 4))}
total_cores=${VMCORES:-$(nproc)}
ARCH=$(uname -i)
DOMAIN=${1:-basevm-$ARCH}
VMUSER=${2:-user}
VMPASSWD=${3:-user}
FEDORARELEASE=38

LOCATION=${LOCATION:-"https://download.fedoraproject.org/pub/fedora/linux/releases/FEDORARELEASE/Everything/$(uname -i)/os/"}

if [[ -z $DOMAIN ]]; then
    echo "USAGE: $0 <DOMAIN NAME>"
    exit -1
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
  --ram $ram_allocation \
  --disk path="$(pwd)/disk/$DOMAIN.qcow2,size=200,format=qcow2" \
  --check disk_size=off \
  --vcpus $total_cores \
  --network bridge=virbr0 \
  --graphics none \
  --console pty,target_type=serial \
  --location $LOCATION \
  --initrd-inject="$(pwd)/$DOMAIN.ks" \
  --extra-args "inst.ks=file:/$DOMAIN.ks console=ttyS0,115200n8" \
  --wait -1
