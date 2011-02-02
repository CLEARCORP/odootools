#       openerp-update.sh
#       
#       Copyright 2010 ClearCorp S.A. <info@clearcorp.co.cr>
#       
#       This program is free software; you can redistribute it and/or modify
#       it under the terms of the GNU General Public License as published by
#       the Free Software Foundation; either version 2 of the License, or
#       (at your option) any later version.
#       
#       This program is distributed in the hope that it will be useful,
#       but WITHOUT ANY WARRANTY; without even the implied warranty of
#       MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#       GNU General Public License for more details.
#       
#       You should have received a copy of the GNU General Public License
#       along with this program; if not, write to the Free Software
#       Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston,
#       MA 02110-1301, USA.
#!/bin/bash

if [[ ! -d $LIBBASH_CCORP_DIR ]]; then
	echo "libbash-ccorp not installed."
	exit 1
fi

#~ Libraries import
. $LIBBASH_CCORP_DIR/main-lib/checkRoot.sh
. $LIBBASH_CCORP_DIR/main-lib/getDist.sh
. $LIBBASH_CCORP_DIR/install-scripts/openerp-install/openerp-lib.sh

# Check user is root
checkRoot

# Init log file
INSTALL_LOG_PATH=/var/log/openerp
INSTALL_LOG_FILE=$INSTALL_LOG_PATH/update.log

if [[ ! -f $INSTALL_LOG_FILE ]]; then
	mkdir -p $INSTALL_LOG_PATH
	touch $INSTALL_LOG_FILE
fi

log ""

# Print title
log_echo "OpenERP update script"
log_echo "---------------------"
log_echo ""

# Set distribution
dist=""
getDist dist
log_echo "Distribution: $dist"
log_echo ""

# Sets vars corresponding to the distro
if [[ $dist == "lucid" ]]; then
	# Ubuntu 10.04, python 2.6
	posgresql_rel=8.4
	python_rel=python2.6
	ubuntu_rel=10.04
	base_path=/usr/local
	install_path=$base_path/lib/$python_rel/dist-packages/openerp-server-skeleton
	install_path_web=$base_path/lib/$python_rel/dist-packages
	addons_path=$install_path/addons/
	sources_path=$base_path/src/openerp
elif [[ $dist == "maverick" ]]; then
	# Ubuntu 10.10, python 2.6
	posgresql_rel=8.4
	python_rel=python2.6
	ubuntu_rel=10.10
	base_path=/usr/local
	install_path=$base_path/lib/$python_rel/dist-packages/openerp-server-skeleton
	install_path_web=$base_path/lib/$python_rel/dist-packages
	addons_path=$install_path/addons/
	sources_path=$base_path/src/openerp
else
	# Only Lucid supported for now
	log_echo "ERROR: This program must be executed on Ubuntu Lucid 10.04 (Desktop or Server)"
	exit 1
fi

# Check system values
if [[ ! check_system_values ]]; then
	exit 1
fi


# Initial questions
####################

# Source installation variables
if [ -d /etc/openerp/5.0 && ! -d /etc/openerp/6.0 ]; then
	branch=5.0
elif [ ! -d /etc/openerp/5.0 && -d /etc/openerp/6.0 ]; then
	branch=6.0
else
	branch=""
	while [[ ! $branch =~ ^[56]$ ]]; do
		read -p "You have installed versions 5 and 6, choose the version to update (5/_6_): " branch
		if [[ $branch == "" ]]; then
			branch="6"
		fi
		log_echo ""
	done
fi

if [[ $branch =~ ^[5]$ ]]; then
	log_echo "This server will use 5.0 branch."
	branch="5.0"
else
	log_echo "This server will use 6.0 branch."
	branch="6.0"
fi

. /etc/openerp/$branch/install.cfg

#Preparing update
#----------------
log_echo "Preparing update"
log_echo "----------------"
# Updating user
add_openerp_user
# Update the system.
update_system
# Updating the required python libraries for openerp-server.
install_python_lib
# Updating bazaar.
install_bzr
# Updating postgresql
install_postgresql

# Downloading OpenERP
#--------------------
log_echo "Downloading OpenERP"
log_echo "-------------------"
log_echo ""
download_openerp


# Updating OpenERP
#################

log_echo "Updating OpenERP"
log_echo "----------------"
log_echo ""

#~ Make skeleton installation
if [ -e $install_path ]; then
	tar cvfz $sources_path/openerp-server-skeleton-backup-`date +%Y-%m-%d_%H-%M-%S`.tgz $install_path >> $INSTALL_LOG_FILE
	rm -r $install_path >> $INSTALL_LOG_FILE
fi

install_openerp

# Updating OpenERP Web Client
#----------------------------
log_echo "Updating OpenERP Web Client"
log_echo "---------------------------"
log_echo ""
download_openerp_web
install_openerp_web_client

# Add log file rotation
add_log_rotation

exit 0
