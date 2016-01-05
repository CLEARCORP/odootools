#!/bin/bash

if [[ $OPENERP_REPO_BASE == "" ]]; then
    OPENERP_REPO_BASE=~/Development/openerp
fi

OPENERP_REPO_BASE=$(readlink -m $OPENERP_REPO_BASE)

function update_project {
	# $1: Project name
	# $2: Version
	# $3: Original branch
	# $4: Destination branch
    echo ""
    echo ""
	echo "UPDATE $1 ($4) v$2"
    echo "--------------------------------------------------------------"
    echo ""
	
	ORI_DIR=$OPENERP_REPO_BASE/$1/main/$3
	DES_DIR=$OPENERP_REPO_BASE/openerp-src/src/$2/$4
	
    echo "Updating branch $2/$4"
    echo "cd $DES_DIR"
	cd $DES_DIR
    echo "bzr pull $ORI_DIR"
	bzr pull $ORI_DIR
    echo ""
}

function compress_project {
	# $1: Version
	# $2: Destination branch
	echo ""
	echo ""
	echo "COMPRESS $1/$2"
	
	cd $OPENERP_REPO_BASE/openerp-src/src
	tar czf $OPENERP_REPO_BASE/openerp-src/bin/$1/$2.tmp.tgz $1/$2/
	if [[ $? != 0 ]]; then
	    echo "tar exited with error code $?, skipping the file"
	else
	    echo "tar OK, moving the file"
	    mv $OPENERP_REPO_BASE/openerp-src/bin/$1/$2.tmp.tgz $OPENERP_REPO_BASE/openerp-src/bin/$1/$2.tgz
	fi
}

function update_repo {
	# $1: 
	
	REPO_DIR=$OPENERP_REPO_BASE/openerp-src/src
	
    echo ""
    echo ""
    echo "UPDATE $REPO_DIR/openerp"
    echo "--------------------------------------------------------------"
    echo ""
    echo "Updating branch trunk/openobject-server"
    cd $REPO_DIR/openerp/trunk/openobject-server
    bzr pull
    echo ""
    echo "Updating branch trunk/openerp-web"
    cd $REPO_DIR/openerp/trunk/openerp-web
    bzr pull
    echo ""
    echo "Updating branch trunk/openobject-addons"
    cd $REPO_DIR/openerp/trunk/openobject-addons
    bzr pull
}

function compress_repo {
	# $1: 
	
	REPO_DIR=$OPENERP_REPO_BASE/openerp-src/src
	
	echo ""
	echo ""
	echo "COMPRESS $REPO_DIR/openerp"
	
	cd $REPO_DIR
	tar czf $OPENERP_REPO_BASE/openerp-src/bin/openerp.tmp.tgz openerp/.bzr
	if [[ $? != 0 ]]; then
	    echo "tar exited with error code $?, skipping the file"
	else
	    echo "tar OK, moving the file"
	    mv $OPENERP_REPO_BASE/openerp-src/bin/openerp.tmp.tgz $OPENERP_REPO_BASE/openerp-src/bin/openerp.tgz
	fi
}

update_project	openobject-server	5.0		5.0-ccorp	openobject-server
update_project	openobject-server	6.0		6.0-ccorp	openobject-server
update_project	openobject-server	6.1		6.1-ccorp	openobject-server
update_project	openobject-server	trunk	trunk-ccorp	openobject-server

update_project	openobject-addons	5.0		5.0-ccorp	openobject-addons
update_project	openobject-addons	6.0		6.0-ccorp	openobject-addons
update_project	openobject-addons	6.1		6.1-ccorp	openobject-addons
update_project	openobject-addons	trunk	trunk-ccorp	openobject-addons

update_project	openobject-addons	5.0		extra-5.0-ccorp		openobject-addons-extra
update_project	openobject-addons	6.0		extra-6.0-ccorp		openobject-addons-extra
#update_project	openobject-addons	6.1		extra-6.1-ccorp		openobject-addons-extra
update_project	openobject-addons	trunk	extra-trunk-ccorp	openobject-addons-extra

update_project	openobject-client	5.0		5.0-ccorp	openobject-client
update_project	openobject-client	6.0		6.0-ccorp	openobject-client
update_project	openobject-client	6.1		6.1-ccorp	openobject-client
update_project	openobject-client	trunk	trunk-ccorp	openobject-client

update_project	openobject-client-web	5.0		5.0-ccorp	openobject-client-web
update_project	openobject-client-web	6.0		6.0-ccorp	openobject-client-web
update_project	openerp-web				6.1		6.1-ccorp	openerp-web
update_project	openerp-web				trunk	trunk-ccorp	openerp-web

compress_project	5.0		openobject-server
compress_project	6.0		openobject-server
compress_project	6.1		openobject-server
compress_project	trunk	openobject-server

compress_project	5.0		openobject-addons
compress_project	6.0		openobject-addons
compress_project	6.1		openobject-addons
compress_project	trunk	openobject-addons

compress_project	5.0		openobject-addons-extra
compress_project	6.0		openobject-addons-extra
#compress_project	6.1		openobject-addons-extra
compress_project	trunk	openobject-addons-extra

compress_project	5.0		openobject-client
compress_project	6.0		openobject-client
compress_project	6.1		openobject-client
compress_project	trunk	openobject-client

compress_project	5.0		openobject-client-web
compress_project	6.0		openobject-client-web
compress_project	6.1		openerp-web
compress_project	trunk	openerp-web

update_repo
compress_repo
