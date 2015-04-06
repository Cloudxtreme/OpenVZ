#!/usr/bin/bash
#================================================
# F O N C T I O N S . . .
#================================================
#------------------------------------------------
# Menu - Affichage d'un menu
#------------------------------------------------
# Args : $1    = Titre du menu
#        $2n   = Fonction associée 'n' au choix
#        $2n+1 = Libellé du choix 'n' du menu
#------------------------------------------------
Menu()
{
  local -a menu fonc
  local titre nbchoix
  # Constitution du menu
  if [[ $(( $# % 1 )) -ne 0 ]] ; then
     echo "$0 - Menu invalide" >&2
     return 1
  fi
  titre="$1"
  shift 1
  set "$@" "return 0" "Sortie"
  while [[ $# -gt 0 ]]
  do
     (( nbchoix += 1 ))
     fonc[$nbchoix]="$1"
     menu[$nbchoix]="$2"
     shift 2
  done
  # Affichage menu
  PS3="Votre choix ? "
  while :
  do
     echo
     [[ -n "$titre" ]] && echo -e "$titre\n"
     select choix in "${menu[@]}"
     do
        if [[ -z "$choix" ]]
           then echo -e "\nChoix invalide"
           else eval ${fonc[$REPLY]}
        fi
        break
     done || break
  done
}
#------------------------------------------------
# Création d'un VPS
#------------------------------------------------
Create_VPS()
{
	clear
	echo -e "\033[31mCreation D'un VPS\033[0m";
	
	echo -e "\033[31mTemplates à télécharger:\n\033[0m";
	vztmpl-dl --list-remote
	
	echo -e "\n\033[31mTemplate dèjà télécharger:\n\033[0m";
	vztmpl-dl --list-local
	
	echo -e "\n\033[31mVoulez-vous télécharger un template (O/n):\033[0m"; read selectNAT;
	if [[ $selectNAT == "O" || $selectNAT = "o" ]]; then
		echo -e "\033[31mEntrer le nom d'un template à télécharger(ex: debian-7.0-x86_64-minimal):\033[0m"; read template;
		vztmpl-dl $template
	else 
		echo -e "\033[31mEntrer le nom d'un template dèjà télécharger(ex: debian-7.0-x86_64-minimal):\033[0m"; read template;
	fi
	
	
	#-------------------------------------------------------------------------
	# Déclaration des variables
	#-------------------------------------------------------------------------
	
	clear
	echo -e "\033[31mEntrer le numéro du conteneur (ex: '101',102'):\033[0m"; read CTID;
	echo -e "\033[31mEntrer l'IP de conteneur (ex: '192.168.0.1') :\033[0m"; read ip_address;
	echo -e "\033[31mEntrer le nom du conteneur :\033[0m"; read name;
	echo -e "\033[31mEntrer le hostname du conteneur (FQDN) :\033[0m"; read FQDN;
	echo -e "\033[31mEntrer la taille disque du conteneur (en kilo, ex: '2000000' pour 2G) :\033[0m"; read disque;
	echo -e "\033[31mEntrer la taille de la memoire RAM du conteneur (ex: '2G') :\033[0m"; read ram;
	echo -e "\033[31mListe des volumes disponibles:\033[0m";
	lvdisplay
	echo -e "\033[31mEntrer le nom du volume (LV Name) ou le conteneur sera stocker :\033[0m"; read Volume;
	echo -e "\033[31mUtiliser vous le mode NAT pour la configuration IP de votre VPS ? (O/n): \033[0m"; read NAT;
	if [[ $NAT = "O" || $NAT = "o" ]]; then
		echo -e "\033[31mLe VPS utilisera t'elle un port particulier ? (O/n): \033[0m"; read port;
			if [[ $port = "O" || $port = "o" ]]; then
				echo -e "\033[31mQuel port utilisera t'elle ? ('22', '80'): \033[0m"; read port2;
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
	echo -e "\033[31mVotre conteneur est créé:\033[0m";
	# Affichage VPS actifes
	vzlist
	
	echo -e "\n\033[31mLa creation Du VPS est terminer\033[0m"

}
#------------------------------------------------
# Changer le mot de passe root d’un VPS
#------------------------------------------------
ChangeMdpRoot()
{
   clear
   echo -e "\033[31mVPS Actif\033[0m"
   vzlist
   echo -e "\033[31mEntrer le numéro du conteneur (ex: '101',102'):\033[0m"; read CTID;
   echo -e "\033[31mEntrer le nouveau mot de passe\033[0m"; read passwd;
   vzctl set $CTID $passwd
}
#------------------------------------------------
# Changer la taille de la mémoire RAM d’un VPS
#------------------------------------------------
GHome()
{
   clear
   echo -e "\033[31mVPS Actif\033[0m"
   vzlist
   echo -e "\033[31mEntrer le numéro du conteneur (ex: '101',102'):\033[0m"; read CTID;
   echo -e "\033[31mEntrer la taille de la memoire RAM du conteneur (ex: '2G') :\033[0m"; read ram;
   vzctl set $CTID --ram $ram --swap 1G --save
}
#-----------------------------------------------
# Changer le nouveau hostname du conteneur
#------------------------------------------------
ChangeFQDN()
{
   clear
   echo -e "\033[31mVPS Actif\033[0m"
   vzlist
   echo -e "\033[31mEntrer le numéro du conteneur (ex: '101',102'):\033[0m"; read CTID;
   echo -e "\033[31mEntrer le nouveau hostname du conteneur (FQDN) :\033[0m"; read FQDN;
   vzctl set $CTID --hostname $FQDN --save
}
#-----------------------------------------------
# Changer le DNS serveur
#------------------------------------------------
ChangeDNS()
{
   clear
   echo -e "\033[31mVPS Actif\033[0m"
   vzlist
   echo -e "\033[31mEntrer le numéro du conteneur (ex: '101',102'):\033[0m"; read CTID;
   echo -e "\033[31mEntrer le nouveau hostname du conteneur (FQDN) :\033[0m"; read FQDN;
   vzctl set $CTID --nameserver 8.8.8.8 --save
}
#-----------------------------------------------
# Changer l'adresse IP
#------------------------------------------------
ChangeIP()
{
   clear
   echo -e "\033[31mVPS Actif\033[0m"
   vzlist
   echo -e "\033[31mEntrer le numéro du conteneur (ex: '101',102'):\033[0m"; read CTID;
   echo -e "\033[31mEntrer l'ancienne IP du conteneur (ex: '192.168.0.1') :\033[0m"; read ip_address_add;
   echo -e "\033[31mEntrer l'IP du conteneur (ex: '192.168.0.2') :\033[0m"; read ip_address_del;
   vzctl set $CTID --ipdel $ip_address_del --save
   vzctl set $CTID --ipadd $ip_address_add --save
}
#-----------------------------------------------
# Sauvegarder un VPS
#------------------------------------------------
BackupVPS()
{
   clear
   echo -e "\033[31mVPS Actif\033[0m"
   vzlist
   echo -e "\033[31mEntrer le numéro du conteneur (ex: '101',102'):\033[0m"; read CTID;
   mkdir /backup_VPS
   cd /backup_VPS
   vzdump $CTID
   echo -e "\n\033[31mVotre VPS sauvegarder se trouve dans '/var/lib/vz/dump/':\033[0m"
}
#-----------------------------------------------
# Restaurer un VPS
#------------------------------------------------
RestaureVPS()
{
   clear
   echo -e "\033[31mVPS Actif\033[0m"
   vzlist
   echo -e "\033[31mOu se trouve l'archive du VPS ? (ex: /root/backup_101.tar):\033[0m"; read chemin;
   echo -e "\033[31mEntrer le numéro du conteneur (ex: '101',102'):\033[0m"; read CTID;
   echo -e "\033[31mEntrer l'IP du conteneur (ex: '192.168.0.1') :\033[0m"; read ip_address;
   vzrestore $chemin $CTID
   vzctl set $CTID --ipadd $ip_address --save
   vzctl start $CTID
   vzlist
}
#================================================
# M A I N . . .
#================================================
Menu \
  "---- Managements VPS ----"	\
  Create_VPS    		"Créé un VPS"	\
  ChangeMdpRoot 		"Changer le mot de passe root d’un VPS"		\
  ChangeRAM    			"Changer la taille de la mémoire RAM d’un VPS"	\
  ChangeFQDN 			"Changer le hostname d'un conteneur (FQDN)"	\
  ChangeDNS				"Changer le serveur DNS d'un conteneur"	\
  ChangeIP				"Changer l'adresse IP d'un conteneur"	\
  BackupVPS				"Sauvegarder un VPS"	\
  RestaureVPS			"Restaurer un VPS"	\