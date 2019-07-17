#!/bin/bash

# Packages: chpasswd

source ./lib/common.sh
source ./lib/install_packages.sh

usage_text="Install Ansible"

usage( )
{
    cat <<EOF
$usage_text
Usage:
    $PROGRAM [ --? ]
        [ --help ]
        [ --version ]
EOF
}

PROGRAM=`basename $0`
VERSION=1.0

while test $# -gt 0
do
    case $1 in
    --help | --hel | --he | --h | '--?' | -help | -hel | -he | -h | '-?' )
        usage_and_exit 0
        ;;
    --version | --versio | --versi | --vers | --ver | --ve | --v | \
    -version | -versio | -versi | -vers | -ver | -ve | -v )
        version
        exit 0
        ;;
    -*)
        error "Unrecognized option: $1"
        ;;
    *)
        break
        ;;
    esac
    shift
done

function os_specific () {
    #
    if [ -f /etc/centos-release ] || [ -f /etc/redhat-release ] ; then
        echo "CentOS";
        package_manager="yum"
        packages="epel-release ansible openssl"
        install_packages $package_manager $packages
	elif [ -f /etc/debian_version ]; then
    	echo "Debian/Ubuntu/Kali Linux";
        package_manager="apt-get"
        sudo sh -c "echo \"deb http://ppa.launchpad.net/ansible/ansible/ubuntu trusty main\" > /etc/apt/sources.list.d/ansible.list"
        if [[ ! $( apt-key list | grep '93C4 A3FD 7BB9 C367' ) ]] 2> /dev/null; then
            sudo apt-key adv --keyserver "keyserver.ubuntu.com" --recv-keys "93C4A3FD7BB9C367"
        fi
        packages="ansible openssl"
        install_packages $package_manager $packages
        if [[ $( apt-key list | grep '93C4 A3FD 7BB9 C367' ) ]] 2> /dev/null; then
            sudo apt-key del "93C4 A3FD 7BB9 C367"
        fi
        sudo rm "/etc/apt/sources.list.d/ansible.list"
        sudo $package_manager autoremove -y > /dev/null
	else
    	OS=$(uname -s)
    	VER=$(uname -r)
    	echo 'OS=' $OS 'VER=' $VER
        exit 0
	fi
    #
}

function install_ansible () {
    os_specific
    ansible --version
    sudo sed -i 's/#pipelining = False/pipelining = True/g' /etc/ansible/ansible.cfg
}

install_ansible

exit 0