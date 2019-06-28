FROM httpd:2.4

LABEL maintainer="PCSOFT <network@pcsoft.fr>"

# Version de webdev
ENV WEBDEVVersion=24
ENV WEBDEVVersionRepertoire=${WEBDEVVersion}.0

# Attention, la variable d'environnement WEBDEVConfiguration est utilisée par le site WDAdminWeb :
# - Pour détecter sont exécution dans un conteneur.
# - Pour definir la racine des comptes créé.
ENV WEBDEVBinaries=/usr/local/WEBDEV/${WEBDEVVersionRepertoire}/ \
	WEBDEVConfiguration=/var/lib/WEBDEV/${WEBDEVVersionRepertoire}/ \
	WEBDEVRegistreBase="/etc/PC SOFT/WEBDEV/"

# Installation du serveur d'applications :
# - Déclaration des dépendances
# - Téléchargement de l'installation :
# => Installation de wget.
# => Téléchargement de l'archive d'installation.
# => Vérification du téléchargement.
# - Extraction de l'installation :
# => Extraction de l'installation 64bits depuis l'archive.
# => Fixe les droits d'exécution de l'installeur.
# - Création des répertoires et des liens symboliques. La configuration du serveur d'application WEBDEV est redirigé vers un répertoire unique pour avoir une persistance.
# - Exécution du programme d'installation.
# - Copie des droits et déplacement des fichiers des comptes.
# - Ajout de l'utilisateur et du groupe webdevuser.
# - Installation des dépendances (techniquement libqtcore et libfreetype sont des dépendances de libqtgui)
# - Nettoyage :
# => Suppression des fichiers d'installation.
# => Desinstallation de wget.
# => Nettoyage des fichiers de apt.
RUN set -ex \
	&& sDependancesInstallation='ca-certificates wget unzip' \
	&& sDependancesExecution='libfreetype6 libqtcore4 libqtgui4' \
	&& apt-get update \
	&& apt-get install -y $sDependancesInstallation --no-install-recommends \
	&& wget -nv -O WEBDEV_Install3264.zip https://package.windev.com/pack/wx24/install/wx24_75n/fr/WBDEP24LINUXPACKDVD075n.zip \
	&& echo "280c49cf2b4f8de42842f913aa251a0afbf8aeacdfe55340c6b2ee2a0ac7d12f *WEBDEV_Install3264.zip" | sha256sum -c - \
	&& unzip -b -j WEBDEV_Install3264.zip Linux64x86/* \
	&& chmod 550 webdev_install64 \
	&& mkdir -p ${WEBDEVConfiguration}comptes ${WEBDEVConfiguration}conf ${WEBDEVConfiguration}httpd "${WEBDEVRegistreBase}" \
	&& ln -s ${WEBDEVConfiguration}conf "${WEBDEVRegistreBase}${WEBDEVVersionRepertoire}" \
	&& ./webdev_install64 --docker \
	&& chmod --reference=${WEBDEVBinaries}WDAdminWeb ${WEBDEVConfiguration}comptes \
	&& chown --reference=${WEBDEVBinaries}WDAdminWeb ${WEBDEVConfiguration}comptes \
	&& mv ${WEBDEVBinaries}WDAdminWeb/wbcompte.* ${WEBDEVConfiguration}comptes \
	&& groupadd -r webdevuser --gid=4999 \
	&& useradd -r -g webdevuser --uid=4999 webdevuser \
	&& apt-get install -y $sDependancesExecution --no-install-recommends \
	&& rm -rf webdev_install64 WEBDEV_Install.zip WEBDEV_Install3264.zip \
	&& apt-get purge -y --auto-remove $sDependancesInstallation \
	&& rm -rf /var/lib/apt/lists/*

# Lancement du serveur d'application
# Il n'est pas possible d'utiliser ${WEBDEVBinaries} : la valeur n'est pas remplacée.
ENTRYPOINT ["/usr/local/WEBDEV/24.0/wd240admind", "--docker"]
#CMD []
