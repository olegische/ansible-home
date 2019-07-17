#! /bin/bash

function install_packages () {
    #
    #update OS
    p_m=$1 && shift
    sudo $p_m update -y &> /dev/null
    for package in $@
    do
        if [ ! $( type -path "$package"  > /dev/null 2>&1 ) ]; then
#            sudo $p_m install -y $package &> /dev/null
            sudo $p_m install -y $package
        fi
    done
    #
}