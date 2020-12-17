python2 -c "import crypt, getpass, pwd; print crypt.crypt(raw_input(), crypt.mksalt(crypt.METHOD_SHA512))"

