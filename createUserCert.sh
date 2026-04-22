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

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
USER=""
CERTNAME=""
ITAK_FLAG=""
FULL_FLAG=""

usage() {
    echo "Usage: createUserCert.sh [options]"
    echo ""
    echo "Options:"
    echo "  -h          Show this help message and exit."
    echo "  -u <user>   Specify the username."
    echo "  -c <name>   Name for the certificate file."
    echo "  -i          Include iTAK configuration (optional)."
    echo "  -f          Create a full data package (optional)."
    exit 1
}

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
            ITAK_FLAG="-i"
            ;;
        f)
            FULL_FLAG="-f"
            ;;
        *)
            usage
            ;;
    esac
done
shift $((OPTIND-1))

if [[ -z "${USER}" || -z "${CERTNAME}" ]]; then
    usage
fi

# Change to the certificates directory
cd /opt/tak/certs || { echo "Failed to change to /opt/tak/certs"; exit 1; }

# Generate the certificate
./makeCert.sh client "$CERTNAME"

# Modify user with new certificate
java -jar /opt/tak/utils/UserManager.jar usermod -c "/opt/tak/certs/files/${CERTNAME}.pem" "${USER}"

# Check if P12 file exists
if [[ ! -f "/opt/tak/certs/files/${CERTNAME}.p12" ]]; then
    echo "Cert file (${CERTNAME}.p12) does not exist!"
    exit 1
fi

# Change back to script directory
cd "$SCRIPT_DIR" || { echo "Failed to change to $SCRIPT_DIR"; exit 1; }

# Call buildDP.sh with appropriate flags
./buildDP.sh -U "${USER}" -z "${CERTNAME}" -c "/opt/tak/certs/files/${CERTNAME}.p12" ${ITAK_FLAG} ${FULL_FLAG}