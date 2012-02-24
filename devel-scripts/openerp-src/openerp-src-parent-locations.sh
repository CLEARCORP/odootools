#!/bin/bash

if [[ $OPENERP_REPO_BASE == "" ]]; then
    OPENERP_REPO_BASE="~/Development/openerp"
fi

echo "parent_location = lp:~clearcorp/openobject-server/5.0-ccorp" > $BASE_DIR/5.0/openobject-server/.bzr/branch/branch.conf
echo "parent_location = lp:~clearcorp/openobject-server/6.0-ccorp" > $BASE_DIR/6.0/openobject-server/.bzr/branch/branch.conf
echo "parent_location = lp:~clearcorp/openobject-server/6.1-ccorp" > $BASE_DIR/6.1/openobject-server/.bzr/branch/branch.conf
echo "parent_location = lp:~clearcorp/openobject-server/trunk-ccorp" > $BASE_DIR/trunk/openobject-server/.bzr/branch/branch.conf

echo "parent_location = lp:~clearcorp/openobject-addons/5.0-ccorp" > $BASE_DIR/5.0/openobject-addons/.bzr/branch/branch.conf
echo "parent_location = lp:~clearcorp/openobject-addons/6.0-ccorp" > $BASE_DIR/6.0/openobject-addons/.bzr/branch/branch.conf
echo "parent_location = lp:~clearcorp/openobject-addons/6.1-ccorp" > $BASE_DIR/6.1/openobject-addons/.bzr/branch/branch.conf
echo "parent_location = lp:~clearcorp/openobject-addons/trunk-ccorp" > $BASE_DIR/trunk/openobject-addons/.bzr/branch/branch.conf

echo "parent_location = lp:~clearcorp/openobject-addons/extra-5.0-ccorp" > $BASE_DIR/5.0/openobject-addons-extra/.bzr/branch/branch.conf
echo "parent_location = lp:~clearcorp/openobject-addons/extra-6.0-ccorp" > $BASE_DIR/6.0/openobject-addons-extra/.bzr/branch/branch.conf
echo "parent_location = lp:~clearcorp/openobject-addons/extra-trunk-ccorp" > $BASE_DIR/trunk/openobject-addons-extra/.bzr/branch/branch.conf

echo "parent_location = lp:~clearcorp/openobject-client/5.0-ccorp" > $BASE_DIR/5.0/openobject-client/.bzr/branch/branch.conf
echo "parent_location = lp:~clearcorp/openobject-client/6.0-ccorp" > $BASE_DIR/6.0/openobject-client/.bzr/branch/branch.conf
echo "parent_location = lp:~clearcorp/openobject-client/6.1-ccorp" > $BASE_DIR/6.1/openobject-client/.bzr/branch/branch.conf
echo "parent_location = lp:~clearcorp/openobject-client/trunk-ccorp" > $BASE_DIR/trunk/openobject-client/.bzr/branch/branch.conf

echo "parent_location = lp:~clearcorp/openobject-client-web/5.0-ccorp" > $BASE_DIR/5.0/openobject-client-web/.bzr/branch/branch.conf
echo "parent_location = lp:~clearcorp/openobject-client-web/6.0-ccorp" > $BASE_DIR/6.0/openobject-client-web/.bzr/branch/branch.conf
echo "parent_location = lp:~clearcorp/openerp-web/6.1-ccorp" > $BASE_DIR/6.1/openerp-web/.bzr/branch/branch.conf
echo "parent_location = lp:~clearcorp/openerp-web/trunk-ccorp" > $BASE_DIR/trunk/openerp-web/.bzr/branch/branch.conf
