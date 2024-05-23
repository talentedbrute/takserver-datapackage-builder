#!/bin/bash

USER=
ZIPNAME=
CERT=
ITAK=0
FULL=0
usage() { echo "usage: buildDP.sh -U <username> -z <name for data package> -c <certificate file> -i"; exit 1; }

while getopts "fiu:U:c:h" arg; do
	case $arg in
		h)
			usage
			;;
		U)
			USER=$OPTARG
			;;
		z)
			ZIPNAME=$OPTARG
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

if [ -z "${ZIPNAME}" ] || [ -z "${CERT}" ] || [ -z "${USER}" ];
then
	usage
fi

CERTFILE=`basename ${CERT}`

if [ "${FULL}" == "0" ]
then

	cp -a template ${ZIPNAME}

	sed -i 's/##username##/'"${USER}"'/g' ${ZIPNAME}/secure.pref
	sed -i 's/##uuid##/'"`uuid`"'/g' ${ZIPNAME}/MANIFEST/manifest.xml
else
	cp -a template-full ${ZIPNAME}

	cp files/${CERTFILE} ${ZIPNAME}

	sed -i 's/##usercert##/'"${CERTFILE}"'/g' ${ZIPNAME}/secure.pref
	sed -i 's/##username##/'"${USER}"'/g' ${ZIPNAME}/secure.pref
	sed -i 's/##username##/'"${USER}"'/g' ${ZIPNAME}/MANIFEST/manifest.xml
	sed -i 's/##usercert##/'"${CERTFILE}"'/g' ${ZIPNAME}/MANIFEST/manifest.xml
	sed -i 's/##uuid##/'"`uuid`"'/g' ${ZIPNAME}/MANIFEST/manifest.xml
fi

SUFFIX=
if [ "${ITAK}" == 0 ];
then
	zip -r ${ZIPNAME}.zip ${ZIPNAME}
else
	SUFFIX=_iTAK
	cd ${ZIPNAME}
	mv secure.pref config.pref
	zip ../${ZIPNAME}${SUFFIX}.zip config.pref *.p12
	cd ..
fi

rm -rf ${ZIPNAME}

