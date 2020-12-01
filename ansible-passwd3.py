python3 -c "import crypt, getpass, pwd; print(crypt.crypt(input(), crypt.mksalt(crypt.METHOD_SHA512)))"

