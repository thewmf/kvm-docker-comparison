#!/bin/bash

############################################################################
#
#               ------------------------------------------
#               THIS SCRIPT PROVIDED AS IS WITHOUT SUPPORT
#               ------------------------------------------
#
# Author: Renato Botelho do Couto <rbcouto@br.ibm.com>
# Version: 0.3.1
# Changes: Quote parameters when it's necessary
#
# Author: Graham Eames <graham_eames@uk.ibm.com> 
# Version: 0.3.0
# Changes: Added support for RHEL 6 clients (including sub-channels)
#
# Author: Graham Eames <graham_eames@uk.ibm.com>
# Version: 0.2.2
# Changes: Updated to support non-x86 architectures, now tested on i386/x86_64/ppc/s390x
#
# author: diego souza <diegocs@br.ibm.com>
# version: 0.2.1
# changes: Added support for RHEL 5 clients and uses yum instead of up2date
#          Added support for new RHEL 5 subchannels
#
# author: scott russell <lnxgeek@us.ibm.com>
# version: 0.1
# description: Wrapper script for up2date to use yum repos from the
#              ftp3.linux.ibm.com server. Avoids the need to keep a
#              user id and password exposed in the sources file.
#
# The following environment variables can be used:
#
#   FTP3USER=user@cc.ibm.com        Enterprise Linux FTP Account
#   FTP3PASS=mypasswd               Enterprise Linux FTP Password
#   FTP3HOST=ftp3.linux.ibm.com     Server to use for updates
#
# You must be root to run this script. The user id and password will be
# prompted for if the environment variables are not set. The server can be
# any site listed from https://ftp3.linux.ibm.com/sites.html and defaults
# to ftp3.linux.ibm.com.
#
# All options given are passed directly to the yum command. Some
# example uses might be:
#
#   ./ibm-yum.sh list updates
#   FTP3USER=user@cc.ibm.com ./ibm-yum.sh list updates
#
# The first example is a good way to test this script. The second example
# shows how to set the FTP3USER environment variable on the command line.
# See the output of up2date --help for full options.
#
# This script was tested on RHEL 5 Server i386
#
############################################################################

## default host
if [ -z "$FTP3HOST" ] ; then
    FTP3HOST="ftp3.linux.ibm.com"
fi

## other vars that most likely should not change
UP2DATE="/usr/bin/yum --noplugins"
RHN_SOURCE="/etc/yum.repos.d/ibm-yum-$$.repo";
#RHN_SOURCE_BACKUP="$RHN_SOURCE.$$";

## these are detected automatically
ARCH=
VERSION=
RELEASE=

## this is called on exit to restore the sources file from the backup
cleanUp()
{
#    if [ -e $RHN_SOURCE_BACKUP ] ; then
#        TEMP=`mv --force $RHN_SOURCE_BACKUP $RHN_SOURCE`
#        if [ $? != 0 ] ; then
#            echo ""
#            echo "Failed to restore $RHN_SOURCE from backup"
#            echo "copy $RHN_SOURCE_BACKUP."
#            echo ""
#        else
#            echo ""
#            echo "Restored $RHN_SOURCE from backup"
#            echo ""
#        fi
#    fi
    if [ -e $RHN_SOURCE ] ; then
        TEMP=`rm --force $RHN_SOURCE`
        if [ $? != 0 ] ; then
            echo ""
            echo "Failed to remove temporary config file"
            echo "Remove $RHN_SOURCE"
            echo ""
        else
            echo ""
            echo "Removed temporary configuration"
            echo ""
        fi
    fi
    return 0;
}

## clean up proper if something goes bad
trap cleanUp EXIT HUP INT QUIT TERM;


## must be root to run this
if [ `whoami` != "root" ] ; then
    echo "You must run this script as root. Goodbye."
    echo ""
    exit 1
fi

## get the userid
if [ -z "$FTP3USER" ] ; then
    echo -n "User ID: "
    read FTP3USER

    if [ -z "$FTP3USER" ] ; then
        echo ""
        echo "Missing userid. Either set the environment variable"
        echo "FTP3USER to your user id or enter a user id when prompted."
        echo "Goodbye."
        echo ""
        exit 1
    fi
fi

## get the password
if [ -z "$FTP3PASS" ] ; then
    ## prompt for password
    echo -n "Password for $FTP3USER: "
    stty -echo
    read FTP3PASS
    stty echo
    echo ""
    echo ""

    if [ -z "$FTP3PASS" ] ; then
        echo "Missing password. Either set the environment variable"
        echo "FTP3PASS to your user password or enter a password when"
        echo "prompted. Goodbye."
        echo ""
        exit 1
    fi
fi

## get the system arch
case `uname -m` in
    i?86        ) ARCH="i386";;
    ppc | ppc64 ) ARCH="ppc";;
    s390        ) ARCH="s390";;
    s390x       ) ARCH="s390x";;
    x86_64      ) ARCH="x86_64";;
    ia64        ) ARCH="ia64";;
    *           ) ARCH=;;
esac

## check to see we got a good arch
if [ -z "$ARCH" ] ; then
    echo "Unknown or unsupported system arch: `uname -m`"
    echo "Try reporting this to ftpadmin@linux.ibm.com with"
    echo "the full output of uname -a and the contents of"
    echo "/etc/redhat-release"
    echo ""
    exit 1
fi

## get the version and release, most likely only works on RHEL
VERREL=`rpm -qf --qf "%{VERSION}\n" /etc/redhat-release`
if [ $? != 0 ] ; then
    echo "Failed to find system version and release with the"
    echo "command \"rpm -q redhat-release\". Is this system"
    echo "running Red Hat Enterprise Linux?"
    echo ""
    exit 1
fi

## split something like "5Server" into 5 and Server
RELEASE=${VERREL:0:1}
VERSION=${VERREL:1}

## verify support for this release
case $RELEASE in
    5   ) : ;;
    6   ) : ;;
    *       ) RELEASE= ;;
esac

## verify support for this version
case $VERSION in
    Server      ) VERSION="server" ;;
    Client      ) VERSION="client" ;;
    Workstation ) VERSION="workstation" ;;
    *           ) VERSION= ;;
esac

if [ -z "$VERSION" ] || [ -z "$RELEASE" ] ; then
    echo "Unknown or unsupported system version and release: $VERREL"
    echo "Try reporting this to ftpadmin@linux.ibm.com with the"
    echo "full output of uname -a and the contents of /etc/redhat-release"
    echo ""
    exit 1
fi


echo "Detected RHEL $VERREL $ARCH ..."

## backup the sources file
#TEMP=`cp --force $RHN_SOURCE $RHN_SOURCE_BACKUP`
#if [ $? != 0 ] ; then
#    echo "Failed backing up of $RHN_SOURCE. Make sure"
#    echo "you are running as root!"
#    echo ""
#    exit 1
#fi
#echo "Created backup file of $RHN_SOURCE_BACKUP"

# Encode the the username for use in URLs
FTP3USERENC=`echo $FTP3USER | sed s/@/%40/g`

## write out a new sources file
URL="ftp://$FTP3USERENC:$FTP3PASS@$FTP3HOST"

# Base OS packages
echo "[ftp3]" >> $RHN_SOURCE
echo "name=FTP3 yum repository" >> $RHN_SOURCE
echo "baseurl=$URL/redhat/yum/$RELEASE/$VERSION/os/$ARCH/" >> $RHN_SOURCE
echo "gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-redhat-release" >> $RHN_SOURCE

# Update packages
echo "[ftp3-updates]" >> $RHN_SOURCE
echo "name=FTP3 updates yum repository" >> $RHN_SOURCE
echo "baseurl=$URL/redhat/yum/$RELEASE/$VERSION/updates/$ARCH/" >> $RHN_SOURCE
echo "gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-redhat-release" >> $RHN_SOURCE

# Supplementary packages
echo "[ftp3-supplementary]" >> $RHN_SOURCE
echo "name=FTP3 supplementary yum repository" >> $RHN_SOURCE
echo "baseurl=$URL/redhat/yum/$RELEASE/$VERSION/supplementary/$ARCH/" >> $RHN_SOURCE
echo "gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-redhat-release" >> $RHN_SOURCE

# RHEL 5 specfic sub-channels
if [ $RELEASE == 5 ] ; then
    if [[ ($ARCH != "ppc") && ($ARCH != "s390x") ]] ; then
	echo "[ftp3-vt]" >> $RHN_SOURCE
	echo "name=FTP3 virtualization yum repository" >> $RHN_SOURCE
	echo "baseurl=$URL/redhat/yum/$RELEASE/$VERSION/vt/$ARCH/" >> $RHN_SOURCE
    fi
    if [[ ($VERSION = "server") && ($ARCH != "ppc") && ($ARCH != "s390x") ]] ; then
        echo "[ftp3-cluster]" >> $RHN_SOURCE
        echo "name=FTP3 cluster yum repository" >> $RHN_SOURCE
        echo "baseurl=$URL/redhat/yum/$RELEASE/$VERSION/cluster/$ARCH/" >> $RHN_SOURCE

        echo "[ftp3-cluster-storage]" >> $RHN_SOURCE
        echo "name=FTP3 cluster-storage yum repository" >> $RHN_SOURCE
        echo "baseurl=$URL/redhat/yum/$RELEASE/$VERSION/cluster-storage/$ARCH/" >> $RHN_SOURCE
    fi
    if [ $VERSION = "client" ] ; then
        echo "[ftp3-workstation]" >> $RHN_SOURCE
        echo "name=FTP3 workstation yum repository" >> $RHN_SOURCE
        echo "baseurl=$URL/redhat/yum/$RELEASE/$VERSION/workstation/$ARCH/" >> $RHN_SOURCE
    fi
fi

# RHEL 6 specific sub-channels
if [ $RELEASE == 6 ] ; then
    # Optional packages
    echo "[ftp3-optional]" >> $RHN_SOURCE
    echo "name=FTP3 optional yum repository" >> $RHN_SOURCE
    echo "baseurl=$URL/redhat/yum/$RELEASE/$VERSION/optional/$ARCH/" >> $RHN_SOURCE

    if [[ ($VERSION == "server") && ($ARCH != "ppc") && ($ARCH != "s390x") ]] ; then
        echo "[ftp3-ha]" >> $RHN_SOURCE
        echo "name=FTP3 ha yum repository" >> $RHN_SOURCE
        echo "baseurl=$URL/redhat/yum/$RELEASE/$VERSION/ha/$ARCH/" >> $RHN_SOURCE

        echo "[ftp3-lb]" >> $RHN_SOURCE
        echo "name=FTP3 lb yum repository" >> $RHN_SOURCE
        echo "baseurl=$URL/redhat/yum/$RELEASE/$VERSION/lb/$ARCH/" >> $RHN_SOURCE

        #echo "[ftp3-rs]" >> $RHN_SOURCE
        #echo "name=FTP3 rs yum repository" >> $RHN_SOURCE
        #echo "baseurl=$URL/redhat/yum/$RELEASE/$VERSION/rs/$ARCH/" >> $RHN_SOURCE
    fi
    if [[ ($VERSION == "server") && ($ARCH == "x86_64") ]] ; then
        echo "[ftp3-v2vwin]" >> $RHN_SOURCE
        echo "name=FTP3 v2vwin yum repository" >> $RHN_SOURCE
        echo "baseurl=$URL/redhat/yum/$RELEASE/$VERSION/v2vwin/$ARCH/" >> $RHN_SOURCE
    fi
fi

echo "Wrote new config file $RHN_SOURCE"

## run the up2date command
echo ""
echo "$UP2DATE $@"
$UP2DATE "$@"

exit 0
