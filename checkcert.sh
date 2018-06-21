#!/usr/bin/bash
# Kevin Burg - burg.kevin@gmail.com
# Use OpenSSL to check a .csr file
openssl req -in ${1} -noout -text
