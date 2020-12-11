FROM httpd:2.4

LABEL maintainer="PCSOFT <network@pcsoft.fr>"

# Version de WEBDEV
ENV WEBDEVVersion=26
ENV WEBDEVVersionRepertoire=${WEBDEVVersion}.0

# Attention, la variable d'environnement WEBDEVConfiguration est utilisée par le site WDAdminWeb :
# - Pour détecter son exécution dans un conteneur.
# - Pour définir la racine des comptes créés.
ENV WEBDEVBinaries=/usr/local/WEBDEV/${WEBDEVVersionRepertoire}/ \
	WEBDEVConfiguration=/var/lib/WEBDEV/${WEBDEVVersionRepertoire}/ \
	WEBDEVRegistreBase="/etc/PC SOFT/WEBDEV/"

# Installation du Serveur d'application WEBDEV :
# - Déclaration des dépendances
# - Téléchargement de l'installation :
# => Installation de wget.
# => Téléchargement de l'archive d'installation.
# => Vérification du téléchargement.
# - Extraction de l'installation :
# => Extraction de l'installation 64bits depuis l'archive.
# => Fixation des droits d'exécution de l'installeur.
# - Création des répertoires et des liens symboliques. La configuration du Serveur d'application WEBDEV est redirigée vers un répertoire unique pour être persistante.
# - Exécution du programme d'installation.
# - Copie des droits et déplacement des fichiers de comptes.
# - Ajout de l'utilisateur et du groupe webdevuser.
# - Installation des dépendances (techniquement libqtcore et libfreetype sont des dépendances de libqtgui).
# - Nettoyage :
# => Suppression des fichiers de l'installation.
# => Désinstallation de wget.
# => Nettoyage des fichiers de apt.
RUN set -ex \
	&& sDependancesInstallation='ca-certificates wget unzip' \
	&& sDependancesExecution='libfreetype6 libqtcore4 libqtgui4' \
	&& apt-get update \
	&& apt-get install -y $sDependancesInstallation --no-install-recommends \
	&& wget -nv -O WEBDEV_Install3264.zip https://package.windev.com/pack/wx26/install/wx26_56p/fr/WBDEP26LINUXPACKDVD056p.zip \
	&& echo "2961ea5ecb026af8fe10dc537d953019f55db34c7457af980f21add169fa28a2 *WEBDEV_Install3264.zip" | sha256sum -c - \
	&& unzip -b -j WEBDEV_Install3264.zip Linux64x86/* \
	&& chmod 550 webdev_install64 \
	&& mkdir -p ${WEBDEVConfiguration}comptes ${WEBDEVConfiguration}conf ${WEBDEVConfiguration}httpd "${WEBDEVRegistreBase}" \
	&& ln -s ${WEBDEVConfiguration}conf "${WEBDEVRegistreBase}${WEBDEVVersionRepertoire}" \
	&& ./webdev_install64 --docker \
	&& chmod --reference=${WEBDEVBinaries}WDAdminWeb ${WEBDEVConfiguration}comptes \
	&& chown --reference=${WEBDEVBinaries}WDAdminWeb ${WEBDEVConfiguration}comptes \
	&& apt-get install -y $sDependancesExecution --no-install-recommends \
	&& rm -rf webdev_install64 WEBDEV_Install.zip WEBDEV_Install3264.zip \
	&& apt-get purge -y --auto-remove $sDependancesInstallation \
	&& rm -rf /var/lib/apt/lists/*

# Lancement du Serveur d'application WEBDEV. 
# Il n'est pas possible d'utiliser ${WEBDEVBinaries} : la valeur n'est pas remplacée.
ENTRYPOINT ["/usr/local/WEBDEV/26.0/wd260admind", "--docker"]
#CMD []
