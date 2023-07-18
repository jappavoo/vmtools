#!/bin/bash
#set -x

ARCH=$(uname -i)
DOMAIN=${VMBASEVM:-basevm-$ARCH}
DISKDIR=${VMDISKDIR:-disk}
DISK=${DISKDIR}/${DOMAIN}.qcow2
NVRAM=${DISKDIR}/${DOMAIN}_VARS.fd
URLBASE=${VMURLBASE:-http://www.cs.bu.edu/~jappavoo/Resources}


echo "downloading $DOMAIN" > /dev/stderr
if [[ ! -a ${DOMAIN}.tar ]]; then
  wget ${URLBASE}/${DOMAIN}.tar
fi

echo "untaring $DOMAIN" > /dev/stderr
tar xf ${DOMAIN}.tar

echo "rewriting $DOMAIN" > /dev/stderr
mv ${DISKDIR}/${DOMAIN}.xml ${DISKDIR}/${DOMAIN}.xml.orig
sed -e "s%<source file='.*'%<source file='$(pwd)/${DISK}'%" \
    -e "s%<nvram>.*</nvram>%<nvram>$(pwd)/${NVRAM}</nvram>%" < ${DISKDIR}/${DOMAIN}.xml.orig  > ${DISKDIR}/${DOMAIN}.xml

echo "defining $DOMAIN" > /dev/stderr
virsh define --file disk/${DOMAIN}.xml
