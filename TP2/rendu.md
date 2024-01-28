# TP2 : Appréhension d'un système Linux

# Partie 1 - Files and users

- [Partie : Files and users](#partie--files-and-users)
- [I. Fichiers](#i-fichiers)
  - [1. Find me](#1-find-me)
- [II. Users](#ii-users)
  - [1. Nouveau user](#1-nouveau-user)
  - [2. Infos enregistrées par le système](#2-infos-enregistrées-par-le-système)
  - [3. Hint sur la ligne de commande](#3-hint-sur-la-ligne-de-commande)
  - [3. Connexion sur le nouvel utilisateur](#3-connexion-sur-le-nouvel-utilisateur)

# I. Fichiers

## 1. Find me

🌞 **Trouver le chemin vers le répertoire personnel de votre utilisateur**

```bash
/home/et0
```

🌞 **Trouver le chemin du fichier de logs SSH**

```bash
/var/log/secure
```

🌞 **Trouver le chemin du fichier de configuration du serveur SSH**

```bash
/etc/ssh/sshd_config
```

# II. Users

## 1. Nouveau user

🌞 **Créer un nouvel utilisateur**

```bash
[et0@TP2 ~]$ sudo adduser marmotte
[et0@TP2 ~]$ sudo passwd marmotte
Changing password for user marmotte.
New password: 
BAD PASSWORD: The password fails the dictionary check - it is based on a dictionary word
Retype new password: 
passwd: all authentication tokens updated successfully.
[et0@TP2 home]$ sudo mv /home/marmotte /home/papier_alu
[et0@TP2 home]$ sudo chown -R marmotte /home/papier_alu
[et0@TP2 home]$ ls
et0  papier_alu
```

## 2. Infos enregistrées par le système

🌞 **Prouver que cet utilisateur a été créé**

```bash
[et0@TP2 home]$ sudo cat /etc/passwd | grep marmotte
marmotte:x:1001:1001::/home/marmotte:/bin/bash
```

🌞 **Déterminer le *hash* du password de l'utilisateur `marmotte`**

```bash
[et0@TP2 etc]$ sudo cat shadow | grep marmotte
marmotte:$6$GS74rJj6cjlSz8Hd$3mQTwrP.2Brhvp1xInEJTwarOhpWwD2t82aoricrhZFzqbxmMElBugQ6SMec0/FiOpiJcNVRYKizm2xO.MpJl.:19744:0:99999:7:::
```

## 3. Connexion sur le nouvel utilisateur

🌞 **Tapez une commande pour vous déconnecter : fermer votre session utilisateur**

```bash
[et0@TP2 home]$ logout
```

🌞 **Assurez-vous que vous pouvez vous connecter en tant que l'utilisateur `marmotte`**

```bash
[marmotte@TP2 home]$ ls et0
ls: cannot open directory 'et0': Permission denied
```

# Partie 2 : Programmes et paquets

- [Partie 2 : Programmes et paquets](#partie-2--programmes-et-paquets)
- [I. Programmes et processus](#i-programmes-et-processus)
  - [1. Run then kill](#1-run-then-kill)
  - [2. Tâche de fond](#2-tâche-de-fond)
  - [3. Find paths](#3-find-paths)
  - [4. La variable PATH](#4-la-variable-path)
- [II. Paquets](#ii-paquets)

# I. Programmes et processus

## 1. Run then kill

🌞 **Lancer un processus `sleep`**

```bash
[et0@TP2 ~]$ sleep 1000
```

```bash
[et0@TP2 ~]$ ps -fe | grep sleep
et0         1366    1294  0 10:18 pts/0    00:00:00 sleep 1000
```

🌞 **Terminez le processus `sleep` depuis le deuxième terminal**

```bash
[et0@TP2 ~]$ kill 1366
```

## 2. Tâche de fond

🌞 **Lancer un nouveau processus `sleep`, mais en tâche de fond**

```bash
[et0@TP2 ~]$ sleep 1000&
[1] 1388
```

🌞 **Visualisez la commande en tâche de fond**

```bash
[et0@TP2 ~]$ ps -fe | grep sleep
et0         1388    1294  0 10:27 pts/0    00:00:00 sleep 1000
```

## 3. Find paths

➜ La commande `sleep`, comme toutes les commandes, c'est un programme

- sous Linux, on met pas l'extension `.exe`, s'il y a pas d'extensions, c'est que c'est un exécutable généralement

🌞 **Trouver le chemin où est stocké le programme `sleep`**

```bash
[et0@TP2 /]$ ls -al /usr/bin | grep sleep
-rwxr-xr-x.  1 root root   68896 Apr 24  2023 sleep
```

🌞 Tant qu'on est à chercher des chemins : **trouver les chemins vers tous les fichiers qui s'appellent `.bashrc`**

```bash
[et0@TP2 ~]$ find / -name .bashrc 2>/dev/null
/etc/skel/.bashrc
/home/et0/.bashrc
```

## 4. La variable PATH

**Sur tous les OS (MacOS, Windows, Linux, et autres) il existe une variable `PATH` qui est définie quand l'OS démarre.** Elle est accessible par toutes les applications qui seront lancées sur cette machine.

**On dit que `PATH` est une variable d'environnement.** C'est une variable définie par l'OS, et accessible par tous les programmes.

> *Il existe plein de variables d'environnement définie dès que l'OS démarre, `PATH` n'est pas la seule. On peut aussi en créer autant qu'on veut. Attention, suivant avec quel utilisateur on se connecte à une machine, les variables peuvent être différentes : parfait pour avoir chacun sa configuration !*

**`PATH` contient la liste de tous les dossiers qui contiennent des commandes/programmes.**

Ainsi quand on tape une commande comme `ls /home`, il se passe les choses suivantes :

- votre terminal consulte la valeur de la variable `PATH`
- parmi tous les dossiers listés dans cette variable, il cherche s'il y en a un qui contient un programme nommé `ls`
- si oui, il l'exécute
- sinon : `command not found`

Démonstration :

```bash
# on peut afficher la valeur de la variable PATH à n'importe quel moment dans un terminal
$ echo $PATH
/usr/local/sbin:/usr/local/bin:/usr/bin:/bin
# ça contient bien une liste de dossiers, séparés par le caractère ":"

# si la commande ls fonctionne c'est forcément qu'elle se trouve dans l'un de ces dossiers
# on peut savoir lequel avec la commande which qui interroge aussi la variable PATH
$ which ls
/usr/bin/ls
```

🌞 **Vérifier que**

```bash
[et0@TP2 ~]$ echo $PATH
/home/et0/.local/bin:/home/et0/bin:/usr/local/bin:/usr/bin:/usr/local/sbin:/usr/sbin
[et0@TP2 ~]$ which sleep
/usr/bin/sleep
[et0@TP2 ~]$ which ssh
/usr/bin/ssh
[et0@TP2 ~]$ which ping
/usr/bin/ping
```

# II. Paquets

➜ **Tous les OS Linux sont munis d'un store d'application**

- c'est natif
- quand tu fais `apt install` ou `dnf install`, ce genre de commandes, t'utilises ce store
- on dit que `apt` et `dnf` sont des gestionnaires de paquets
- ça permet aux utilisateurs de télécharger des nouveaux programmes (ou d'autres trucs) depuis un endroit safe

🌞 **Installer le paquet `git`**

```bash
[et0@TP2 ~]$ sudo dnf install git
[sudo] password for et0: 
```

🌞 **Utiliser une commande pour lancer git**

```bash
[et0@TP2 ~]$ which git
/usr/bin/git
```

🌞 **Installer le paquet `nginx`**

```bash
sudo dnf install nginx
```

🌞 **Déterminer**

```bash
/var/log/nginx/
```
```bash
/etc/nginx/
```

🌞 **Mais aussi déterminer...**

- l'adresse `http` ou `https` des serveurs où vous téléchargez des paquets
- une commande `apt install` ou `dnf install` permet juste de faire un téléchargement HTTP
- ma question c'est donc : sur quel URL tu t'es connecté pour télécharger ce paquet
- il existe un dossier qui contient la liste des URLs consultées quand vous demandez un téléchargement de paquets

# Partie 3 : Poupée russe

Pour finir de vous exercer avec le terminal, je vous ai préparé une poupée russe :D

➜ **De mon côté, pour préparer l'exercice :**

- j'ai créé un dossier `dawa/`, qui a plein de sous-dossiers, sous-fichiers, etc
  - y'a des fichiers particuliers, les autres c'est juste du random
- je l'ai archivé/compressé plusieurs fois
- j'ai volontairement supprimé les extensions des fichiers compressés
  - comme ça tu peux pas savoir à l'aide du nom si c'est un `.zip` ou un autre format

➜ **Le but de l'exercice pour vous :**

- je vous file le fichier que j'ai compressé/archivé plusieurs fois, que vous téléchargez dans la VM
- vous devez :
  - déterminer le type du fichier
  - renommer le fichier correctement (si c'est une archive zip, il faut ajouter `.zip` à son nom)
  - extraire l'archive
  - répéter l'opération (car j'ai mis une archive, dans une archive, dans une archive... meow)
- bien sûr que c'est stupide
  - mais c'est pour vous faire pratiquer le terminal, et voir des commandes usuelles
- une fois que vous avez trouvé le dossier `dawa/`, vous avez fini le jeu de poupées russes
- vous allez devoir trouver les fichiers spécifiques que je vous demande à l'intérieur de ce dossier

🌞 **Récupérer le fichier `meow`**

- téléchargez-le à l'aide d'une commande

🌞 **Trouver le dossier `dawa/`**

```bash
[et0@TP2 ~]$ file meow
meow: Zip archive data, at least v2.0 to extract
[et0@TP2 ~]$ mv meow meow.zip
[et0@TP2 ~]$ ls
meow.zip
[et0@TP2 ~]$ sudo dnf install unzip
[et0@TP2 ~]$ unzip meow.zip
[et0@TP2 ~]$ rm meow.zip
```
```bash
[et0@TP2 ~]$ file meow
meow: XZ compressed data
[et0@TP2 ~]$ mv meow meow.xz
[et0@TP2 ~]$ ls
meow.xz
[et0@TP2 ~]$ sudo dnf install tar
[et0@TP2 ~]$ xz -d meow.xz
[et0@TP2 ~]$ ls
meow
```
```bash
[et0@TP2 ~]$ file meow
meow: bzip2 compressed data, block size = 900k
[et0@TP2 ~]$ mv meow meow.bz2
[et0@TP2 ~]$ ls
meow.bz2
[et0@TP2 ~]$ sudo dnf install bzip2
[et0@TP2 ~]$ bzip2 -d meow.bz2
```
```bash
[et0@TP2 ~]$ file meow
meow: RAR archive data, v5
[et0@TP2 ~]$ mv meow meow.rar
[et0@TP2 ~]$ ls
meow.rar
```

🌞 **Dans le dossier `dawa/`, déterminer le chemin vers**

- le seul fichier de 15Mo
- le seul fichier qui ne contient que des `7`
- le seul fichier qui est nommé `cookie`
- le seul fichier caché (un fichier caché c'est juste un fichier dont le nom commence par un `.`)
- le seul fichier qui date de 2014
- le seul fichier qui a 5 dossiers-parents
  - je pense que vous avez vu que la structure c'est 50 `folderX`, chacun contient 50 dossiers `X`, et chacun contient 50 `fileX`
  - bon bah là y'a un fichier qui est contenu dans `folderX/X/X/X/X/` et c'est le seul qui 5 dossiers parents comme ça


