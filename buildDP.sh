#!/bin/bash

# MIT License

# Copyright (c) 2026 Adeptus Cyber Solutions, LLC

# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:

# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.

# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

USER=""
ZIPNAME=""
CERT=""
ITAK=0
FULL=0

usage() {
    local exit_code=${1:-0}
    echo "Usage: buildDP.sh [options]"
    echo ""
    echo "Options:"
    echo "  -h          Show this help message and exit."
    echo "  -U <user>   Specify the username."
    echo "  -z <name>   Name for the data package zip file."
    echo "  -c <cert>   Path to the certificate file."
    echo "  -i          Include iTAK configuration (optional)."
    echo "  -f          Create a full data package (optional)."
    exit "$exit_code"
}

while getopts "fiz:U:c:h" arg; do
	case $arg in
		h)
			usage 0
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

if [[ -z "${ZIPNAME}" || -z "${CERT}" || -z "${USER}" ]]; then
	usage 1
fi

CERTFILE=$(basename "${CERT}")

if [[ ${FULL} == 0 ]]; then
	cp -a template "${ZIPNAME}"
	sed -i 's/##username##/'"${USER}"'/g' "${ZIPNAME}/secure.pref"
	sed -i 's/##uuid##/'"$(uuid)"'/g' "${ZIPNAME}/MANIFEST/manifest.xml"
else
	cp -a template-full "${ZIPNAME}"
	cp "/opt/tak/certs/files/${CERTFILE}" "${ZIPNAME}"
	sed -i 's/##usercert##/'"${CERTFILE}"'/g' "${ZIPNAME}/secure.pref"
	sed -i 's/##username##/'"${USER}"'/g' "${ZIPNAME}/secure.pref"
	sed -i 's/##username##/'"${USER}"'/g' "${ZIPNAME}/MANIFEST/manifest.xml"
	sed -i 's/##usercert##/'"${CERTFILE}"'/g' "${ZIPNAME}/MANIFEST/manifest.xml"
	sed -i 's/##uuid##/'"$(uuid)"'/g' "${ZIPNAME}/MANIFEST/manifest.xml"
fi

SUFFIX=""
if [[ ${ITAK} == 0 ]]; then
	zip -r "${ZIPNAME}.zip" "${ZIPNAME}"
else
	SUFFIX="_iTAK"
	cd "${ZIPNAME}" || exit
	mv secure.pref config.pref
	zip "../${ZIPNAME}${SUFFIX}.zip" config.pref *.p12
	cd ..
fi

rm -rf "${ZIPNAME}"