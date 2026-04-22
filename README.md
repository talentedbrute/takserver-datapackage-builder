# takserver-datapackage-builder

Scripts to help build data packages for TAK Server.

## Prerequisites

The scripts require the `uuid` command-line tool. You can install it using your system's package manager:
- On Debian/Ubuntu: `sudo apt-get install uuid-runtime`
- On CentOS/RHEL: `sudo yum install uuid`

## Directions:

1. Place your servers' CA.p12 file into each of the template folders.
2. Update the `secure.pref` in each template to use your host and server's CA.p12.
3. Update the `MANIFEST/manifest.xml` file in each template to reference your server's CA.p12.

## Scripts

### buildDP.sh

You can use this script to build a data package when user certificates exist already or you just need a data package for auto-certificate enrollment.

**Usage:**

```bash
./buildDP.sh -U <username> -z <name for datapackage zip> -c <certificate file> [-i] [-f]
```

- `-h`: Show this help message and exit.
- `-U <username>`: Specify the name of the user for this data package. This is used to name the zip file and change the display in TAK.
- `-z <name for datapackage zip>`: Specify the name of the output data package zip file.
- `-c <certificate file>`: Specify the full path to the user's certificate file.
- `-i`: Include iTAK configuration (optional).
- `-f`: Create a full ATAK data package, which will include the user's certificate file. The default is to build an auto-enrollment data package.

**Example Usage:**

```bash
./buildDP.sh -U john.doe -z john-doe-package.zip -c /path/to/john.doe-cert.p12 -f
```

### createUserCert.sh

You can use this script to create a new user and build the corresponding data package simultaneously.

**Usage:**

```bash
./createUserCert.sh -u <username> -c <name for certificate file> [-i] [-f]
```

- `-h`: Show this help message and exit.
- `-u <username>`: Specify the name of the user to be added to the TAK Server.
- `-c <name for certificate file>`: Specify the name of the new certificate file to be created.
- `-i`: Include iTAK configuration (optional).
- `-f`: Create a full ATAK data package, which will include the user's certificate file. The default is to build an auto-enrollment data package.

**Example Usage:**

```bash
./createUserCert.sh -u jane.doe -c jane-doe-cert -i -f
```

### Output

- **buildDP.sh**: A working data package zip file for either ATAK or iTAK, depending on the specified flags.
- **createUserCert.sh**: The new user will be created along with the specified data package.

## Additional Notes

Ensure that the paths and filenames used in the scripts match your environment. Adjust the templates as necessary to reflect your specific setup.

## License

This project is licensed under the MIT License.  See [LICENSE](LICENSE) for more details.