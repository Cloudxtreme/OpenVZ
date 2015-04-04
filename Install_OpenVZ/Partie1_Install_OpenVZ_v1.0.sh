#!/bin/bash
#v1.0
# par Dylan Leborgne http://dylanleborgne.ovh
clear

echo -e "\033[31mPartie 1 - Installation de l’environnement\033[0m"

echo "deb http://download.openvz.org/debian wheezy main" >> /etc/apt/sources.list.d/openvz-rhel6.list

wget http://ftp.openvz.org/debian/archive.key

apt-key add archive.key

rm -rf archive.key

apt-get update

apt-get install linux-image-openvz-amd64

noyau=$(uname -r)

echo -e "\n\033[31mSuppression du noyau, veuillez choisir 'non' lorsque que l'on vous demandera d'annuler la suppression du noyau\033[0m"
read -p "Appuyer sur une touche pour continuer ..."

apt-get remove $noyau

sed '/net.ipv4.ip_forward = 1/d' /etc/sysctl.conf
sed '/net.ipv4.ip_forward = 0/d' /etc/sysctl.conf
sed '/net.ipv6.conf.default.forwarding = 1/d' /etc/sysctl.conf
sed '/net.ipv6.conf.default.forwarding = 0/d' /etc/sysctl.conf
sed '/net.ipv6.conf.all.forwarding = 1/d' /etc/sysctl.conf
sed '/net.ipv6.conf.all.forwarding = 0/d' /etc/sysctl.conf
sed '/net.ipv4.conf.default.proxy_arp = 1/d' /etc/sysctl.conf
sed '/net.ipv4.conf.default.proxy_arp = 0/d' /etc/sysctl.conf
sed '/net.ipv4.conf.all.rp_filter = 1/d' /etc/sysctl.conf
sed '/net.ipv4.conf.all.rp_filter = 0/d' /etc/sysctl.conf
sed '/kernel.sysrq = 1/d' /etc/sysctl.conf
sed '/kernel.sysrq = 0/d' /etc/sysctl.conf
sed '/net.ipv4.conf.default.send_redirects = 1/d' /etc/sysctl.conf
sed '/net.ipv4.conf.default.send_redirects = 0/d' /etc/sysctl.conf
sed '/net.ipv4.conf.all.send_redirects = 1/d' /etc/sysctl.conf
sed '/net.ipv4.conf.all.send_redirects = 0/d' /etc/sysctl.conf

echo "net.ipv4.ip_forward = 1" >> /etc/sysctl.conf
echo "net.ipv6.conf.default.forwarding = 1" >> /etc/sysctl.conf
echo "net.ipv6.conf.all.forwarding = 1" >> /etc/sysctl.conf
echo "net.ipv4.conf.default.proxy_arp = 0" >> /etc/sysctl.conf
echo "# Enables source route verification" >> /etc/sysctl.conf
echo "net.ipv4.conf.all.rp_filter = 1" >> /etc/sysctl.conf
echo "# Enables the magic-sysrq key" >> /etc/sysctl.conf
echo "kernel.sysrq = 1" >> /etc/sysctl.conf
echo "# We do not want all our interfaces to send redirects" >> /etc/sysctl.conf
echo "net.ipv4.conf.default.send_redirects = 1" >> /etc/sysctl.conf
echo "net.ipv4.conf.all.send_redirects = 0" >> /etc/sysctl.conf

apt-get install vzctl vzquota vzstats

echo -e "\n\033[31mL'ordinateur va redémarrer, vous pourrez lancé la partie 2\033[0m"
read -p "Appuyer sur une touche pour redémarrer ..."

reboot