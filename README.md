# Big Data MSPR

Ce projet permet le déploiement auto de l'infrastructure ETL utilisant la suite [Elastic](https://www.elastic.co/fr/).

## Déploiement

### Etape préliminaire 

Il est nécessaire de compléter le fichier `.env` en prenant exemple sur le fichier `.env.example`

### Déploiement 1er partie

* Se rendre dans le dossier `./terraform`
* Intialiser la première partie du projet : `terraform init` 
* Déployer cette première partie : `terraform apply -auto-approve`

### Déploiement 2e partie 

* Puis se rendre dans le dossier `docker/`
* Initialiser cette seconde partie du projet : `terraform init`
* Déployer cette partie : `terraform apply -auto-approve` 

## Explications

Le projet se découpe donc en deux parties :

* La première permet de créer le serveur accueillant les services
* La seconde permet de déployer les services avec Docker

Le serveur kibana est ensuite accessible à l'adresse suivante : `http://etl.fredericpinaud.ovh`

