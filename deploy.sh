#!/bin/bash

if [ ! -z "$TRAVIS_TAG" ] &&
    [ "$TRAVIS_PULL_REQUEST" == "false" ]; then
  echo "This will deploy!"

  ./build.sh

  cd dist

  # Copy libwinpthread-1.dll (user must rename the dll for their system to libwinpthread-1.dll)
  cp ../.travis/win32/libwinpthread-1.dll libwinpthread-1.win32.dll
  cp ../.travis/win64/libwinpthread-1.dll libwinpthread-1.win64.dll

  # Calculate SHA512 hashes
  sha512sum * > sha512_checksums.txt

  # Load signing key
  cp ../.travis/sign.key.gpg /tmp
  gpg --yes --batch --passphrase=$GPG_PASS /tmp/sign.key.gpg
  gpg --allow-secret-key-import --import /tmp/sign.key.gpg
  rm /tmp/sign.key.gpg

  # Sign hash file
  gpg --clearsign --digest-algo SHA512 --armor --output sha512_checksums.asc --passphrase=$GPG_PASS --default-key $GPG_KEYID sha512_checksums.txt

  rm sha512_checksums.txt

  # Upload to GitHub Release page
  ghr --username OpenBazaar -t $GITHUB_TOKEN --replace --prerelease --debug $TRAVIS_TAG .
else
  echo "This will not deploy!"
fi
