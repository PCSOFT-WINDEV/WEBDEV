FROM httpd:2.4

LABEL maintainer="PCSOFT <network@pcsoft.fr>"

# Version de webdev
ENV WEBDEVVersion=24
ENV WEBDEVVersionRepertoire=${WEBDEVVersion}.0

# Attention, la la variable d'environnement WEBDEVConfiguration est utilis�e par le site WDAdminWeb :
# - Pour d�tecter sont ex�cution dans un conteneur.
# - Pour definir la racine des comptes cr��.
ENV WEBDEVBinaries=/usr/local/WEBDEV/${WEBDEVVersionRepertoire}/ \
	WEBDEVConfiguration=/var/lib/WEBDEV/${WEBDEVVersionRepertoire}/ \
	WEBDEVRegistreBase="/etc/PC SOFT/WEBDEV/"

# Installation du serveur d'applications :
# - D�claration des d�pendances
# - T�l�chargement de l'installation :
# => Installation de wget.
# => T�l�chargement de l'archive d'installation.
# => V�rification du t�l�chargement.
# - Extraction de l'installation :
# => Extraction de l'installation 64bits depuis l'archive.
# => Fixe les droits d'ex�cution de l'installeur.
# - Cr�ation des r�pertoires et des liens symboliques. La configuration du serveur d'application WEBDEV est redirig� vers un r�pertoire unique pour avoir une persistance.
# - Ex�cution du programme d'installation.
# - Copie des droits et d�placement des fichiers des comptes.
# - Ajout de l'utilisateur et du groupe webdevuser.
# - Installation des d�pendances (techniquement libqtcore et libfreetype sont des d�pendances de libqtgui)
# - Nettoyage :
# => Suppression des fichiers d'installation.
# => Desinstallation de wget.
# => Nettoyage des fichiers de apt.
RUN set -ex \
	&& sDependancesInstallation='ca-certificates wget unzip' \
	&& sDependancesExecution='libfreetype6 libqtcore4 libqtgui4' \
	&& apt-get update \
	&& apt-get install -y $sDependancesInstallation --no-install-recommends \
	&& wget -nv -O WEBDEV_Install3264.zip https://package.windev.com/pack/wx24/install/fr/WD240PACKDVDDEPLINUX054v.zip \
	&& echo "0a6a40818d7f964a4f7765fc18536b45b3880a87c481a6fc7bef3edea31bf13f *WEBDEV_Install3264.zip" | sha256sum -c - \
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

# Cr�ation de la persistance
VOLUME ${WEBDEVConfiguration}

# Lancement du serveur d'application
# Il n'est pas possible d'utiliser ${WEBDEVBinaries} : la valeur n'est pas remplac�e.
ENTRYPOINT ["/usr/local/WEBDEV/24.0/wd240admind", "--docker"]
#CMD []
