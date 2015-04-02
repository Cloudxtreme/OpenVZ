#!/bin/bash
# v1.0
# par Dylan Leborgne http://dylanleborgne.ovh

clear

echo -e "\033[31mPartie 2 - Configuration réseaux en NAT pour les VPS";


######## Configuration réseau ########
echo -e "Votre configuration réseau est : \033[0m \n";
cat /etc/network/interfaces;
echo -e "\n\n\033[31mAttention!! si vous choisissez de modifier la configuration réseau, l'ancienne version sera supprimer";
echo -e "Voulez-vous modifier (O/n): \033[0m"; read modif;

if [[ $modif == "O" || $modif = "o" ]]; then
		echo -e "\n\033[31mAdresse IP: \033[0m"; read ip;
		echo -e "\n\033[31mMasque de sous réseu: \033[0m"; read mask;
		echo -e "\n\033[31mPasserelle: \033[0m"; read gateway;
		rm -rf /etc/network/interfaces;
		echo -e "# This file describes the network interfaces available on your system
# and how to activate them. For more information, see interfaces(5).

# The loopback network interface
auto lo
iface lo inet loopback

# The primary network interface
allow-hotplug eth0
iface eth0 inet static
	address $ip
    netmask $mask
	gateway $gateway" > /etc/network/interfaces
fi

if [[ $modif == "O" || $modif = "o" ]]; then
	echo -e "\n\033[31mVotre nouvelle configuration réseau est : \033[0m \n";
	cat /etc/network/interfaces;
	read -p "Appuyer sur une touche pour continuer ..."
fi


######## Configuration NAT ########
clear
echo -e "\n\033[31mConfiguration du NAT \033[0m \n"

rm -rf /etc/init.d/iptables

apt-get install iptables

ip=`ifconfig eth0 | grep 'inet addr:' | cut -d: -f2 | awk '{ print $1}'` 

echo -e "\n\n\n\033[31mVoulez pourvoir recevoir du ping ? (O/n): \033[0m"; read ping;
echo -e "\n\n\033[31mUtilisez-vous le protole ssh ? (O/n): \033[0m"; read shh;
	if [[ $ssh = "O" || $shh = "o" ]]; then
		echo -e "\nQuel port utilisez-vous ? ('22', '2222'): \033[0m"; read shh2;
	fi

echo -e "
#!/bin/bash
#/etc/init.d/iptable

### BEGIN INIT INFO
# Provides:          iptable
# Required-Start:    $remote_fs $syslog
# Required-Stop:     $remote_fs $syslog
# Default-Start:     2 3 4 5
# Default-Stop:      0 1 6
# Short-Description: Démarre les règles iptables
# Description:       Charge la configuration du pare-feu iptables
### END INIT INFO

#-------------------------------------------------------------------------
# Essentials
#-------------------------------------------------------------------------

## Effacer toutes les règles existantes pour configurer les notres
iptables -t filter -F
iptables -t filter -X

## Règles permettant de fermer tous les ports, en entrée et ouvrir en sortie du serveur
iptables -t filter -P INPUT DROP
iptables -t filter -P FORWARD ACCEPT
iptables -t filter -P OUTPUT ACCEPT

## On ne ferme pas les connexions déjà établies
iptables -A INPUT -m state --state RELATED,ESTABLISHED -j ACCEPT
iptables -A OUTPUT -m state --state RELATED,ESTABLISHED -j ACCEPT

## On ouvre tous les ports pour une utilisation locale (localhost)
iptables -t filter -A INPUT -i lo -j ACCEPT
iptables -t filter -A OUTPUT -o lo -j ACCEPT


#-------------------------------------------------------------------------
# Routage VE vers internet
#-------------------------------------------------------------------------

#Tout le monde peut sortir
iptables -t nat -A POSTROUTING -s 0.0.0.0/0 -o eth0 -j SNAT --to $ip

#Juste les VE avec cette adresse réseau peut sortir
#iptables -t nat -A POSTROUTING -s 'ip réseau de vos VE (ex:192.168.2.0/24)' -o eth0 -j SNAT --to $ip

#-------------------------------------------------------------------------
# Ouverture de port sur serveur
#-------------------------------------------------------------------------
" >> /etc/init.d/iptables
if [[ $ping = "O" || $ping = "o" ]]; then
	echo -e "## On autorise le ping
			iptables -t filter -A INPUT -p icmp -j ACCEPT" >> /etc/init.d/iptables
fi

if [[ $ssh = "O" || $ssh = "o" ]]; then
		echo -e "## On autorise le ssh sur le port $ssh2
				iptables -t filter -A INPUT -p tcp --dport $ssh2 -j ACCEPT" >> /etc/init.d/iptables
fi

chmod +x /etc/init.d/iptables /etc/init.d/iptables
update-rc.d iptables defaults

echo -e "\n\033[31mVoici votre fichier de configuration NAT (/etc/init.d/iptables) \033[0m \n"
cat /etc/init.d/iptables

echo -e "\n\n\033[31mConfiguration du NAT terminer\033[0m \n"
read -p "Appuyer sur entrer pour continuer ..."