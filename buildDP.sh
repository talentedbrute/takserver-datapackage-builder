#!/bin/bash

USER=
CERTNAME=
CERT=
ITAK=0
FULL=0
usage() { echo "usage: buildDP.sh -U <username> -u <name for data package> -c <certificate file> -i"; exit 1; }

while getopts "fiu:U:c:h" arg; do
	case $arg in
		h)
			usage
			;;
		U)
			USER=$OPTARG
			;;
		u)
			CERTNAME=$OPTARG
			;;
		c)	
			CERT=$OPTARG
			;;
		i)
			ITAK=1
			;;
		f)
			FULL=1
			;;
	esac
done
shift $((OPTIND-1))

if [ -z "${CERTNAME}" ] || [ -z "${CERT}" ] || [ -z "${USER}" ];
then
	usage
fi

CERTFILE=`basename ${CERT}`

if [ "${FULL}" == "0" ]
then

	cp -a template ${CERTNAME}

	sed -i 's/##username##/'"${USER}"'/g' ${CERTNAME}/secure.pref
	sed -i 's/##uuid##/'"`uuid`"'/g' ${CERTNAME}/MANIFEST/manifest.xml
else
	cp -a template-full ${CERTNAME}

	cp files/${CERTFILE} ${CERTNAME}

	sed -i 's/##usercert##/'"${CERTFILE}"'/g' ${CERTNAME}/secure.pref
	sed -i 's/##username##/'"${USER}"'/g' ${CERTNAME}/secure.pref
	sed -i 's/##username##/'"${CERTNAME}"'/g' ${CERTNAME}/MANIFEST/manifest.xml
	sed -i 's/##usercert##/'"${CERTFILE}"'/g' ${CERTNAME}/MANIFEST/manifest.xml
	sed -i 's/##uuid##/'"`uuid`"'/g' ${CERTNAME}/MANIFEST/manifest.xml
fi

SUFFIX=
if [ "${ITAK}" == 0 ];
then
	zip -r ${CERTNAME}.zip ${CERTNAME}
else
	SUFFIX=_iTAK
	cd ${CERTNAME}
	mv secure.pref config.pref
	zip ../${CERTNAME}${SUFFIX}.zip config.pref *.p12
	cd ..
fi

rm -rf ${CERTNAME}

echo "Copying ${CERTNAME}${SUFFIX}.zip to s3://ts-certs..."
/usr/local/bin/aws s3 cp ${CERTNAME}${SUFFIX}.zip s3://ts-certs
