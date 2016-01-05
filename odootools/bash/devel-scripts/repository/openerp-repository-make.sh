#!/bin/bash

if [[ $OPENERP_REPO_BASE == "" ]]; then
    OPENERP_REPO_BASE=~/Development/openerp
fi

OPENERP_REPO_BASE=$(readlink -m $OPENERP_REPO_BASE)

function branch_project {
    # $1: Project name
    # $2: Type (original, ccorp)
    # $3,4,5,...: Original branches
    echo ""
    echo ""
    echo "Project: $1"
    echo "--------------------------------------------------------------"
    echo ""
    
    REPO_DIR=$OPENERP_REPO_BASE/$1
    
    echo "Create $2 repository $REPO_DIR"
    if [ -d $REPO_DIR ]; then
        echo "repository already exists, delete before running the script to recreate"
        echo "$REPO_DIR"
    elif [ $OPENERP_REPO_NOTREES ]; then
        echo "bzr init-repo --no-tree $REPO_DIR"
        bzr init-repo --no-tree $REPO_DIR
    else
        echo "bzr init-repo $REPO_DIR"
        bzr init-repo $REPO_DIR
    fi
    echo ""
    
    echo "Subdirectories creation"
    if [ -d $REPO_DIR/main ]; then
        echo "main already exists, delete before running the script to recreate"
        echo "$REPO_DIR/main"
    else
        echo "mkdir $REPO_DIR/main"
        mkdir $REPO_DIR/main
    fi
    if [ -d $REPO_DIR/features ]; then
        echo "features already exists, delete before running the script to recreate"
        echo "$REPO_DIR/features"
    else
        echo "mkdir $REPO_DIR/features"
        mkdir $REPO_DIR/features
    fi
    echo ""
    
    echo "Main branches creation"
    echo ""
    args=("$@")
    start=2
    let "stop=$#-1"
    for i in `seq $start $stop`; do
        branch=${args[$i]}
        LP_OERP="bzr+ssh://bazaar.launchpad.net/%2Bbranch/$1/$branch"
        LP_CCORP="bzr+ssh://bazaar.launchpad.net/%2Bbranch/~clearcorp-drivers/$1/${branch}-ccorp"
        echo "Branch creation: $1/$branch"
        
        echo "Branch $LP_OERP"
        if [ -d $REPO_DIR/main/$branch/.bzr ]; then
            echo "$REPO_DIR/main/$branch already exists, delete before running the script to recreate"
        else
            echo "bzr branch $LP_OERP $REPO_DIR/main/$branch"
            bzr branch $LP_OERP $REPO_DIR/main/$branch
        fi
        
        if [[ $2 =~ ^original$ ]]; then
            echo "Branch $LP_CCORP"
            if [ -d $REPO_DIR/main/${branch}-ccorp/.bzr ]; then
                echo "$REPO_DIR/main/${branch}-ccorp already exists, delete before running the script to recreate"
            else
                echo "bzr branch $LP_CCORP $REPO_DIR/main/${branch}-ccorp"
                bzr branch $LP_CCORP $REPO_DIR/main/${branch}-ccorp
            fi
        fi

        echo "Updating parent locations"
        echo "parent_location = $LP_OERP" > $REPO_DIR/main/$branch/.bzr/branch/branch.conf
        if [[ $2 =~ ^original$ ]]; then
            echo "parent_location = $LP_OERP" > $REPO_DIR/main/${branch}-ccorp/.bzr/branch/branch.conf
            echo "push_location = $LP_CCORP" >> $REPO_DIR/main/${branch}-ccorp/.bzr/branch/branch.conf
        elif [[ $2 =~ ccorp ]]; then
            echo "push_location = $LP_OERP" >> $REPO_DIR/main/$branch/.bzr/branch/branch.conf
        fi
        
        echo ""
    done
    
    echo ""
    echo ""
}

branch_project  openobject-server       original    5.0 6.0 6.1 trunk
branch_project  openobject-addons       original    5.0 6.0 6.1 trunk extra-5.0 extra-6.0 extra-trunk
branch_project  openobject-client       original    5.0 6.0 6.1 trunk
branch_project  openobject-client-web   original    5.0 6.0 trunk
branch_project  openerp-web             original    6.1 trunk
branch_project  openobject-doc          original    5.0 6.0 6.1

branch_project  openerp-ccorp-addons    ccorp   5.0 6.0 6.1 trunk
branch_project  openerp-costa-rica      ccorp   6.0 6.1 trunk
branch_project  openerp-ccorp-scripts   ccorp   stable trunk

branch_project  banking-addons          original    5.0 6.0 6.1 trunk