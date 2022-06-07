FROM debian:buster-slim

LABEL maintainer="PCSOFT <network@pcsoft.fr>"

# Version de WEBDEV
ENV WEBDEVVersion=27
ENV WEBDEVVersionRepertoire=${WEBDEVVersion}.0

# Attention, la variable d'environnement WEBDEVConfiguration est utilisée par le site WDAdminWeb :
# - Pour détecter son exécution dans un conteneur.
# - Pour définir la racine des comptes créés.
ENV WEBDEVBinaries=/usr/local/WEBDEV/${WEBDEVVersionRepertoire}/ \
	WEBDEVConfiguration=/var/lib/WEBDEV/${WEBDEVVersionRepertoire}/ \
	WEBDEVRegistreBase="/etc/PC SOFT/WEBDEV/"

# Installation du Serveur d'application WEBDEV :
# - Déclaration des dépendances.
# => ca-certificates est conservé après l'installation pour permettre le fonctionnement de HttpRequête (et fonctions associées) en HTTPS.
# => apache2-bin est une dépendance de apache2 et de libapache2-mod-fcgid donc n'est pas déclarée.
# => libqt5core5a et libqt5gui5 sont dépendance de libqt5widgets5 donc ne sont pas déclarées (pareil pour libfreetype6 qui est une dépendance de libqt5gui5).
# - Téléchargement de l'installation :
# => Installation des dépendances d'installation (wget etc.).
# => Installation des dépendances d'exécution (en particulier apache doit être présent avant l'installation du serveur d'application).
# => Téléchargement de l'archive d'installation.
# => Vérification du téléchargement.
# - Extraction de l'installation :
# => Extraction de l'installation 64bits depuis l'archive.
# => Fixation des droits d'exécution de l'installeur.
# - Création des répertoires et des liens symboliques. La configuration du Serveur d'application WEBDEV est redirigée vers un répertoire unique pour être persistante.
# - Exécution du programme d'installation.
# - Copie des droits et déplacement des fichiers de comptes.
# - Ajout de l'utilisateur et du groupe webdevuser.
# - Création de httpd-foreground
# - Nettoyage :
# => Suppression des fichiers de l'installation.
# => Désinstallation de wget.
# => Nettoyage des fichiers de apt.
RUN set -ex \
	&& sDependancesInstallation='wget unzip' \
	&& sDependancesExecution='ca-certificates apache2 libapache2-mod-fcgid libqt5widgets5' \
	&& apt-get update \
	&& apt-get install -y $sDependancesInstallation --no-install-recommends \
	&& apt-get install -y $sDependancesExecution --no-install-recommends \
	&& wget -nv -O WEBDEV_Install3264.zip https://package.windev.com/pack/wx27/install/wx27_103s/us/WBDEP27LINUXPACKDVDUS103s.zip \
	&& echo "7454f7d7f1c7c2e1124e700f93df094b57b34556087e78cae9c3d1308c015eb2 *WEBDEV_Install3264.zip" | sha256sum -c - \
	&& unzip -b -j WEBDEV_Install3264.zip Linux64x86/* \
	&& chmod 550 webdev_install64 \
	&& mkdir -p ${WEBDEVConfiguration}comptes ${WEBDEVConfiguration}conf ${WEBDEVConfiguration}httpd "${WEBDEVRegistreBase}" \
	&& ln -s ${WEBDEVConfiguration}conf "${WEBDEVRegistreBase}${WEBDEVVersionRepertoire}" \
	&& ./webdev_install64 --docker \
	&& chmod --reference=${WEBDEVBinaries}WDAdminWeb ${WEBDEVConfiguration}comptes \
	&& chown --reference=${WEBDEVBinaries}WDAdminWeb ${WEBDEVConfiguration}comptes \
	&& rm -rf webdev_install64 WEBDEV_Install.zip WEBDEV_Install3264.zip \
	&& apt-get purge -y --auto-remove $sDependancesInstallation \
	&& rm -rf /var/lib/apt/lists/*

# Lancement du Serveur d'application WEBDEV. 
# Il n'est pas possible d'utiliser ${WEBDEVBinaries} : la valeur n'est pas remplacée.
ENTRYPOINT ["/usr/local/WEBDEV/27.0/wd270admind", "--docker"]
#CMD []
