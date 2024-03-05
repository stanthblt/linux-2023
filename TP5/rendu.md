# Partie 1 : Script carte d'identité

Vous allez écrire **un script qui récolte des informations sur le système et les affiche à l'utilisateur.** Il s'appellera `idcard.sh` et sera stocké dans `/srv/idcard/idcard.sh`.

> `.sh` est l'extension qu'on donne par convention aux scripts réalisés pour être exécutés avec `sh` ou `bash`.

➜ **L'emoji 🐚** est une aide qui indique une commande qui est capable de réaliser le point demandé

➜ **Testez les commandes à la main avant de les incorporer au script.**

➜ Ce que doit faire le script. Il doit afficher :

- le **nom de la machine**
  - 🐚 `hostnamectl`
- le **nom de l'OS** de la machine
  - regardez le fichier `/etc/redhat-release` ou `/etc/os-release`
  - 🐚 `source`
- la **version du noyau** Linux utilisé par la machine
  - 🐚 `uname`
- l'**adresse IP** de la machine
  - 🐚 `ip`
- l'**état de la RAM**
  - 🐚 `free`
  - espace dispo en RAM (en Go, Mo, ou Ko)
  - taille totale de la RAM (en Go, Mo, ou Ko)
- l'**espace restant sur le disque dur**, en Go (ou Mo, ou Ko)
  - donnez moi l'espace restant sur la partition `/`
  - 🐚 `df`
- le **top 5 des processus** qui pompent le plus de RAM sur la machine actuellement. Procédez par étape :
  - 🐚 `ps`
  - listez les process
  - affichez uniquement le nom du processus (voir exemple ci-dessous)
  - triez par RAM utilisée
  - isolez les 5 premiers
- la **liste des ports en écoute** sur la machine, avec le programme qui est derrière
  - préciser, en plus du numéro, s'il s'agit d'un port TCP ou UDP
  - 🐚 `ss`
  - je vous recommande d'utiliser une [syntaxe `while read`](../../cours/scripting/README.md#8-itérer-proprement-sur-plusieurs-lignes)
- la liste des dossiers disponibles dans la variable `$PATH`
- un **lien vers une image/gif** random de chat
  - 🐚 `curl`
  - il y a de très bons sites pour ça hihi
  - avec [celui-ci](https://thecatapi.com/) par exemple, une simple requête HTTP vous retourne l'URL d'une random image de chat
    - une requête sur cette adresse retourne directement l'image, il faut l'enregistrer dans un fichier
    - parfois le fichier est un JPG, parfois un PNG, parfois même un GIF
    - 🐚 `file` peut vous aider à déterminer le type de fichier

Pour vous faire manipuler les sorties/entrées de commandes, votre script devra sortir **EXACTEMENT** :

```
$ /srv/idcard/idcard.sh
Machine name : ...
OS ... and kernel version is ...
IP : ...
RAM : ... memory available on ... total memory
Disk : ... space left
Top 5 processes by RAM usage :
  - python3
  - NetworkManager
  - systemd
  - ...
  - ...
Listening ports :
  - 22 tcp : sshd
  - ...
  - ...
PATH directories :
  - /usr/local/bin
  - ...
  - ...

Here is your random cat (jpg file) : https://....
```

## Rendu

📁 **Fichier `/srv/idcard/idcard.sh`**

🌞 **Vous fournirez dans le compte-rendu Markdown**, en plus du fichier, **un exemple d'exécution avec une sortie**

- genre t'exécutes ton script et tu copie/colles ça dans le compte-rendu

```sh
#!/usr/bin/bash
# et0
# 23/02/2024

hostname="$(hostnamectl | grep Static | cut -d' ' -f4)"
echo "Machine name : ${hostname}"

name="$(source /etc/os-release && echo $NAME)"
version="$(source /etc/os-release && echo $VERSION)"
echo "OS ${name} and kernel version is ${version}"

ip="$(ip a | grep "inet " | sed -n 2p | tr -s ' ' | cut -d' ' -f3)"
echo "IP : ${ip}"

ram_total="$(free | grep Mem | tr -s ' ' | cut -d' ' -f2)"
ram_free="$(free | grep Mem | tr -s ' ' | cut -d' ' -f4)"
echo "RAM : ${ram_free} memory available on ${ram_total} total memory"

disk="$(df -h / | awk 'NR==2 {print $4}')"
echo "Disk : ${disk} space left"

process="$(ps aux --sort=-%mem | awk 'NR<=6 && NR>1 {print "  - " $11}')"
echo -e "Top 5 processes by RAM usage : \n${process}"

ports="$(ss -tuln | awk '/^tcp/ {print "  - " $4 " : " $6}' | sed 's/\(.*\):\(.*\)/\1 tcp : \2/' && ss -uln | awk '/^udp/ {print "  - " $4 " : " $5}' | sed 's/\(.*\):\(.*\)/\1 udp : \2/')"
echo -e "Listening ports : \n${ports}"

path="$(IFS=: read -ra path_dirs <<< "$PATH" && printf "  - %s\n" "${path_dirs[@]}")"
echo -e "PATH directories : \n${path}"

json_data=$(curl -s "https://api.thecatapi.com/v1/images/search")
url=$(echo "$json_data" | grep -o '"url": *"[^"]*"' | cut -d '"' -f 4)
echo -e "Here is your random cat (jpg file) :\n${url}"
```

```bash
[et0@web ~]$ ./test.sh
Machine name : web.tp4.linux
OS Rocky Linux and kernel version is 9.2 (Blue Onyx)
IP : 10.1.1.12/24
RAM : 119096 memory available on 718820 total memory
Disk : 4.2G space left
Top 5 processes by RAM usage :
  - /home/et0/.vscode-server/bin/903b1e9d8990623e3d7da1df3d33db3e42d80eda/node
  - /home/et0/.vscode-server/bin/903b1e9d8990623e3d7da1df3d33db3e42d80eda/node
  - /home/et0/.vscode-server/bin/903b1e9d8990623e3d7da1df3d33db3e42d80eda/node
  - /home/et0/.vscode-server/bin/903b1e9d8990623e3d7da1df3d33db3e42d80eda/node
  - /usr/bin/python3
Listening ports :
  - 128 : 0.0.0.0 tcp : *
  - 4096 : 0.0.0.0 tcp : *
  - 511 : 0.0.0.0 tcp : *
  - 128 : [::] tcp : *
  - 4096 : [::] tcp : *
PATH directories :
  - /home/et0/.local/bin
  - /home/et0/bin
  - /usr/local/bin
  - /usr/bin
  - /usr/local/sbin
  - /usr/sbin
Here is your random cat (jpg file) :
https://cdn2.thecatapi.com/images/MTcyMTY5NA.jpg
```

```sh
[et0@web yt]$ sudo cat /srv/yt/yt.sh
#!/bin/bash

video_url="$1"

download_dir="/srv/yt/downloads"

log_dir="/var/log/yt"

log_file="$log_dir/download.log"

if [ ! -d "$log_dir" ]; then
    sudo mkdir -p "$log_dir"
fi

if [ ! -d "$download_dir" ]; then
    echo "Error: Download directory $download_dir does not exist. Exiting."
    exit 1
fi

youtube_dl_path="/usr/local/bin/youtube-dl"  # Replace with the actual path

youtube_dl_command="cd $download_dir && sudo $youtube_dl_path $video_url"

download_output=$(eval "$youtube_dl_command" 2>&1)

timestamp=$(date +"%y/%m/%d %H:%M:%S")
log_line="[$timestamp] Video $video_url was downloaded. File path : $download_output"
echo "$log_line" | sudo tee -a "$log_file" > /dev/null

echo "$log_line"
```

```bash
[et0@web yt]$ sudo cat /var/log/yt/download.log | tail -n 3
[24/03/03 20:01:10] Video https://www.youtube.com/watch?v=Dst9gZkq1a8 was downloaded. File path : [youtube] Dst9gZkq1a8: Downloading webpage
[download] Destination: Travis Scott - goosebumps ft. Kendrick Lamar-Dst9gZkq1a8.mp4
[download] 100% of 15.82MiB in 00:0071MiB/s ETA 00:00known ETA
```

## 2. MAKE IT A SERVICE

### A. Adaptation du script

YES. Yet again. **On va en faire un _service_.**

L'idée :

➜ plutôt que d'appeler la commande à la main quand on veut télécharger une vidéo, **on va créer un service qui les téléchargera pour nous**

➜ **le service s'exécute en permanence en tâche de fond**

- il surveille un fichier précis
- s'il trouve une nouvelle ligne dans le fichier, il vérifie que c'est bien une URL de vidéo youtube
  - si oui, il la télécharge, puis enlève la ligne
  - sinon, il enlève juste la ligne

➜ **qui écrit dans le fichier pour ajouter des URLs ? Bah vous !**

- vous pouvez écrire une liste d'URL, une par ligne, et le service devra les télécharger une par une

---

Pour ça, procédez par étape :

- **partez de votre script précédent** (gardez une copie propre du premier script, qui doit être livré dans le dépôt git)
  - le nouveau script s'appellera `yt-v2.sh`
- **adaptez-le pour qu'il lise les URL dans un fichier** plutôt qu'en argument sur la ligne de commande
- **faites en sorte qu'il tourne en permanence**, et vérifie le contenu du fichier toutes les X secondes
  - boucle infinie qui :
    - lit un fichier
    - effectue des actions si le fichier n'est pas vide
    - sleep pendant une durée déterminée
- **il doit marcher si on précise une vidéo par ligne**
  - il les télécharge une par une
  - et supprime les lignes une par une

### B. Le service

➜ **une fois que tout ça fonctionne, enfin, créez un service** qui lance votre script :

- créez un fichier `/etc/systemd/system/yt.service`. Il comporte :
  - une brève description
  - un `ExecStart` pour indiquer que ce service sert à lancer votre script
  - une clause `User=` pour indiquer que c'est l'utilisateur `yt` qui lance le script
    - créez l'utilisateur s'il n'existe pas
    - faites en sorte que le dossier `/srv/yt` et tout son contenu lui appartienne
    - le dossier de log doit lui appartenir aussi
    - l'utilisateur `yt` ne doit pas pouvoir se connecter sur la machine

```bash
[Unit]
Description=<Votre description>

[Service]
ExecStart=<Votre script>
User=yt

[Install]
WantedBy=multi-user.target
```

> Pour rappel, après la moindre modification dans le dossier `/etc/systemd/system/`, vous devez exécuter la commande `sudo systemctl daemon-reload` pour dire au système de lire les changements qu'on a effectué.

Vous pourrez alors interagir avec votre service à l'aide des commandes habituelles `systemctl` :

- `systemctl status yt`
- `sudo systemctl start yt`
- `sudo systemctl stop yt`

> ⚠️ **Votre script doit fonctionner peu importe les conditions** : peu importe le nom de la machine, ou son adresse IP (genre il est interdit de récupérer pile 10 char sous prétexte que ton adresse IP c'est `10.10.10.1` et qu'elle fait 10 char de long)

### C. Rendu

📁 **Le script `/srv/yt/yt-v2.sh`**

📁 **Fichier `/etc/systemd/system/yt.service`**

🌞 Vous fournirez dans le compte-rendu, en plus des fichiers :

- un `systemctl status yt` quand le service est en cours de fonctionnement
- un extrait de `journalctl -xe -u yt`

> Hé oui les commandes `journalctl` fonctionnent sur votre service pour voir les logs ! Et vous devriez constater que c'est vos `echo` qui pop. En résumé, **le STDOUT de votre script, c'est devenu les logs du service !**

🌟**BONUS** : get fancy. Livrez moi un gif ou un [asciinema](https://asciinema.org/) (PS : c'est le feu asciinema) de votre service en action, où on voit les URLs de vidéos disparaître, et les fichiers apparaître dans le fichier de destination

```sh
[et0@web yt]$ sudo cat /srv/yt/yt-v2.sh
#!/bin/bash

download_dir="/srv/yt/downloads"

log_dir="/var/log/yt"

log_file="$log_dir/download.log"

if [ ! -d "$download_dir" ]; then
    echo "\e[31m\e[1mError :\e[0m Download directory \e[1m$download_dir\e[0m does not exist. Exiting."
    exit 1
fi

youtube_dl_path="/usr/local/bin/youtube-dl"

while true; do
    url=$(head -n 1 /srv/yt/url)

    if [ -n "$url" ]; then
        if [[ $url =~ ^https:\/\/www\.youtube\.com\/watch\?v=[a-zA-Z0-9]{11}.*$ ]]; then
            youtube_dl_command="cd $download_dir && $youtube_dl_path $url"

            download_output=$(eval "$youtube_dl_command" 2>&1)

            timestamp=$(date +"%y/%m/%d %H:%M:%S")
            log_line="[$timestamp] Video $url was downloaded. File path : $download_output"
            echo "$log_line" | tee -a "$log_file" > /dev/null

            sed -i '1d' /srv/yt/url
        else
            sed -i '1d' /srv/yt/url
	    echo -e "\e[31m\e[1mError :\e[0m Please enter a valid YouTube url.";
        fi
    fi

    sleep 60
done
```

```bash
[et0@web yt]$ sudo cat /etc/systemd/system/yt.service
[Unit]
Description=YouTube Download Service

[Service]
ExecStart=/srv/yt/yt-v2.sh
User=yt

[Install]
WantedBy=multi-user.target
```

```bash
[et0@web yt]$ systemctl status yt
● yt.service - YouTube Download Service
     Loaded: loaded (/etc/systemd/system/yt.service; enabled; preset: disabled)
     Active: active (running) since Sun 2024-03-03 23:07:03 CET; 6s ago
   Main PID: 5185 (yt-v2.sh)
      Tasks: 3 (limit: 4263)
     Memory: 185.3M
        CPU: 2.337s
     CGroup: /system.slice/yt.service
             ├─5185 /bin/bash /srv/yt/yt-v2.sh
             ├─5188 /bin/bash /srv/yt/yt-v2.sh
             └─5189 python /usr/local/bin/youtube-dl "https://www.youtube.com/watch?v=-udMxs4qDB8"

Mar 03 23:07:03 web.tp4.linux systemd[1]: Started YouTube Download Service.
```

```bash
[et0@web yt]$  journalctl -xe -u yt
Mar 03 23:07:03 web.tp4.linux systemd[1]: Started YouTube Download Service.
░░ Subject: A start job for unit yt.service has finished successfully
░░ Defined-By: systemd
░░ Support: https://access.redhat.com/support
░░
░░ A start job for unit yt.service has finished successfully.
░░
░░ The job identifier is 5980.
```
