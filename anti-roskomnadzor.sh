#!/usr/bin/env bash

set -e

readonly D_START=$(pwd)
readonly D_HOME=/tmp/anti-roskomnadzor
readonly START_TIME=`date +%s`

# Functions
error () {
    echo -e "\e[1;31mERROR: ${1}\e[0m"
}

success () {
    echo -e "\e[1;32m${1}\e[0m"
}

info () {
    echo -e "\e[1;34m${1}\e[0m"
}

# Parse arguments
domains=()
emails=()
ips=()

for i in "$@"
do
case $i in
    -d=*|--domain=*)
    domains=( "${domains[@]}" "${i#*=}" )
    shift
    ;;

    -e=*|--emails=*)
    emails=( "${emails[@]}" "${i#*=}" )
    shift
    ;;

    -i=*|--ip=*)
    ips=( "${ips[@]}" "${i#*=}" )
    shift
    ;;

    *)
    error "Option \"${i}\" unknown!"
    ;;
esac
done

# Download database
if ! [ -d ${D_HOME} ]
then
    mkdir -p ${D_HOME}
fi

if [ -d ${D_HOME}/z-i-master ]
then
    rm -dfr ${D_HOME}/z-i-master
fi

cd ${D_HOME}
wget https://github.com/zapret-info/z-i/archive/master.zip
unzip master.zip -d ${D_HOME}
rm -f master.zip

# Check domaines
for domain in "${domains[@]}"
do
    echo "Check domain: ${domain}"
    if grep -q ${domain} "${D_HOME}/z-i-master/dump.csv"
    then
        for email in emails
        do
            echo "Domain address ${domain} banned!" | sendmail -t ${email}
        done
        error "Domain address ${domain} banned!"
    else
        success "Domain address ${domain} banned!"
    fi
done

# Check ips
for ip in "${ips[@]}"
do
    echo "Check ip: ${ip}"
    if grep -q ${ip} "${D_HOME}/z-i-master/dump.csv"
    then
        for email in emails
        do
            echo "IP address ${ip} banned!" | sendmail -t ${email}
        done
        error "IP address ${domain} banned!"
    else
        success "IP address ${domain} banned!"
    fi
done

# Remove old files and reset directory
rm -dfr ${D_HOME}
cd ${D_START}

# Print info
info "Script execution time $((`date +%s`-START_TIME)) seconds"
