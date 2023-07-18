#!/bin/bash
#set -x

ARCH=$(uname -i)
DOMAIN=${VMBASEVM:-basevm-$ARCH}
DISKDIR=disk
DISK=${DISKDIR}/${DOMAIN}.qcow2
#SAVEDIR=save

#mkdir $SAVEDIR

echo "shutdown down $DOMAIN" > /dev/stderr
virsh shutdown $DOMAIN

echo "dumping xml for $DOMAIN" > /dev/stderr
virsh dumpxml $DOMAIN > ${DISKDIR}/$DOMAIN.xml

#echo "copying disk for $DOMAIN" > /dev/stderr
#cp --sparse=always ${DISK} ${SAVEDIR}/

echo "create sparse tar ball"
tar cvfS $DOMAIN.tar ${DISKDIR}
