# takserver-datapackage-builder
Scripts to help build data packages for TAK Server.

# pre-requisite
The scripts need to use the `uuid` command line tool. You will need to install that using your systems package manager.


# Directions:
1. Place your servers' CA.p12 into each of the template folders
2. Update the secure.pref in each tempalte to use your host and to your server's CA.p12
3. Update the MANIFEST/manifest.xml file in each template to use your servers' CA.p12

# buildDP.sh
You can use this script to build a data package when user's certs exist already or you just need a data package for auto-certificate enrollment

`./buildDP.sh -U <username> -z <name for datapackage zip> -c <certificate file> -i -f`

`-U <username>`: specify the name of the user for this data package.  This is only used to name the zip file and change the display in TAK.  

`-z <name for data package zip>`: specify the name of the output data package zip file

`-c <certificate file>`: specify the full path to the user's certificate file

`-i`: specify if you want an iTAK data package built

`-f`: specify if you want a full ATAK data package built, which will include the user's certificate file.  The default it to build an auto enrollment data package.

### Output
Will be a working data package zip file for either ATAK or iTAK depending on what was specified

# createUserCert.sh
You can use this script to create a new user and data package for that user simultaenously.

`./createUserCert.sh -u <username> -c <name for the certificate file> -i -f`

`-u <username>`: specify the name of the user to be added to the TAK Server 

`-c <name of the certificate file>`: specify the name of the new certificate file to be created

`-i`: specify if you want an iTAK data package built

`-f`: specify if you want a full ATAK data package built, which will include the user's certificate file.  The default it to build an auto enrollment data package.

### Output
The new user will be created along with the specified data package


