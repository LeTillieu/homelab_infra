# Introduction

L'objectif de ce repo est de mettre à disposition les ressource permettant la reinstallation de mon homelab. Il contient l'ensemble des fichier terraform et anssible nécessaires, ainsi que une pipeline CICD.

# Architecture globale
## Résumé du matériel {#devices_list}
| Nom | RAM (Go) | CPU cores | GPU | Disque(Go) | Utilisation |
|---| --- | --- | --- | --- | --- |
| Tour | 16 | 12 | ✔ |  | Serveur proxmox |
| PC Omen | 8 | 4 | ❌ | 1000 | Node kubernetes |
| Raspbery pi 5 Model B 1.0 |  4 | 4 | ❌ | 32 | Infra générale |
| NAS Synology | | | | 11000 | Stockage des backups

## Cluster kubernetes
Le serveur proxmox contient les VM suivantes:
- k8s-ctrlplane-terraform-0 - 1 core - 2Go RAM - 32Go
- k8s-ctrlplane-terraform-1 - 1 core - 2Go RAM - 32Go
- k8s-ctrlplane-terraform-2 - 1 core - 2Go RAM - 32Go
- k8s-node-terraform-0 - 1 core - 7Go RAM - 200Go

Un plus de ces VM, le [PC Omen](#devices_list) sert de noeud sur ce cluster. L'ensemble du cluster est installé par le playbook [install_cluster.yaml](/ansible/install_cluster.yml).

## Stockage des données
Le homelab dispose également de sa base de données postgreSQL, qui est déployée sur la VM **postgres-terraform** sur proxmox. Cette VM dispose de 2cores, 1Go de RAM et 32Go de stockage.

Le homelab dispose également d'un NAS synology sur lequel il y a 4 disques (3\*3To et 1\*2To) configurés en [SHR](https://kb.synology.com/fr-fr/DSM/tutorial/What_is_Synology_Hybrid_RAID_SHR). Ce NAS sert à stocker les backups de volumes [longhorn]() ainsi que des fichiers.

# Kubernetes
Le cluster kubernetes sert à heberger les applications présentes dans le repo  [homelab_apps](https://github.com/LeTillieu/homelab_apps). La limite de ressources matériels disponibles ayant pour le moment été atteinte, certaines applications présentes sur ce repo ne sont pas installées sur le cluster.
L'ensemble des applications sont installées via argocd. Pour le moment seuls *jellyfin* et *monitoring* sont installés.
Après l'installation du cluster avec le playbook [install_cluster.yaml](/ansible/install_cluster.yml), les applications [sealedsecrets](/ansible/deploy_sealedsecrets.yml), [cert_manager](/ansible/deploy_certificate_manager.yml) et [argocd](/ansible/deploy_argocd.yml) sont installées.

## Utilité des différentes applications
- **Certificate manager**

Cette application permet la génération de certificats TLS sur le cluster. C'est particulèrement utile pour les ingress et ainsi assurer le chiffrement des communications jusqu'à l'entrée du cluster.
Afin de pouvoir générer des certificats en utillisant le challenge [DNS-01](https://medium.com/@csp33/building-my-first-go-project-a-cert-manager-webhook-for-duckdns-47db984f9bed), [cert-manager-webhook-duckdns](https://github.com/ebrianne/cert-manager-webhook-duckdns) est également installé.

cert-manager-webhook-duckdns va créer deux Issuers sur le cluster, qui pourront ensuite être utilisés dans la section issuerRef des ressources de types Certificate.

- **sealedsecrets**

Par défaut, les secrets kubernetes sont simplement encodé en base64 dans les fichiers yaml. Ce type d'encodage ne sécurise en rien les données et ne permets donc pas leurs stockages publiquement sur git.
Sealedsecrets permet de générer automatiquement des couples de clés qui servent à chiffrer les secret.
La clé publique utilisée pour chiffrer les secrets sur le cluster est [sealed_secret_public_key.pem](/sealed_secret_public_key.pem). La clé privée correspondante est quant à elle stockée dans un secret github et redéployée pendant l'installation. 

- **argocd**

ArgoCD est un outils gitops permettant le déploiement et la mise à jour d'applications sur git en se basant sur des fichiers yaml.

Ces fichiers se trouves dans le repertoire [/ansible/files/argocd/](/ansible/files/argocd/) et permettent la configuration des différents users et repo pour que les applications puissent être déployée automatiquement.

L'avantage de cette solution est qu'en activant l'option de synchronisation automatique, il est possible de pousser des mises à jour aux applications simplement en modifiant un fichier de config sur git.

- **longhorn** {#longhorn}

Longhorn est un outils qui permet de répliquer des volumes sur plusieurs nodes (=meilleur résiliance) et de planifier des backups régulières et leur export sur des stockage externe.

# Stockage des données

Sur le cluster, tous les repertoires de configuration des applications sont stockés sur des volumes [longhorn](#longhorn). Ainsi ils sont régulièremement sauvegardé et le remplacement d'un pod n'engendre pas la perte des configurations.
