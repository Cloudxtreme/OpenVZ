#!/bin/bash


#-------------------------------------------------------------------------
# Déclaration des variables
#-------------------------------------------------------------------------

echo "Entrer le numéro du conteneur (ex: '101',102') :"; read CTID;
echo "Entrer l'IP de conteneur (ex: '192.168.0.1') :"; read ip_address;
echo "Entrer le nom du conteneur :"; read name;
echo "Entrer le hostname du conteneur (FQDN) :"; read FQDN;
echo "Entrer le template du conteneur (ex: 'debian-7.0-x86_64') :"; read template;
echo "Entrer le nom du volume ou le conteneur sera stocker :"; read Volume;

#-------------------------------------------------------------------------
# Création
#-------------------------------------------------------------------------

vzctl create $CTID --ostemplate $template --config basic --private=/var/lib/vz/private/$Volume/102


#-------------------------------------------------------------------------
# Configuration
#-------------------------------------------------------------------------

# Affectation d’une IP
vzctl set $CTID --ipadd $ip_address --save


# Affectation d’un nom plus facile à retenir que le CTID (MvWeb1 au lieu de « 101 »)!
vzctl set $CTID --name $name --save


# Affectation d’un nom d’host (FQDN)
vzctl set $CTID --hostname $FQDN --save


# Affectation d’un nom serveur DNS
vzctl set $CTID --nameserver 8.8.8.8 --save


# Démarrage  du container
vzctl start $CTID


# Démarage au boot du server OpenVZ
vzctl set $CTID --onboot yes —save


# Affichage VPS actifes
vzlist


# Reload OWP
/etc/init.d/owp reload