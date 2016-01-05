#!/bin/bash
# setup.sh

# Description:	This script must be located at the root of the bin dir
#				Its function is call ccorp-openerp-scripts-setup.sh correctly once the
#				user extracts the installer.

#Gets the dir source
SOURCE="${BASH_SOURCE[0]}"
while [ -h "$SOURCE" ] ; do SOURCE="$(readlink "$SOURCE")"; done
DIR="$( cd -P "$( dirname "$SOURCE" )" && pwd )"

#Go to script dir
cd $DIR

cd install-scripts/ccorp-openerp-scripts-install
./ccorp-openerp-scripts-setup.sh
