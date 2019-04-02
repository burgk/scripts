#!/usr/bin/bash
# Purpose: Use OpenSSL to check a .csr file
# Date: 20181024
# Kevin Burg - burg.kevin@gmail.com

openssl req -in ${1} -noout -text
