# I. Service SSH

> Pour rappel : un *service* c'est juste un programme lancé par l'OS à notre place. Donc quand on dit qu'un "service tourne", ça veut concrètement dire qu'il y a un programme en cours d'exécution.

Le service SSH est déjà installé sur la machine, et il est aussi déjà démarré. C'est par défaut sur Rocky.

> *En effet Rocky c'est un OS qui est spécialisé pour faire tourner des serveurs. Pas choquant d'avoir un serveur SSH préinstallé et dispo dès l'installation pour pouvoir s'y connecter à distance ! Ce serait pas le cas sur un OS Ubuntu (par exemple) que vous installeriez sur votre PC. C'est pas le cas non plus sur un Windows 11 ou un MacOS ou un Android ouuuu... bref t'as capté. Mais sur n'importe lequel de ces OS, on peut **ajouter** un service SSH si on le souhaite.*

- [I. Service SSH](#i-service-ssh)
  - [1. Analyse du service](#1-analyse-du-service)
  - [2. Modification du service](#2-modification-du-service)

## 1. Analyse du service

On va, dans cette première partie, analyser le service SSH qui est en cours d'exécution.

🦦 **S'assurer que le service `sshd` est démarré**

```bash
[et0@TP2 ~]$ systemctl status | grep sshd
           │ ├─sshd.service
           │ │ └─659 "sshd: /usr/sbin/sshd -D [listener] 0 of 10-100 startups"
               │ ├─3106 "sshd: et0 [priv]"
               │ ├─3110 "sshd: et0@pts/1"
               │ └─3148 grep --color=auto sshd
               │ ├─1337 "sshd: et0 [priv]"
               │ ├─1341 "sshd: et0@pts/0"
```

🦦 **Analyser les processus liés au service SSH**

```bash
[et0@TP2 ~]$ ps -ef | grep sshd
root         659       1  0 Jan28 ?        00:00:00 sshd: /usr/sbin/sshd -D [listener] 0 of 10-100 startups
root        1337     659  0 Jan28 ?        00:00:00 sshd: et0 [priv]
et0         1341    1337  0 Jan28 ?        00:00:00 sshd: et0@pts/0
root        3106     659  0 00:36 ?        00:00:00 sshd: et0 [priv]
et0         3110    3106  0 00:36 ?        00:00:00 sshd: et0@pts/1
et0         3153    3111  0 00:41 pts/1    00:00:00 grep --color=auto sshd
```

```bash
# Exemple de manipulation de | grep

# admettons un fichier texte appelé "fichier_demo"
# on peut afficher son contenu avec la commande cat :
$ cat fichier_demo
bob a un chapeau rouge
emma surfe avec un dinosaure
eve a pas toute sa tête

# il est possible de filtrer la sortie de la commande cat pour afficher uniquement certaines lignes
$ cat fichier_demo | grep emma
emma surfe avec un dinosaure

$ cat fichier_demo | grep bob
bob a un chapeau rouge
```

> Il est possible de repérer le numéro des processus liés à un service avec la commande `systemctl status sshd`.

🦦 **Déterminer le port sur lequel écoute le service SSH**

```bash
[et0@TP2 ~]$ ss | grep ssh
tcp   ESTAB  0      52                        10.1.1.11:ssh          10.1.1.10:58836        
tcp   ESTAB  0      0                         10.1.1.11:ssh          10.1.1.10:53871
```

🦦 **Consulter les logs du service SSH**

```bash
[et0@TP2 ~]$ journalctl | grep ssh
```
```bash
[et0@TP2 ~]$ sudo tail -n 10 /var/log/dnf.log
[sudo] password for et0: 
2024-01-29T00:02:08+0100 DEBUG extras: using metadata from Sun Dec 31 02:20:22 2023.
2024-01-29T00:02:08+0100 DEBUG reviving: 'rpmfusion-free-updates' can be revived - metalink checksums match.
2024-01-29T00:02:08+0100 DEBUG rpmfusion-free-updates: using metadata from Thu Jan 25 09:14:58 2024.
2024-01-29T00:02:09+0100 DEBUG reviving: 'rpmfusion-nonfree-updates' can be revived - repomd matches.
2024-01-29T00:02:09+0100 DEBUG rpmfusion-nonfree-updates: using metadata from Thu Jan 25 09:19:08 2024.
2024-01-29T00:02:09+0100 DEBUG User-Agent: constructed: 'libdnf (Rocky Linux 9.2; generic; Linux.aarch64)'
2024-01-29T00:02:09+0100 DDEBUG timer: sack setup: 2695 ms
2024-01-29T00:02:09+0100 INFO Metadata cache created.
2024-01-29T00:02:09+0100 DDEBUG Cleaning up.
2024-01-29T00:02:09+0100 DDEBUG Plugins were unloaded.
```

## 2. Modification du service

Dans cette section, on va aller visiter et modifier le fichier de configuration du serveur SSH.

Comme tout fichier de configuration, celui de SSH se trouve dans le dossier `/etc/`.

Plus précisément, il existe un sous-dossier `/etc/ssh/` qui contient toute la configuration relative à SSH

🦦 **Identifier le fichier de configuration du serveur SSH**

🦦 **Modifier le fichier de conf**

```bash
[et0@TP2 ~]$ echo $RANDOM
1890
```
```bash
[et0@TP2 ~]$ sudo cat /etc/ssh/sshd_config | grep Port
Port 1890
```
```bash
[et0@TP2 ~]$ sudo firewall-cmd --remove-port=22/tcp --permanent
Warning: NOT_ENABLED: 22:tcp
success
[et0@TP2 ~]$ sudo firewall-cmd --add-port=1890/tcp --permanent
success
[et0@TP2 ~]$ sudo firewall-cmd --reload
success
[et0@TP2 ~]$ sudo firewall-cmd --list-all | grep port
  ports: 1890/tcp
  forward-ports: 
  source-ports: 
```

🦦 **Redémarrer le service**

```bash
[et0@TP2 ~]$ sudo systemctl restart firewalld
```

🦦 **Effectuer une connexion SSH sur le nouveau port**

```bash
stanislasthabault@MacBook-Pro-de-Stanislas ~ % ssh et0@10.1.1.11 -p 1890
et0@10.1.1.11's password: 
Last login: Mon Jan 29 11:57:32 2024
[et0@TP2 ~]$ 
```

# II. Service HTTP

**Dans cette partie, on ne va pas se limiter à un service déjà présent sur la machine : on va ajouter un service à la machine.**

➜ **On va faire dans le *clasico* et installer un serveur HTTP très réputé : NGINX**

Un serveur HTTP permet d'héberger des sites web.

➜ **Un serveur HTTP (ou "serveur Web") c'est :**

- un programme qui écoute sur un port (ouais ça change pas ça)
- il permet d'héberger des sites web
  - un site web c'est un tas de pages html, js, css
  - un site web c'est aussi parfois du code php, go, python, ou autres, qui indiquent comment le site doit se comporter
- il permet à des clients de visiter les sites web hébergés
  - pour ça, il faut un client HTTP (par exemple, un navigateur web, ou la commande `curl`)
  - le client peut alors se connecter au port du serveur (connu à l'avance)
  - une fois le tunnel de communication établi, le client effectuera des *requêtes HTTP*
  - le serveur répondra par des *réponses HTTP*

> Une requête HTTP c'est "donne moi tel fichier HTML". Une réponse c'est "voici tel fichier HTML" + le fichier HTML en question.

**Ok bon on y va ?**

- [II. Service HTTP](#ii-service-http)
  - [1. Mise en place](#1-mise-en-place)
  - [2. Analyser la conf de NGINX](#2-analyser-la-conf-de-nginx)
  - [3. Déployer un nouveau site web](#3-déployer-un-nouveau-site-web)

## 1. Mise en place

> Si jamais, pour la prononciation, NGINX ça vient de "engine-X" et vu que c'était naze comme nom... ils ont choisi un truc imprononçable ouais je sais cherchez pas la logique.

🦦 **Installer le serveur NGINX**

```bash
[et0@TP2 ~]$ sudo dnf install nginx
[sudo] password for et0: 
Rocky Linux 9 - BaseOS                                          7.6 kB/s | 4.1 kB     00:00    
Rocky Linux 9 - AppStream                                        15 kB/s | 4.5 kB     00:00    
Rocky Linux 9 - Extras                                           12 kB/s | 2.9 kB     00:00    
Package nginx-1:1.20.1-14.el9_2.1.aarch64 is already installed.
Dependencies resolved.
Nothing to do.
Complete!
```

🦦 **Démarrer le service NGINX**

```bash
[et0@TP2 ~]$ sudo systemctl start nginx
[et0@TP2 ~]$ sudo systemctl status nginx
● nginx.service - The nginx HTTP and reverse proxy server
     Loaded: loaded (/usr/lib/systemd/system/nginx.service; disabled; preset: disabled)
     Active: active (running) since Mon 2024-01-29 12:04:06 CET; 6s ago
    Process: 1331 ExecStartPre=/usr/bin/rm -f /run/nginx.pid (code=exited, status=0/SUCCESS)
    Process: 1332 ExecStartPre=/usr/sbin/nginx -t (code=exited, status=0/SUCCESS)
    Process: 1333 ExecStart=/usr/sbin/nginx (code=exited, status=0/SUCCESS)
   Main PID: 1334 (nginx)
      Tasks: 3 (limit: 4263)
     Memory: 3.4M
        CPU: 22ms
     CGroup: /system.slice/nginx.service
             ├─1334 "nginx: master process /usr/sbin/nginx"
             ├─1335 "nginx: worker process"
             └─1336 "nginx: worker process"

Jan 29 12:04:06 TP2 systemd[1]: Starting The nginx HTTP and reverse proxy server...
Jan 29 12:04:06 TP2 nginx[1332]: nginx: the configuration file /etc/nginx/nginx.conf syntax is >
Jan 29 12:04:06 TP2 nginx[1332]: nginx: configuration file /etc/nginx/nginx.conf test is succes>
Jan 29 12:04:06 TP2 systemd[1]: Started The nginx HTTP and reverse proxy server.
lines 1-19/19 (END)
```

🦦 **Déterminer sur quel port tourne NGINX**
```bash
[et0@TP2 ~]$ sudo nano /etc/nginx/nginx.conf
[et0@TP2 ~]$ sudo cat /etc/nginx/nginx.conf | grep listen
        listen       80;
        listen       [::]:80;
#        listen       443 ssl http2;
#        listen       [::]:443 ssl http2;
```
```bash
[et0@TP2 ~]$ sudo firewall-cmd --add-port=80/tcp --permanent
success
[et0@TP2 ~]$ sudo firewall-cmd --list-all | grep port
  ports: 22/tcp 80/tcp
  forward-ports: 
  source-ports: 
```

🦦 **Déterminer les processus liés au service NGINX**

```bash
[et0@TP2 ~]$ ps -ef | grep nginx
root        1334       1  0 12:04 ?        00:00:00 nginx: master process /usr/sbin/nginx
nginx       1335    1334  0 12:04 ?        00:00:00 nginx: worker process
nginx       1336    1334  0 12:04 ?        00:00:00 nginx: worker process
et0         1386    1281  0 12:11 pts/0    00:00:00 grep --color=auto nginx
```

🦦 **Déterminer le nom de l'utilisateur qui lance NGINX**

```bash
[et0@TP2 ~]$ cat /etc/passwd | grep root
root:x:0:0:root:/root:/bin/bash
operator:x:11:0:operator:/root:/sbin/nologin
```

🦦 **Test !**

```bash
stanislasthabault@MacBook-Pro-de-Stanislas ~ % curl 10.1.1.11 | head -7 
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100  7620  100  7620    0     0   147k      0 --:--:-- --:--:-- --:--:--  148k
<!doctype html>
<html>
  <head>
    <meta charset='utf-8'>
    <meta name='viewport' content='width=device-width, initial-scale=1'>
    <title>HTTP Server Test Page powered by: Rocky Linux</title>
    <style type="text/css">
```

## 2. Analyser la conf de NGINX

🦦 **Déterminer le path du fichier de configuration de NGINX**

```bash
[et0@TP2 nginx]$ ls -al /etc/nginx
total 84
drwxr-xr-x.  4 root root 4096 Jan 23 11:19 .
drwxr-xr-x. 83 root root 8192 Jan 30 09:51 ..
drwxr-xr-x.  2 root root    6 Oct 16 20:00 conf.d
drwxr-xr-x.  2 root root    6 Oct 16 20:00 default.d
-rw-r--r--.  1 root root 1077 Oct 16 20:00 fastcgi.conf
-rw-r--r--.  1 root root 1077 Oct 16 20:00 fastcgi.conf.default
-rw-r--r--.  1 root root 1007 Oct 16 20:00 fastcgi_params
-rw-r--r--.  1 root root 1007 Oct 16 20:00 fastcgi_params.default
-rw-r--r--.  1 root root 2837 Oct 16 20:00 koi-utf
-rw-r--r--.  1 root root 2223 Oct 16 20:00 koi-win
-rw-r--r--.  1 root root 5231 Oct 16 20:00 mime.types
-rw-r--r--.  1 root root 5231 Oct 16 20:00 mime.types.default
-rw-r--r--.  1 root root 2334 Oct 16 20:00 nginx.conf
-rw-r--r--.  1 root root 2656 Oct 16 20:00 nginx.conf.default
-rw-r--r--.  1 root root  636 Oct 16 20:00 scgi_params
-rw-r--r--.  1 root root  636 Oct 16 20:00 scgi_params.default
-rw-r--r--.  1 root root  664 Oct 16 20:00 uwsgi_params
-rw-r--r--.  1 root root  664 Oct 16 20:00 uwsgi_params.default
-rw-r--r--.  1 root root 3610 Oct 16 20:00 win-utf
```

🦦 **Trouver dans le fichier de conf**

```bash
[et0@TP2 nginx]$ cat nginx.conf nginx.conf.default | grep "server" -A 5
    server {
        listen       80;
        listen       [::]:80;
        server_name  _;
        root         /usr/share/nginx/html;

        # Load configuration files for the default server block.
        include /etc/nginx/default.d/*.conf;

        error_page 404 /404.html;
        location = /404.html {
        }
--
# Settings for a TLS enabled server.
#
#    server {
#        listen       443 ssl http2;
#        listen       [::]:443 ssl http2;
#        server_name  _;
#        root         /usr/share/nginx/html;
#
#        ssl_certificate "/etc/pki/nginx/server.crt";
#        ssl_certificate_key "/etc/pki/nginx/private/server.key";
#        ssl_session_cache shared:SSL:1m;
#        ssl_session_timeout  10m;
#        ssl_ciphers PROFILE=SYSTEM;
#        ssl_prefer_server_ciphers on;
#
#        # Load configuration files for the default server block.
#        include /etc/nginx/default.d/*.conf;
#
#        error_page 404 /404.html;
#            location = /40x.html {
#        }
--
    server {
        listen       80;
        server_name  localhost;

        #charset koi8-r;

        #access_log  logs/host.access.log  main;

--
        # redirect server error pages to the static page /50x.html
        #
        error_page   500 502 503 504  /50x.html;
        location = /50x.html {
            root   html;
        }
--
        # pass the PHP scripts to FastCGI server listening on 127.0.0.1:9000
        #
        #location ~ \.php$ {
        #    root           html;
        #    fastcgi_pass   127.0.0.1:9000;
        #    fastcgi_index  index.php;
--
    #server {
    #    listen       8000;
    #    listen       somename:8080;
    #    server_name  somename  alias  another.alias;

    #    location / {
    #        root   html;
    #        index  index.html index.htm;
    #    }
--
    # HTTPS server
    #
    #server {
    #    listen       443 ssl;
    #    server_name  localhost;

    #    ssl_certificate      cert.pem;
    #    ssl_certificate_key  cert.key;

    #    ssl_session_cache    shared:SSL:1m;
--
    #    ssl_prefer_server_ciphers  on;

    #    location / {
    #        root   html;
    #        index  index.html index.htm;
    #    }
```

## 3. Déployer un nouveau site web

🦦 **Créer un site web**

```bash
[et0@TP2 var]$ sudo mkdir www && cd www && sudo mkdir tp2_linux && cd tp2_linux  && sudo vi index.html
```
```bash
[et0@TP2 tp2_linux]$ cat index.html 
<h1>MEOW mon premier serveur web</h1>
```

🦦 **Gérer les permissions**

```bash
[et0@TP2 var]$ sudo chown -R nginx:nginx www/tp2_linux/
```

🦦 **Adapter la conf NGINX**

```bash
[et0@TP2 conf.d]$ sudo cat tp2.conf 
server {
  # le port choisi devra être obtenu avec un 'echo $RANDOM' là encore
  listen 20694;

  root /var/www/tp2_linux;
}
```
```bash
[et0@TP2 conf.d]$  sudo firewall-cmd --add-port=20694/tcp --permanent
success
```
```bash
[et0@TP2 conf.d]$  sudo firewall-cmd --reload
success
```

🦦 **Visitez votre super site web**

```bash
stanislasthabault@MacBook-Pro-de-Stanislas ~ % curl 10.1.1.11:20694    
<h1>MEOW mon premier serveur web</h1>
```

# III. Your own services

Dans cette partie, on va créer notre propre service :)

HE ! Vous vous souvenez de `netcat` ou `nc` ? Le ptit machin de notre premier cours de réseau ? C'EST L'HEURE DE LE RESORTIR DES PLACARDS.

- [III. Your own services](#iii-your-own-services)
  - [1. Au cas où vous l'auriez oublié](#1-au-cas-où-vous-lauriez-oublié)
  - [2. Analyse des services existants](#2-analyse-des-services-existants)
  - [3. Création de service](#3-création-de-service)

## 1. Au cas où vous l'auriez oublié

> Rien à écrire dans le rendu pour cette partie, c'juste pour vous remettre `nc` en main.

➜ Dans la VM

- `nc -l 8888`
  - lance netcat en mode listen
  - il écoute sur le port 8888
  - sans rien préciser de plus, c'est le port 8888 TCP qui est utilisé

➜ Connectez-vous au netcat qui est en écoute sur la VM

- depuis votre PC ou depuis une autre VM (il faut avoir la commande `nc`)
- `nc <IP_PREMIERE_VM> 8888`
- vérifiez que vous pouvez envoyer des messages dans les deux sens

> N'oubliez pas d'ouvrir le port 8888/tcp de la première VM bien sûr :)

## 2. Analyse des services existants

Un service c'est quoi concrètement ? C'est juste un processus, que le système lance, et dont il s'occupe après.

Il est défini dans un simple fichier texte, qui contient une info primordiale : quel programme doit être lancé quand le service "démarre".

> *"démarrer" un service c'est juste lancer un programme. Mais l'OS prend soin d'entretenir ce programme. Si on lance un programme à la main, l'OS il s'en balec un peu.*

Voyons un peu comment sont définis les services `sshd` et `nginx` avant de créer le nôtre.

🦦 **Afficher le fichier de service SSH**

```bash
[et0@TP2 ~]$ cat /usr/lib/systemd/system/sshd.service | grep "ExecStart="
ExecStart=/usr/sbin/sshd -D $OPTIONS
```

🦦 **Afficher le fichier de service NGINX**

```bash
[et0@TP2 ~]$ cat /usr/lib/systemd/system/nginx.service | grep "ExecStart="
ExecStart=/usr/sbin/nginx
```

## 3. Création de service

Bon ! On va créer un petit service qui lance un `nc`. Et vous allez tout de suite voir pourquoi c'est pratique d'en faire un service et pas juste le lancer à la main : on va faire en sorte que `nc` se relance tout seul quand un client se déconnecte.

> *Le comportement de base de `nc` c'est de quitter, de se fermer, si un utilisateur se connecte puis s'en va.*

Ca reste un truc pour s'exercer, c'pas non plus le truc le plus utile de l'année que de mettre un `nc` dans un service n_n

🦦 **Créez le fichier `/etc/systemd/system/tp3_nc.service`**

```bash
[et0@TP2 ~]$ sudo cat /etc/systemd/system/tp3_nc.service 
[Unit]
Description=Super netcat tout fou

[Service]
ExecStart=/usr/bin/nc -l 19269 -k
```
```bash
[et0@TP2 ~]$ sudo firewall-cmd --add-port=19269/tcp --permanent
success
```
```bash
[et0@TP2 ~]$ sudo firewall-cmd --reload
success
```

🦦 **Indiquer au système qu'on a modifié les fichiers de service**

```bash
[et0@TP2 ~]$ sudo systemctl daemon-reload
```

🦦 **Démarrer notre service de ouf**

```bash
[et0@TP2 ~]$ sudo systemctl start tp3_nc.service
```

🦦 **Vérifier que ça fonctionne**

```bash
[et0@TP2 ~]$ sudo systemctl status tp3_nc.service
● tp3_nc.service - Super netcat tout fou
     Loaded: loaded (/etc/systemd/system/tp3_nc.service; static)
     Active: active (running) since Tue 2024-01-30 11:33:40 CET; 3s ago
   Main PID: 1753 (nc)
      Tasks: 1 (limit: 4263)
     Memory: 744.0K
        CPU: 4ms
     CGroup: /system.slice/tp3_nc.service
             └─1753 /usr/bin/nc -l 19269 -k

Jan 30 11:33:40 TP2 systemd[1]: Started Super netcat tout fou.
```
```bash
[et0@TP2 ~]$ sudo ss -alntp | grep nc
LISTEN 0      10           0.0.0.0:19269      0.0.0.0:*    users:(("nc",pid=1770,fd=4))                                                   
LISTEN 0      10              [::]:19269         [::]:*    users:(("nc",pid=1770,fd=3))   
```

🦦 **Les logs de votre service**

```bash
[et0@TP2 ~]$ sudo journalctl -xe -u tp3_nc | grep start
```
```bash
[et0@TP2 ~]$ sudo journalctl -xe -u tp3_nc | grep nc
```
```bash
[et0@TP2 ~]$ sudo journalctl -xe -u tp3_nc | grep finished
```

🦦 **S'amuser à `kill` le processus**

```bash
[et0@TP2 ~]$ ps -fe | grep nc
root         635       1  0 09:51 ?        00:00:00 /usr/sbin/irqbalance --foreground
dbus         645       1  0 09:51 ?        00:00:00 /usr/bin/dbus-broker-launch --scope system --audit
root        1770       1  0 11:37 ?        00:00:00 /usr/bin/nc -l 19269 -k
et0         1831    1268  0 11:51 pts/0    00:00:00 grep --color=auto nc
```
```bash
[et0@TP2 ~]$ sudo kill 1770
```

🦦 **Affiner la définition du service**

```bash
[et0@TP2 ~]$ sudo cat /etc/systemd/system/tp3_nc.service
[Unit]
Description=Super netcat tout fou

[Service]
Restart=always
ExecStart=/usr/bin/nc -l 19269 -k
```
```bash
[et0@TP2 ~]$ ps -fe | grep nc
root         635       1  0 09:51 ?        00:00:00 /usr/sbin/irqbalance --foreground
dbus         645       1  0 09:51 ?        00:00:00 /usr/bin/dbus-broker-launch --scope system --audit
root        1848       1  0 11:54 ?        00:00:00 /usr/bin/nc -l 19269 -k
et0         1860    1268  0 11:55 pts/0    00:00:00 grep --color=auto nc
[et0@TP2 ~]$ sudo kill 1848
[et0@TP2 ~]$ ps -fe | grep nc
root         635       1  0 09:51 ?        00:00:00 /usr/sbin/irqbalance --foreground
dbus         645       1  0 09:51 ?        00:00:00 /usr/bin/dbus-broker-launch --scope system --audit
root        1865       1  0 11:56 ?        00:00:00 /usr/bin/nc -l 19269 -k
et0         1867    1268  0 11:56 pts/0    00:00:00 grep --color=auto nc
```
