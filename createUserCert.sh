#!/bin/bash

USER=
CERTNAME=
ITAK=
FULL=

usage() { echo "usage: buildDP.sh -u <username> -c <name for certificate file> [ -i (iTAK) | -f (FULL) ]"; exit 1; }

while getopts "ifu:c:h" arg; do
        case $arg in
                h)
                        usage
                        ;;
                u)
                        USER=$OPTARG
                        ;;
                c)
                        CERTNAME=$OPTARG
                        ;;
                i)
                        ITAK="-i"
                        ;;
                f)
                        FULL="-f"
                        ;;
        esac
done
shift $((OPTIND-1))

if [ -z "${USER}" ] || [ -z "${CERTNAME}" ];
then
        usage
fi

cd /opt/tak/certs

. cert-env.sh

./makeCert.sh client ${CERTNAME}

java -jar /opt/tak/utils/UserManager.jar usermod -c /opt/tak/certs/files/${CERTNAME}.pem ${USER}

if [ ! -f /opt/tak/certs/files/${CERTNAME}.p12 ]; 
then
	echo "Cert file (${CERTFILE}.p12) does not exists!"
	exit 1
fi

./buildDP.sh -U ${USER} -z ${CERTNAME} -c /opt/tak/certs/files/${CERTNAME}.p12 ${ITAK} ${FULL}

