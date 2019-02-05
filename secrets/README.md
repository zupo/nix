# Secrets

It's lovely that NixOs allows us to store secrets in separate files that do not get pushed to git and hence stay safe, on the device only. What is less great is that when you are looking at other people's `.nix` files and you see they are referencing a secrets file you are not always sure what format the secrets file needs to be in.

Everywhere I am using secrets files, I put an example into this folder, for your convenience. You're welcome :)


## Newlines

The secrets files often need to terminate without a trailing newline. Use `echo -n "foo" > /my/secrets_file` to achieve this. 
