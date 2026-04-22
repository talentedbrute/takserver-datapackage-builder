#!/bin/bash

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