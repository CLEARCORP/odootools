#!/bin/bash

#       mkserver.sh
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

if [[ ! -d $OPENERP_CCORP_DIR ]]; then
    echo "openerp-ccorp-scripts not installed."
    exit 1
fi

#~ Libraries import
. $OPENERP_CCORP_DIR/main-lib/checkRoot.sh
. $OPENERP_CCORP_DIR/main-lib/getDist.sh
. $OPENERP_CCORP_DIR/openerp-scripts/openerp-lib.sh

# Check user is root
checkRoot

# Init log file
INSTALL_LOG_PATH=/var/log/openerp
INSTALL_LOG_FILE=$INSTALL_LOG_PATH/install.log

if [[ ! -f $INSTALL_LOG_FILE ]]; then
    mkdir -p $INSTALL_LOG_PATH
    touch $INSTALL_LOG_FILE
fi

function log {
    echo "$(date): $1" >> $INSTALL_LOG_FILE
}
function log_echo {
    echo $1
    log "$1"
}
log ""

# Set distribution
dist=""
getDist dist
log_echo "Distribution: $dist"
log_echo ""

openerp_get_dist

# Print title
log_echo "OpenERP make server script"
log_echo "--------------------------"
log_echo ""

# Source installation variables
installed_5_0=0
installed_6_0=0
installed_6_1=0
installed_trunk=0
installed_count=0
installed_branch=""

if [ -d /etc/openerp/5.0 ]; then
    installed_5_0=1
    installed_count=$installed_count+1
    installed_branch="5.0"
fi
if [ -d /etc/openerp/6.0 ]; then
    installed_6_0=1
    installed_count=$installed_count+1
    installed_branch="6.0"
fi
if [ -d /etc/openerp/6.1 ]; then
    installed_6_1=1
    installed_count=$installed_count+1
    installed_branch="6.1"
fi
if [ -d /etc/openerp/trunk ]; then
    installed_trunk=1
    installed_count=$installed_count+1
    installed_branch="trunk"
fi

if [[ $installed_count -eq 0 ]]; then
    log_echo "No OpenERP installed."
    exit 1
elif [[ $installed_count -eq 1 ]]; then
    branch=$installed_branch
else
    branch=""
    while [[ ! $branch =~ ^5\.0|6\.0|6\.1|trunk$ ]]; do
        read -p "You have installed several versions, choose the version for this server (5.0 / 6.0 / _6.1_ / trunk)? " branch
        if [[ $branch == "" ]]; then
            branch="6.1"
        fi
        log_echo ""
    done
fi

log_echo "This server will use $branch branch."

if [[ $branch = "5.0" ]]; then
    branch="5.0"
elif [[ $branch = "6.0" ]]; then
    branch="6.0"
elif [[ $branch = "6.1" ]]; then
    branch="6.1"
else
    branch="trunk"
fi
log_echo ""

. /etc/openerp/$branch/install.cfg

name=""
while [[ $name == "" ]]; do
    read -p "Enter the OpenERP server name: " name
    if [[ $name == "" ]]; then
        log_echo "The name cannot be blank."
    fi
done

#~ Set the openerp port
port=""
test="^[0-9]{2}$"
mkdir -p /etc/openerp/ports
while [[ $port == "" ]]; do
    read -p "Enter the OpenERP server port (2 digits only): " port
    if [[ ! $port =~ $test ]]; then
        log_echo "The port has to contain exactly 2 digits."
        port=""
    elif ls /etc/openerp/ports/${port}_* > /dev/null 2>&1; then
        tmp=$(ls /etc/openerp/ports/${port}_* | xargs -n1 basename)
        log_echo "The port $port is already in use by the server ${tmp:3} (/etc/openerp/ports)."
        port=""
    fi
done
touch /etc/openerp/ports/${port}_${name}
log_echo "Selected port is: $port"

#~ Start the server now
while [[ ! $start_now =~ ^[YyNn]$ ]]; do
        read -p "Would you like to start the server now (Y/n)? " -n 1 start_now
        if [[ $start_now == "" ]]; then
                start_now="y"
        fi
        log_echo ""
done

#~ Start the server on boot
while [[ ! $start_boot =~ ^[YyNn]$ ]]; do
        read -p "Would you like to start the server on boot (Y/n)? " -n 1 start_boot
        if [[ $start_boot == "" ]]; then
                start_boot="y"
        fi
        log_echo ""
done

#~ Set the openerp admin password
admin_passwd=""
while [[ $admin_passwd == "" ]]; do
    read -p "Enter the OpenERP administrator password: " admin_passwd
    if [[ $admin_passwd == "" ]]; then
        log_echo "The password cannot be empty."
    else
        read -p "Enter the OpenERP administrator password again: " admin_passwd2
        log_echo ""
        if [[ $admin_passwd == $admin_passwd2 ]]; then
            log_echo "OpenERP administrator password set."
        else
            admin_passwd=""
            log_echo "Passwords don't match."
        fi
    fi
    log_echo ""
done

# Add openerp postgres user
adduser --system --home /var/run/openerp/$name --no-create-home --ingroup openerp openerp_$name >> $INSTALL_LOG_FILE
/usr/bin/sudo -u postgres createuser openerp_$name --superuser --createdb --no-createrole >> $INSTALL_LOG_FILE
/usr/bin/sudo -u postgres psql template1 -U postgres -c "alter user openerp_$name with password '$admin_passwd'" >> $INSTALL_LOG_FILE
log_echo ""

log_echo "Making instance..."
cd /srv/openerp/$branch >> $INSTALL_LOG_FILE
mkdir -p instances/$name/addons >> $INSTALL_LOG_FILE
mkdir -p instances/$name/filestore >> $INSTALL_LOG_FILE
ln -s /srv/openerp/$branch/src/openobject-server instances/$name/server >> $INSTALL_LOG_FILE
if [[ $branch == "6.1" ]] || [[ $branch == "trunk" ]]; then
    ln -s /srv/openerp/$branch/src/openerp-web instances/$name/web >> $INSTALL_LOG_FILE
else
    ln -s /srv/openerp/$branch/src/openobject-client-web instances/$name/web >> $INSTALL_LOG_FILE
fi
mkserver_install_addons >> $INSTALL_LOG_FILE


log_echo "Creating openerp-server init script..."
cp -a /etc/openerp/$branch/server/init-$branch-skeleton /etc/init.d/openerp-server-$name >> $INSTALL_LOG_FILE
sed -i "s#\\[NAME\\]#$name#g" /etc/init.d/openerp-server-$name >> $INSTALL_LOG_FILE
sed -i "s#\\[USER\\]#openerp_$name#g" /etc/init.d/openerp-server-$name >> $INSTALL_LOG_FILE
#~ Start server on boot
if [[ $start_boot =~ ^[Yy]$ ]]; then
    log_echo "Creating server rc rules..."
    update-rc.d openerp-server-$name defaults >> $INSTALL_LOG_FILE
    log_echo ""
fi

log_echo "Creating openerp-server bin script..."
cp -a /etc/openerp/$branch/server/bin-skeleton /usr/local/bin/openerp-server-$name
sed -i "s#\\[NAME\\]#$name#g" /usr/local/bin/openerp-server-$name

log_echo "Creating openerp-server configuration file..."
cp -a /etc/openerp/$branch/server/server.conf-$branch-skeleton /etc/openerp/$branch/server/$name.conf
sed -i "s#\\[DB_USER\\]#openerp_$name#g" /etc/openerp/$branch/server/$name.conf >> $INSTALL_LOG_FILE
sed -i "s#\\[NAME\\]#$name#g" /etc/openerp/$branch/server/$name.conf >> $INSTALL_LOG_FILE
sed -i "s#\\[PORT\\]#$port#g" /etc/openerp/$branch/server/$name.conf >> $INSTALL_LOG_FILE
sed -i "s#\\[XMLPORT\\]#20$port#g" /etc/openerp/$branch/server/$name.conf >> $INSTALL_LOG_FILE
sed -i "s#\\[NETPORT\\]#21$port#g" /etc/openerp/$branch/server/$name.conf >> $INSTALL_LOG_FILE
sed -i "s#\\[XMLSPORT\\]#22$port#g" /etc/openerp/$branch/server/$name.conf >> $INSTALL_LOG_FILE
sed -i "s#\\[PYROPORT\\]#24$port#g" /etc/openerp/$branch/server/$name.conf >> $INSTALL_LOG_FILE
sed -i "s#\\[ADMIN_PASSWD\\]#$admin_passwd#g" /etc/openerp/$branch/server/$name.conf >> $INSTALL_LOG_FILE
addons_config=""
mkserver_addons_config
sed -i "s#\\[ADDONS\\]#$addons_config#g" /etc/openerp/$branch/server/$name.conf >> $INSTALL_LOG_FILE


# For OpenERP 6.1+ the XML-RPC secure is not used any more, so don't initiate the certificates
if [[ "$branch" =~ ^5\.0|6\.0$ ]]; then
    log_echo "Creating openerp-server ssl files..."
    cp -a /etc/openerp/ssl/server.cnf-skeleton /etc/openerp/ssl/servers/$name.cnf >> $INSTALL_LOG_FILE
    sed -i "s#\\[NAME\\]#$name#g" /etc/openerp/ssl/servers/$name.cnf >> $INSTALL_LOG_FILE
    cd /etc/openerp/ssl/servers
    openssl req -newkey rsa:1024 -keyout tempkey.pem -keyform PEM -out tempreq.pem -outform PEM -config $name.cnf -passout pass:$admin_passwd
    openssl rsa -passin pass:$admin_passwd < tempkey.pem > server_key.pem
    echo 20$port > /etc/openerp/ssl/serial
    openssl ca -batch -in tempreq.pem -out server_crt.pem -config ../ca.cnf -passin pass:$admin_passwd
    rm -f tempkey.pem && rm -f tempreq.pem
    mv server_crt.pem ${name}_crt.pem
    mv server_key.pem ${name}_key.pem
fi

log_echo "Creating openerp-server log files..."
mkdir -p /var/log/openerp/$name >> $INSTALL_LOG_FILE
touch /var/log/openerp/$name/server.log >> $INSTALL_LOG_FILE

log_echo "Creating openerp-web bin script..."
cp -a /etc/openerp/$branch/web-client/bin-skeleton /usr/local/bin/openerp-web-$name >> $INSTALL_LOG_FILE
sed -i "s#\\[NAME\\]#$name#g" /usr/local/bin/openerp-web-$name >> $INSTALL_LOG_FILE

# For OpenERP 6.1+ the web server is embedded, so no need to initiate or configure the process
if [[ "$branch" =~ ^5\.0|6\.0$ ]]; then
    log_echo "Creating openerp-web init script..."
    cp -a /etc/openerp/$branch/web-client/init-skeleton /etc/init.d/openerp-web-$name >> $INSTALL_LOG_FILE
    sed -i "s#\\[NAME\\]#$name#g" /etc/init.d/openerp-web-$name >> $INSTALL_LOG_FILE
    sed -i "s#\\[USER\\]#openerp_$name#g" /etc/init.d/openerp-web-$name >> $INSTALL_LOG_FILE
    #~ Start web client on boot
    if [[ $start_boot =~ ^[Yy]$ ]]; then
        log_echo "Creating web-client rc rules..."
        update-rc.d openerp-web-$name defaults >> $INSTALL_LOG_FILE
        log_echo ""
    fi

    log_echo "Creating openerp-web configuration file..."
    cp -a /etc/openerp/$branch/web-client/web-client.conf-$branch-skeleton /etc/openerp/$branch/web-client/$name.conf
    sed -i "s#\\[NAME\\]#$name#g" /etc/openerp/$branch/web-client/$name.conf
    sed -i "s#\\[PORT\\]#23$port#g" /etc/openerp/$branch/web-client/$name.conf
    sed -i "s#\\[SERVER_PORT\\]#21$port#g" /etc/openerp/$branch/web-client/$name.conf
    if [[ $server_type == "production" ]]; then
        sed -i "s/#\?[[:space:]]*\(dbbutton\.visible.*\)/dbbutton.visible = False/g" /etc/openerp/$branch/web-client/$name.conf
    else
        sed -i "s/#\?[[:space:]]*\(dbbutton\.visible.*\)/dbbutton.visible = True/g" /etc/openerp/$branch/web-client/$name.conf
    fi

    log_echo "Creating openerp-web log files..."
    touch /var/log/openerp/$name/web-client-access.log
    touch /var/log/openerp/$name/web-client-error.log
fi

#Change log permissions
chown -R openerp_$name:openerp /var/log/openerp/$name
chmod 664 /var/log/openerp/$name/*.log

log_echo "Creating apache rewrite file..."
cp -a /etc/openerp/apache2/ssl-$branch-skeleton /etc/openerp/apache2/rewrites/$name
sed -i "s#\\[NAME\\]#$name#g" /etc/openerp/apache2/rewrites/$name

if [[ "$branch" =~ ^6\.1|trunk$ ]]; then
    #Use OpenERP embedded XML-RPC Werzeug server
    sed -i "s#\\[PORT\\]#20$port#g" /etc/openerp/apache2/rewrites/$name >> $INSTALL_LOG_FILE
else
    #Use OpenERP Web client
    sed -i "s#\\[PORT\\]#23$port#g" /etc/openerp/apache2/rewrites/$name >> $INSTALL_LOG_FILE
fi

service apache2 reload >> $INSTALL_LOG_FILE

log_echo "Creating pid dir..."
mkdir -p /var/run/openerp/$name

#~ Start server now
if [[ $start_now =~ ^[Yy]$ ]]; then
    log_echo "Starting openerp server and web client..."
    service postgresql$postgresql_init start
    service apache2 restart
    service openerp-server-$name start
    #Start OpenERP Web client if not embedded
    if [[ "$branch" =~ ^5\.0|6\.0$ ]]; then service openerp-web-$name start; fi
    log_echo ""
fi

#~ Make developer menus
#if [[ $server_type == "station" ]]; then
#    sudo -E -u $openerp_user ccorp-openerp-mkmenus $branch $name
#fi

#~ Add server to hosts file if station

if [[ $server_type == "station" ]]; then
    echo "127.0.1.1    $name.localhost" >> /etc/hosts
fi

install_change_perms

exit 0
