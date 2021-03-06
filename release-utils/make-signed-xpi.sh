#!/bin/sh
set -e
cd "`dirname $0`"

APP_NAME=privacybadger
# Auto-generated XPI name from 'cfx xpi'
PRE_XPI_NAME="$APP_NAME.xpi"
LATEST_SDK_VERSION=1.17

if ! type cfx > /dev/null; then
  echo "Please activate the Firefox Addon SDK before running this script."
  exit 1
fi

if ! cfx --version | grep -q "$LATEST_SDK_VERSION"; then
    echo "Please use the latest stable SDK version or edit this script to the current version."
    exit 1
fi

if [ $# -ne 1 ] ; then
  echo "Usage: $0 <version to release>"
  exit 1
fi

# Final XPI name
XPI_NAME="privacy-badger-$1.xpi"

rm -rf xpi/
mkdir xpi

# Build the unsigned XPI and unzip it
echo "Running cfx xpi"
cfx xpi
unzip -q -d xpi "$PRE_XPI_NAME"
rm "$PRE_XPI_NAME"

# Customize install.rdf with our updateKey and URL
sed -i ':a;N;$!ba;s@</Description>\n</RDF>@\n@g' xpi/install.rdf
cat install-template.rdf >> xpi/install.rdf

# Rezip the XPI
rm -f "$XPI_NAME"
cd xpi
zip -q -X -9r "$XPI_NAME" .

echo "Created $XPI_NAME in $(pwd)"

# Move it to the canonical location
mkdir -p ../pkg
mv "$XPI_NAME" ../pkg/
