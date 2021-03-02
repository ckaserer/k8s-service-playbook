#!/bin/bash
set -e

# Script should only be run as root
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root" 
   exit 1
fi

# Script should only be run on Ubuntu
# https://askubuntu.com/questions/459402/how-to-know-if-the-running-platform-is-ubuntu-or-centos-with-help-of-a-bash-scri
UNAME=$(uname | tr "[:upper:]" "[:lower:]")
if [ "$UNAME" == "linux" ]; then
    if [ -f /etc/lsb-release -o -d /etc/lsb-release.d ]; then
        export DISTRO=$(lsb_release -i | cut -d: -f2 | sed s/'^\t'//)
    else
        export DISTRO=$(ls -d /etc/[A-Za-z]*[_-][rv]e[lr]* | grep -v "lsb" | cut -d'/' -f3 | cut -d'-' -f1 | cut -d'_' -f1)
    fi
fi
unset UNAME
if [ "$DISTRO" != "Ubuntu" ]; then
   echo "This script must be run on Ubuntu" 
   exit 1
fi

apt-get update -y
apt-get install -y git python3 python3-pip

git clone https://github.com/ckaserer/k8s-service-playbook.git

cd k8s-bastion-playbook

pip3 install virtualenv
python3 -m virtualenv .env
source .env/bin/activate

pip3 install -r requirements.txt
ansible-galaxy role install -r requirements.yml

ansible-playbook playbook.yml -i hosts.ini
