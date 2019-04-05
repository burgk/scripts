#!/usr/bin/bash
#
#   Author: Finnbarr P. Murphy
#     Date: December 2016
#  License: BSD
#  
#  Purpose: Configure OpenLDAP server on RHEL 7.2 or later
#           Two users added - ldapuser1, ldapuser2
#
 
# modify as necessary
HOSTNAME="server.example.com"
HOSTS=/etc/hosts
PACKAGES="openldap-clients openldap-servers"
PASSWORD=P@ssw0rd
DELETE_ONLY=0
SUFFIX="dc=example,dc=com"
LDIF="/var/tmp/temp.ldif"
 
 
if (( $EUID != 0 )); then
    echo "ERROR: You need root privileges to run this script"
    exit 1
fi
 
if (( $# >= 1 )); then
   if [[ "$1" = "-h" || "$1" = "--help" ]]; then
      echo "Usage: $(basename $0) [-d]"
      exit 0
   fi
   if [[ "$1" = "-d" ]]; then
       DELETE_ONLY=1 
   fi
fi
 
if yum list installed openldap-servers  > /dev/null 2>&1
then
    systemctl -q is-active slapd && {
        systemctl stop slapd 
        systemctl -q disable slapd
    }
    echo -n "Removing existing LDAP server files ..... "
    yum remove -y -q -e0 $PACKAGES 
    rm -rf /etc/openldap/slapd.d/
    rm -rf /var/lib/ldap/*
    id -u ldapuser1 > /dev/null && userdel -frZ  ldapuser1 2>/dev/null
    id -u ldapuser2 > /dev/null && userdel -frZ  ldapuser2 2>/dev/null
    echo "Done"
fi
 
if [[ "$DELETE_ONLY" = "1" ]]; then
    exit 0
fi
 
echo -n "Installing $PACKAGES ..... "
yum install -y -q -e0 $PACKAGES 
echo "Done"
 
# Handle hostname issues here
hostnamectl set-hostname $HOSTNAME 
if grep $HOSTNAME $HOSTS  > /dev/null  2>&1
then
    sed -i".bak" '/^#/ ! s/\(^.*'$HOSTNAME'.*\)/\#\ \1/' /etc/hosts
fi
echo "192.168.1.10  $HOSTNAME  server" >> $HOSTS 
echo "Modified hostname and /etc/hosts as needed."
 
# Generate LDAP password from a secret key (Pa$$w0rd()
slappasswd -s $PASSWORD -n > /etc/openldap/passwd
 
# FPM - test passwd file
 
# Generate X.509 certificate good for approx 6 months 
openssl req -new -x509 -nodes -out /etc/openldap/certs/cert.pem \
-keyout /etc/openldap/certs/priv.pem -days 180 \
-subj '/C=US /O=Training /OU=RHCSA RHCE Training /CN=server.example.com' \
> /dev/null 2>&1 
 
cd /etc/openldap/certs
chown ldap:ldap *
chmod 600 priv.pem
cd - >/dev/null
 
cp /usr/share/openldap-servers/DB_CONFIG.example /var/lib/ldap/DB_CONFIG
slaptest > /dev/null  2>&1
chown ldap:ldap /var/lib/ldap/*
 
systemctl -q enable slapd
systemctl start slapd
sleep 10
echo -n "Start LDAP server daemon ..... "
systemctl -q is-active slapd
if (( $? == 0 )); then
    echo "Success"
else
    echo "Failed"
    exit 1
fi
 
 
ldapadd -Y EXTERNAL -H ldapi:/// -D "cn=config" -f /etc/openldap/schema/cosine.ldif > /dev/null  2>&1
 
ldapadd -Y EXTERNAL -H ldapi:/// -D "cn=config" -f /etc/openldap/schema/nis.ldif > /dev/null  2>&1
 
cat > /etc/openldap/changes.ldif << EOF
dn: olcDatabase={2}hdb,cn=config
changetype: modify
replace: olcSuffix
olcSuffix: dc=example,dc=com
 
dn: olcDatabase={2}hdb,cn=config
changetype: modify
replace: olcRootDN
olcRootDN: cn=Manager,dc=example,dc=com
 
dn: olcDatabase={2}hdb,cn=config
changetype: modify
replace: olcRootPW
olcRootPW: $(</etc/openldap/passwd) 
 
dn: cn=config
changetype: modify
replace: olcTLSCertificateFile
olcTLSCertificateFile: /etc/openldap/certs/cert.pem
 
dn: cn=config
changetype: modify
replace: olcTLSCertificateKeyFile
olcTLSCertificateKeyFile: /etc/openldap/certs/priv.pem
 
dn: cn=config
changetype: modify
replace: olcLogLevel
olcLogLevel: -1
 
dn: olcDatabase={1}monitor,cn=config
changetype: modify
replace: olcAccess
olcAccess: {0}to * by dn.base="gidNumber=0+uidNumber=0,cn=peercred,cn=external,cn=auth" read by dn.base="cn=Manager,dc=example,dc=com" read by * none
EOF
 
ldapmodify -Y EXTERNAL -H ldapi:/// -f /etc/openldap/changes.ldif > /dev/null  2>&1
 
 
cat > /etc/openldap/base.ldif << EOF
dn: dc=example,dc=com
dc: example
objectClass: top
objectClass: domain
 
dn: ou=People,dc=example,dc=com
ou: People
objectClass: top
objectClass: organizationalUnit
 
dn: ou=Group,dc=example,dc=com
ou: Group
objectClass: top
objectClass: organizationalUnit
EOF
 
ldapadd -x -w $PASSWORD -D cn=Manager,$SUFFIX -f /etc/openldap/base.ldif > /dev/null 2>&1
 
# Create two OpenLDAP test users
[ -d /home/ldap ] || mkdir /home/ldap
useradd -d /home/ldap/ldapuser1 ldapuser1  > /dev/null  2>&1
echo "ldapuser1:$PASSWORD" | chpasswd
useradd -d /home/ldap/ldapuser2 ldapuser2 > /dev/null  2>&1
echo "ldapuser2:$PASSWORD" | chpasswd
 
# Migrate existing local users with UID > 1000
GROUP_IDS=()
echo -n > $LDIF
grep "x:10[0-9][0-9]:" /etc/passwd | 
( while IFS=':' read U_NAME U_X U_UID U_GID U_GECOS U_DIR U_SHELL
do
    # U_GECOS="$(echo "$U_GECOS" | cut -d' ' -f1,2)"
    [ ! "$U_GECOS" ] && U_GECOS="$U_NAME"
 
    S_ENT=$(grep "${U_NAME}:" /etc/shadow)
 
    S_AGING=$(passwd -S "$U_NAME")
    S_AGING_ARRAY=($S_AGING)
 
    # build up array of group IDs
    [ ! "$(echo "${GROUP_IDS[@]}" | grep "$U_GID")" ] && GROUP_IDS=("${GROUP_IDS[@]}" "$U_GID")
 
    echo "dn: uid=$U_NAME,ou=People,$SUFFIX" >> $LDIF
    echo "objectClass: account" >> $LDIF
    echo "objectClass: posixAccount" >> $LDIF
    echo "objectClass: shadowAccount" >> $LDIF
    echo "objectClass: top" >> $LDIF
    echo "cn: $(echo "$U_GECOS" | awk -F',' '{print $1}')" >> $LDIF
    echo "uidNumber: $U_UID" >> $LDIF
    echo "gidNumber: $U_GID" >> $LDIF
    echo "userPassword: {crypt}$(echo "$S_ENT" | cut -d':' -f2)" >> $LDIF
    echo "gecos: $U_GECOS" >> $LDIF
    echo "loginShell: $U_SHELL"  >> $LDIF
    echo "homeDirectory: $U_DIR" >> $LDIF
    echo "shadowExpire: ${S_AGING_ARRAY[6]}" >> $LDIF
    echo "shadowWarning: ${S_AGING_ARRAY[5]}" >> $LDIF
    echo "shadowMin: ${S_AGING_ARRAY[3]}" >> $LDIF
    echo "shadowMax: ${S_AGING_ARRAY[4]}" >> $LDIF
    echo >> $LDIF
done
 
for G_GID in "${GROUP_IDS[@]}"
do
    L_CN="$(grep ":$G_GID:" /etc/group | cut -d':' -f1)"
    echo "dn: cn=$L_CN,ou=Group,$SUFFIX" >> $LDIF
    echo "objectClass: posixGroup" >> $LDIF
    echo "objectClass: top" >> $LDIF
    echo "cn: $L_CN" >> $LDIF
    echo "gidNumber: $G_GID" >> $LDIF
    echo >> $LDIF
done
)
 
ldapadd -x -w $PASSWORD -D cn=Manager,$SUFFIX -f $LDIF > /dev/null
rm -rf $LDIF
 
echo -n "Testing operation of LDAP server ..... "
ldapsearch -x  -b dc=example,dc=com cn=ldapuser01 > /dev/null
if (( $? == 0 )); then
    echo "Success"
else
    echo "Failed"
    exit 1
fi
 
exit 0
