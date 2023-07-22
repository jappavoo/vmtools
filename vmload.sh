#!/bin/bash
#set -x

ARCH=$(uname -i)
DOMAIN=${VMBASEVM:-basevm-$ARCH}
VMSDIR=${VMSDIR:-vms}
DISK=${VMSDIR}/${DOMAIN}.qcow2
NVRAM=${VMSDIR}/${DOMAIN}_VARS.fd
URLBASE=${VMURLBASE:-http://www.cs.bu.edu/~jappavoo/Resources}


echo "downloading $DOMAIN" > /dev/stderr
if [[ ! -a ${DOMAIN}.tar ]]; then
  wget ${URLBASE}/${DOMAIN}.tar
fi

echo "untaring $DOMAIN" > /dev/stderr
tar xf ${DOMAIN}.tar

echo "rewriting $DOMAIN" > /dev/stderr
mv ${VMSDIR}/${DOMAIN}.xml ${VMSDIR}/${DOMAIN}.xml.orig
sed -e "s%<source file='.*'%<source file='$(pwd)/${DISK}'%" \
    -e "s%<nvram>.*</nvram>%<nvram>$(pwd)/${NVRAM}</nvram>%" < ${VMSDIR}/${DOMAIN}.xml.orig  > ${VMSDIR}/${DOMAIN}.xml

echo "defining $DOMAIN" > /dev/stderr
virsh define --file $VMSDIR/${DOMAIN}.xml
