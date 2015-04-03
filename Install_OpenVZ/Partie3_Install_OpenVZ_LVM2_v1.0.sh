#!/bin/bash
#v1.0
# par Dylan Leborgne http://dylanleborgne.ovh

chmod +x /etc/init.d/iptables /etc/init.d/iptables
update-rc.d iptables defaults

clear

echo -e "\033[31mPartie 3 - Configuration de LVM2\033[0m\n\n";

apt-get install lvm2

umount /vz

sed '/\/vz/d' /etc/fstab > /etc/fstab2
rm -rf /etc/fstab
mv /etc/fstab2 /etc/fstab

pvcreate /dev/sda3

vgcreate OpenVZ /dev/sda3

echo -e "\n\n\033[31mNom du volume logique:\033[0m"; read lvname;
echo -e "\n\n\033[31mTailles du volume logique $lvname (ex: 10g):\033[0m"; read lvtaille;

lvcreate -n $lvname -L $lvtaille OpenVZ

mkfs -t ext4 /dev/OpenVZ/$lvname

mkdir /var/lib/vz/private/$lvname

mount /dev/OpenVZ/$lvname /var/lib/vz/private/$lvname/

echo -e "\n\n\033[31mSauvegarde de /etc/fstab vers /etc/fstab.save\033[0m"
cp /etc/fstab /etc/fstab.save

echo -e "
#OpenVZ-$lvname
/dev/mapper/OpenVZ-$lvname /var/lib/vz/private/$lvname ext4 defaults 0 2
" >> /etc/fstab

mount -a

echo -e "\n\n\033[31mVotre volume logique est prêt, vous pourrez lancé la partie 4\033[0m"
lvdisplay
