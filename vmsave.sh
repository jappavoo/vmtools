#!/bin/bash
#set -x

ARCH=$(uname -i)
DOMAIN=${VMBASEVM:-basevm-$ARCH}
VMSDIR=vms
DISK=${VMSDIR}/${DOMAIN}.qcow2

echo "shutdown down $DOMAIN" > /dev/stderr
virsh shutdown $DOMAIN

echo "dumping xml for $DOMAIN" > /dev/stderr
virsh dumpxml $DOMAIN > ${VMSDIR}/$DOMAIN.xml

# brittle but will do
#echo "attempting to save nvram" > /dev/stderr
#virsh vol-download --sparse --pool nvram basevm-aarch64_VARS.fd --file ${VMSDIR}/${DOMAIN}_VARS.fd

# JA: KLUDGE -- WHAT A PIECE OF @$%@$%@#$
grep $USER ${VMSDIR}/basevm-aarch64.xml | grep -v $(pwd)/${VMSDIR} | while read file
do
    file=${file#*>}
    file=${file%<*}
    if [[ -a ${file} ]]; then
	echo copying: ${file}
	cp -r $file ${VMSDIR}
    fi
done

#echo "copying disk for $DOMAIN" > /dev/stderr
#cp --sparse=always ${DISK} ${SAVEDIR}/

echo "create sparse tar ball"
tar cvfS $DOMAIN.tar ${VMSDIR}
