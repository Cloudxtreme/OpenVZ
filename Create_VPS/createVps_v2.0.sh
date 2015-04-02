#!/bin/bash


#-------------------------------------------------------------------------
# Déclaration des variables
#-------------------------------------------------------------------------

CTID="102";
ip_address="192.168.3.2";
name="MySQL";
FQDN="MySQL";
template="debian-7.0-x86_64";
Volume="SrvMySQL";

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