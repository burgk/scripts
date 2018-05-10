#!/usr/bin/bash
# Use OpenSSL to check a .csr file
openssl req -in ${1} -noout -text
