#!/bin/bash
# v1.0
# par Dylan Leborgne http://dylanleborgne.ovh
clear

echo -e "\033[31mPartie 2 - Install OpenVZ";

echo -e "\033[31mVoulez-vous configuration le réseaux en NAT pour les VPS (O/n): \033[0m"; read selectNAT;
echo -e "\033[31mVoulez-vous insatller et configuration LVM2 (O/n): \033[0m"; read selectLVM2;
echo -e "\033[31mVoulez-vous installer OpenVZ Web Panel (OWP) (O/n): \033[0m"; read selectOWP;
echo -e "\033[31mVoulez-vous créé un VPS (O/n): \033[0m"; read selectVPS;

case $selectNAT in
        "O" | "o")
        	clear

			echo -e "\033[31mPartie 2 - Configuration réseaux en NAT pour les VPS";
			
			
			######## Configuration réseau ########
			echo -e "Votre configuration réseau est : \033[0m \n";
			cat /etc/network/interfaces;
			echo -e "\n\033[31mSi vous choisissez de modifier la configuration réseau, l'ancienne version sera enregistrer sous le nom interfaces.save";
			echo -e "Voulez-vous modifier (O/n): \033[0m"; read modif;
			
			if [[ $modif == "O" || $modif = "o" ]]; then
					cp /etc/network/interfaces /etc/network/interfaces.save; 
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
				clear
			fi
			
			
			######## Configuration NAT ########
			clear
			echo -e "\n\033[31mConfiguration du NAT \033[0m \n"
			
			rm -rf /etc/init.d/iptables
			
			apt-get install iptables
			
			clear
			
			ip=`ifconfig eth0 | grep 'inet adr:' | cut -d: -f2 | awk '{ print $1}'` 
			
			echo -e "\n\n\n\033[31mVoulez pourvoir recevoir du ping ? (O/n): \033[0m"; read ping;
			echo -e "\n\n\033[31mUtilisez-vous le protole ssh ? (O/n): \033[0m"; read ssh;
				if [[ $ssh = "O" || $ssh = "o" ]]; then
					echo -e "\n\033[31mQuel port utilisez-vous ? ('22', '2222'): \033[0m"; read ssh2;
				fi
			
			echo -e "#!/bin/bash
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
#-------------------------------------------------------------------------" >> /etc/init.d/iptables
			if [[ $ping = "O" || $ping = "o" ]]; then
				echo -e "
## On autorise le ping
iptables -t filter -A INPUT -p icmp -j ACCEPT" >> /etc/init.d/iptables
			fi
			
			if [[ $ssh = "O" || $ssh = "o" ]]; then
					echo -e "
## On autorise le ssh sur le port $ssh2
iptables -t filter -A INPUT -p tcp --dport $ssh2 -j ACCEPT" >> /etc/init.d/iptables
			fi
			
			echo -e "\n\033[31mVoici votre fichier de configuration NAT (/etc/init.d/iptables) \033[0m \n"
			cat /etc/init.d/iptables
			
			echo -e "\n\n\033[31mConfiguration du NAT terminer, vous pourrez lancé la partie 3\033[0m \n"
			read -p "Appuyer sur entrer pour continuer ..."
			;;
case $selectLVM2 in
        "O" | "o")
        	
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
			
			clear
			
			echo -e "\n\n\033[31mNom du volume logique:\033[0m"; read lvname;
			echo -e "\n\033[31mTailles du volume logique $lvname (ex: 10g):\033[0m"; read lvtaille;
			
			lvcreate -n $lvname -L $lvtaille OpenVZ
			
			mkfs -t ext4 /dev/OpenVZ/$lvname
			
			mkdir /var/lib/vz/private/$lvname
			
			mount /dev/OpenVZ/$lvname /var/lib/vz/private/$lvname/
			
			clear
			
			echo -e "\n\n\033[31mSauvegarde de /etc/fstab vers /etc/fstab.save\033[0m"
			cp /etc/fstab /etc/fstab.save
			
			echo -e "
#OpenVZ-$lvname
/dev/mapper/OpenVZ-$lvname /var/lib/vz/private/$lvname ext4 defaults 0 2
" >> /etc/fstab
			
			mount -a
			
			echo -e "\n\033[31mVotre volume logique est prêt:\033[0m"
			lvdisplay
			
			echo -e "\n\033[31mLa configuration de LVM2 est terminer, vous pouvez lancé la partie 4\033[0m"
			read -p "Appuyer sur entrer pour continuer ..."
			;;
case $selectOWP in
        "O" | "o")
        	clear

			echo -e "\033[31mPartie 4 - Installation de OpenVZ Web Panel (OWP)\033[0m \n\n";
			
			apt-get install ruby1.8
			
			ln -fs /usr/bin/ruby1.8 /etc/alternatives/ruby
			
			wget -O - http://ovz-web-panel.googlecode.com/svn/installer/ai.sh | sh
			
			/etc/init.d/owp reload
			
			apt-get install ruby1.8
			
			ln -fs /usr/bin/ruby1.8 /etc/alternatives/ruby
			
			wget -O - http://ovz-web-panel.googlecode.com/svn/installer/ai.sh | sh
			
			/etc/init.d/owp reload
			
			iptables=$(sed "49i\ \n## On autoriser la connexion à OpenVZ Web Panel (OWP) \niptables -A INPUT --protocol tcp --destination-port 3000 -j ACCEPT " /etc/init.d/iptables)
			
			rm -rf /etc/init.d/iptables
			
			echo "$iptables" >> /etc/init.d/iptables
			
			chmod +x /etc/init.d/iptables /etc/init.d/iptables
			update-rc.d iptables defaults
			
			/etc/init.d/iptables reload
			
			echo -e "
SHELL=/bin/sh
PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin
# m   h  dom mon dow   command
  */5 *   *   *   *    /etc/init.d/owp reload" >> /var/spool/cron/crontabs/root
			  
			ip=`ifconfig eth0 | grep 'inet adr:' | cut -d: -f2 | awk '{ print $1}'` 
			
			clear
			  
			echo -e "\n\n\033[31mVotre interface OWP est accessible depuis votre navigateur à:
http://$ip:3000
login: admin
Mot de Passe : admin"
			
			echo -e "\n\nL'installation de OpenVZ Web Panel est terminer, vous pourrez lancé la partie 5\033[0m \n"
			read -p "Appuyer sur entrer pour continuer ..."
        	;;
case $selectOWP in
        "O" | "o")
        	clear

			echo -e "\033[31mPartie5 - Creation D'un VPS\033[0m";
			
			echo -e "\n\033[31mTelechargement d'un templates\nListe des templates disponible\n\033[0m";
			vztmpl-dl --list-remote
			echo -e "\n\033[31mEntrer le nom d'un template (ex: debian-7.0-x86_64-minimal):\033[0m"; read template;
			vztmpl-dl $template
			
			
			#-------------------------------------------------------------------------
			# Déclaration des variables
			#-------------------------------------------------------------------------
			
			clear
			
			echo -e "\n\033[31mEntrer le numéro du conteneur (ex: '101',102'):\033[0m"; read CTID;
			echo -e "\033[31mEntrer l'IP de conteneur (ex: '192.168.0.1') :\033[0m"; read ip_address;
			echo -e "\033[31mEntrer le nom du conteneur :\033[0m"; read name;
			echo -e "\033[31mEntrer le hostname du conteneur (FQDN) :\033[0m"; read FQDN;
			echo -e "\033[31mEntrer la taille disque du conteneur (en kilo, ex: '2000000' pour 2g) :\033[0m"; read disque;
			echo -e "\033[31mEntrer la taille de la memoire RAM du conteneur (ex: '2G') :\033[0m"; read ram;
			echo -e "\033[31mListe des volumes disponibles:\033[0m";
			lvdisplay
			echo -e "\n\033[31mEntrer le nom du volume (LV Name) ou le conteneur sera stocker :\033[0m"; read Volume;
			echo -e "\n\033[31mUtiliser vous le mode NAT pour la configuration IP de votre VPS ? (O/n): \033[0m"; read NAT;
			if [[ $NAT = "O" || $NAT = "o" ]]; then
				echo -e "\n\033[31mLe VPS utilisera t'elle un port particulier ? (O/n): \033[0m"; read port;
					if [[ $port = "O" || $port = "o" ]]; then
						echo -e "\n\033[31mQuel port utilisera t'elle ? ('22', '80'): \033[0m"; read port2;
					fi
			fi
			
			#-------------------------------------------------------------------------
			# Création
			#-------------------------------------------------------------------------
			
			vzctl create $CTID --ostemplate $template --config basic --private=/var/lib/vz/private/$Volume/$CTID --diskspace=$disque
			
			
			#-------------------------------------------------------------------------
			# Configuration
			#-------------------------------------------------------------------------
			
			# Affectation de la mémoire RAM
			vzctl set $CTID --ram $ram --swap 1G --save
			
			# Affectation d’une IP
			vzctl set $CTID --ipadd $ip_address --save
			
			# Affectation d’un nom plus facile à retenir que le CTID (MvWeb1 au lieu de « 101 »)!
			vzctl set $CTID --name $name --save
			
			# Affectation d’un nom d’host (FQDN)
			vzctl set $CTID --hostname $FQDN --save
			
			# Affectation d’un nom serveur DNS
			vzctl set $CTID --nameserver 8.8.8.8 --save
			
			# Démarage au boot du server OpenVZ
			vzctl set $CTID --onboot yes --save
			
			# Démarrage  du container
			vzctl start $CTID
			
			# Reload OWP
			/etc/init.d/owp reload
			
			ip=`ifconfig eth0 | grep 'inet adr:' | cut -d: -f2 | awk '{ print $1}'` 
			
			if [[ $port = "O" || $port = "o" ]]; then
				echo -e "
#-------------------------------------------------------------------------
# Routage de port internet vers VE
#-------------------------------------------------------------------------
	
## Routage port 80 vers VE
iptables -t nat -A PREROUTING -p tcp -d $ip --dport $port2 \
  -i eth0 -j DNAT --to-destination $ip_address:$port2" >> /etc/init.d/iptables
			fi
			
			clear
			
			echo -e "\n\n\033[31mVotre conteneur est cree:\033[0m";
			# Affichage VPS actifes
			vzlist
			
			echo -e "\n\n\033[31mLa creation Du VPS est terminer, ainsi que l'installation de OpenVZ\033[0m \n"
			read -p "Appuyer sur entrer pour continuer ..."
        	;;