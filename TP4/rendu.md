# Partie 1 : Partitionnement du serveur de stockage

> Cette partie est à réaliser sur 🖥️ **VM storage.tp4.linux**.

On va ajouter un disque dur à la VM, puis le partitionner, afin de créer un espace dédié qui accueillera nos sites web.

➜ **Ajouter deux disques durs de 2G à la VM**

- cela se fait via l'interface graphique de virtualbox
- il faut éteindre la VM pour ce faire

> [**Référez-vous au mémo LVM pour réaliser le reste de cette partie.**](../../../cours/memo/lvm.md)

**Le partitionnement est obligatoire pour que le disque soit utilisable.** Ici on va rester simple : une seule partition, qui prend toute la place offerte par le disque.

Comme vu en cours, le partitionnement dans les systèmes GNU/Linux s'effectue généralement à l'aide de _LVM_.

**Allons !**

🦦 **Partitionner le disque à l'aide de LVM**

```bash
[et0@storage ~]$ lsblk
NAME        MAJ:MIN RM  SIZE RO TYPE MOUNTPOINTS
sr0          11:0    1 1024M  0 rom
vda         252:0    0    8G  0 disk
├─vda1      252:1    0  600M  0 part /boot/efi
├─vda2      252:2    0    1G  0 part /boot
└─vda3      252:3    0  6.4G  0 part
  ├─rl-root 253:0    0  5.6G  0 lvm  /
  └─rl-swap 253:1    0  820M  0 lvm  [SWAP]
vdb         252:16   0    2G  0 disk
vdc         252:32   0    2G  0 disk
```

```bash
[et0@storage ~]$ sudo pvcreate /dev/vdb
[sudo] password for et0:
  Physical volume "/dev/vdb" successfully created.
[et0@storage ~]$ sudo pvcreate /dev/vdc
  Physical volume "/dev/vdc" successfully created.
```

```bash
[et0@storage ~]$ sudo vgcreate storage /dev/vdb
  Volume group "storage" successfully created
[et0@storage ~]$ sudo vgextend storage /dev/vdc
  Volume group "storage" successfully extended
```

```bash
[et0@storage ~]$ sudo lvcreate -n toto -l +100%FREE storage
  Logical volume "toto" created.
```

🦦 **Formater la partition**

```bash
[et0@storage ~]$ sudo mkfs -t ext4 /dev/storage/toto
mke2fs 1.46.5 (30-Dec-2021)
Discarding device blocks: done
Creating filesystem with 1046528 4k blocks and 261632 inodes
Filesystem UUID: 78e4bcc3-79a3-4305-a925-f0b8d6f68e35
Superblock backups stored on blocks:
	32768, 98304, 163840, 229376, 294912, 819200, 884736

Allocating group tables: done
Writing inode tables: done
Creating journal (16384 blocks): done
Writing superblocks and filesystem accounting information: done
```

🦦 **Monter la partition**

```bash
[et0@storage ~]$ sudo mkdir /mnt/toto
[sudo] password for et0:
[et0@storage ~]$ sudo mount /dev/storage/toto /mnt/storage
[et0@storage ~]$ df -h | grep toto
/dev/mapper/storage-toto  3.9G   24K  3.7G   1% /mnt/storage
```

```bash
[et0@storage storage]$ pwd
/mnt/storage
[et0@storage storage]$ sudo cat test.txt
coucou
```

```bash
[et0@storage storage]$ sudo cat /etc/fstab | grep toto
/dev/mapper/storage-toto /mnt/storage           ext4    defaults        0 0
```

⭐**BONUS**

```bash
[et0@storage storage]$ sudo dd if=/dev/zero of=/dev/mapper/storage-toto bs=2M count=1000
1000+0 records in
1000+0 records out
2097152000 bytes (2.1 GB, 2.0 GiB) copied, 0.812783 s, 2.6 GB/s
```

```bash
[et0@storage storage]$ df | grep toto
/dev/mapper/storage-toto 73786976294838058880 73786976294834020380   4022116 100% /mnt/storage
```

# Partie 2 : Serveur de partage de fichiers

**Dans cette partie, le but sera de monter un serveur de stockage.** Un serveur de stockage, ici, désigne simplement un serveur qui partagera un dossier ou plusieurs aux autres machines de son réseau.

Ce dossier sera hébergé sur la partition dédiée sur la machine **`storage.tp4.linux`**.

Afin de partager le dossier, **nous allons mettre en place un serveur NFS** (pour Network File System), qui est prévu à cet effet. Comme d'habitude : c'est un programme qui écoute sur un port, et les clients qui s'y connectent avec un programme client adapté peuvent accéder à un ou plusieurs dossiers partagés.

Le **serveur NFS** sera **`storage.tp4.linux`** et le **client NFS** sera **`web.tp4.linux`**.

L'objectif :

- avoir deux dossiers sur **`storage.tp4.linux`** partagés
  - `/storage/site_web_1/`
  - `/storage/site_web_2/`
- la machine **`web.tp4.linux`** monte ces deux dossiers à travers le réseau
  - le dossier `/storage/site_web_1/` est monté dans `/var/www/site_web_1/`
  - le dossier `/storage/site_web_2/` est monté dans `/var/www/site_web_2/`

🦦 **Donnez les commandes réalisées sur le serveur NFS `storage.tp4.linux`**

```bash
[et0@storage ~]$ sudo cat /etc/exports
/mnt/storage/site_web_1     10.1.1.12(rw,sync,no_subtree_check)
/mnt/storage/site_web_2     10.1.1.12(rw,sync,no_subtree_check)
```

🦦 **Donnez les commandes réalisées sur le client NFS `web.tp4.linux`**

```bash
[et0@web ~]$ sudo cat /etc/fstab | grep site_web_
10.1.1.11:/mnt/storage/site_web_1 /var/www/site_web_1   nfs    defaults        0 0
10.1.1.11:/mnt/storage/site_web_2 /var/www/site_web_2   nfs    defaults        0 0
```

# Partie 3 : Serveur web

- [Partie 3 : Serveur web](#partie-3--serveur-web)
  - [1. Intro NGINX](#1-intro-nginx)
  - [2. Install](#2-install)
  - [3. Analyse](#3-analyse)
  - [4. Visite du service web](#4-visite-du-service-web)
  - [5. Modif de la conf du serveur web](#5-modif-de-la-conf-du-serveur-web)
  - [6. Deux sites web sur un seul serveur](#6-deux-sites-web-sur-un-seul-serveur)

## 1. Intro NGINX

**NGINX (prononcé "engine-X") est un serveur web.** C'est un outil de référence aujourd'hui, il est réputé pour ses performances et sa robustesse.

Un serveur web, c'est un programme qui écoute sur un port et qui attend des requêtes HTTP. Quand il reçoit une requête de la part d'un client, il renvoie une réponse HTTP qui contient le plus souvent de l'HTML, du CSS et du JS.

> Une requête HTTP c'est par exemple `GET /index.html` qui veut dire "donne moi le fichier `index.html` qui est stocké sur le serveur". Le serveur renverra alors le contenu de ce fichier `index.html`.

Ici on va pas DU TOUT s'attarder sur la partie dév web étou, une simple page HTML fera l'affaire.

Une fois le serveur web NGINX installé (grâce à un paquet), sont créés sur la machine :

- **un service** (un fichier `.service`)
  - on pourra interagir avec le service à l'aide de `systemctl`
- **des fichiers de conf**
  - comme d'hab c'est dans `/etc/` la conf
  - comme d'hab c'est bien rangé, donc la conf de NGINX c'est dans `/etc/nginx/`
  - question de simplicité en terme de nommage, le fichier de conf principal c'est `/etc/nginx/nginx.conf`
- **une racine web**
  - c'est un dossier dans lequel un site est stocké
  - c'est à dire là où se trouvent tous les fichiers PHP, HTML, CSS, JS, etc du site
  - ce dossier et tout son contenu doivent appartenir à l'utilisateur qui lance le service
- **des logs**
  - tant que le service a pas trop tourné c'est empty
  - les fichiers de logs sont dans `/var/log/`
  - comme d'hab c'est bien rangé donc c'est dans `/var/log/nginx/`
  - on peut aussi consulter certains logs avec `sudo journalctl -xe -u nginx`

> Chaque log est à sa place, on ne trouve pas la même chose dans chaque fichier ou la commande `journalctl`. La commande `journalctl` vous permettra de repérer les erreurs que vous glisser dans les fichiers de conf et qui empêche le démarrage correct de NGINX.

## 2. Install

🖥️ **VM web.tp4.linux**

🦦 **Installez NGINX**

```bash
[et0@web ~]$ sudo dnf install nginx
Last metadata expiration check: 1:34:22 ago on Tue Feb 20 10:12:55 2024.
Package nginx-1:1.20.1-14.el9_2.1.aarch64 is already installed.
Dependencies resolved.
Nothing to do.
Complete!
```

## 3. Analyse

Avant de config des truks 2 ouf étou, on va lancer à l'aveugle et inspecter ce qu'il se passe, inspecter avec les outils qu'on connaît ce que fait NGINX à notre OS.

Commencez donc par démarrer le service NGINX :

```bash
$ sudo systemctl start nginx
$ sudo systemctl status nginx
```

🦦 **Analysez le service NGINX**

```bash
[et0@web ~]$ sudo ps -ef | grep nginx
root        4250       1  0 22:06 ?        00:00:00 nginx: master process /usr/sbin/nginx
nginx       4251    4250  0 22:06 ?        00:00:00 nginx: worker process
nginx       4252    4250  0 22:06 ?        00:00:00 nginx: worker process
```

```bash
[et0@web nginx]$ sudo ss -ltnep | grep nginx
LISTEN 0      511          0.0.0.0:80        0.0.0.0:*    users:(("nginx",pid=4252,fd=6),("nginx",pid=4251,fd=6),("nginx",pid=4250,fd=6)) ino:26264 sk:51 cgroup:/system.slice/nginx.service <->
LISTEN 0      511             [::]:80           [::]:*    users:(("nginx",pid=4252,fd=7),("nginx",pid=4251,fd=7),("nginx",pid=4250,fd=7)) ino:26265 sk:54 cgroup:/system.slice/nginx.service v6only:1 <->
```

```bash
[et0@web nginx]$ cat nginx.conf | grep html
    # See http://nginx.org/en/docs/ngx_core_module.html#include
        root         /usr/share/nginx/html;
        error_page 404 /404.html;
        location = /404.html {
        error_page 500 502 503 504 /50x.html;
        location = /50x.html {
#        root         /usr/share/nginx/html;
#        error_page 404 /404.html;
#            location = /40x.html {
#        error_page 500 502 503 504 /50x.html;
#            location = /50x.html {
```

```bash
[et0@web html]$ ls -al
total 12
drwxr-xr-x. 3 root root  143 Feb 20 10:42 .
drwxr-xr-x. 4 root root   33 Feb 20 10:42 ..
-rw-r--r--. 1 root root 3332 Oct 16 19:58 404.html
-rw-r--r--. 1 root root 3404 Oct 16 19:58 50x.html
drwxr-xr-x. 2 root root   27 Feb 20 10:42 icons
lrwxrwxrwx. 1 root root   25 Oct 16 20:00 index.html -> ../../testpage/index.html
-rw-r--r--. 1 root root  368 Oct 16 19:58 nginx-logo.png
lrwxrwxrwx. 1 root root   14 Oct 16 20:00 poweredby.png -> nginx-logo.png
lrwxrwxrwx. 1 root root   37 Oct 16 20:00 system_noindex_logo.png -> ../../pixmaps/system-noindex-logo.png
```

## 4. Visite du service web

**Et ça serait bien d'accéder au service non ?** Genre c'est un serveur web. On veut voir un site web !

🦦 **Configurez le firewall pour autoriser le trafic vers le service NGINX**

```bash
[et0@web ~]$ sudo firewall-cmd --add-port=80/tcp --permanent
success
```

```bash
[et0@TP2 ~]$ sudo firewall-cmd --reload
success
```

```bash
[et0@web ~]$ sudo firewall-cmd --list-all | grep port
  ports: 80/tcp
  forward-ports:
  source-ports:
```

🦦 **Accéder au site web**

```bash
stan@MacBook-Pro-de-Stanislas ~ % curl 10.1.1.12
<!doctype html>
<html>
  <head>
    <meta charset='utf-8'>
    <meta name='viewport' content='width=device-width, initial-scale=1'>
    <title>HTTP Server Test Page powered by: Rocky Linux</title>
    <style type="text/css">
      /*<![CDATA[*/

      html {
        height: 100%;
        width: 100%;
      }
        body {
  background: rgb(20,72,50);
  background: -moz-linear-gradient(180deg, rgba(23,43,70,1) 30%, rgba(0,0,0,1) 90%)  ;
  background: -webkit-linear-gradient(180deg, rgba(23,43,70,1) 30%, rgba(0,0,0,1) 90%) ;
  background: linear-gradient(180deg, rgba(23,43,70,1) 30%, rgba(0,0,0,1) 90%);
  background-repeat: no-repeat;
  background-attachment: fixed;
  filter: progid:DXImageTransform.Microsoft.gradient(startColorstr="#3c6eb4",endColorstr="#3c95b4",GradientType=1);
        color: white;
        font-size: 0.9em;
        font-weight: 400;
        font-family: 'Montserrat', sans-serif;
        margin: 0;
        padding: 10em 6em 10em 6em;
        box-sizing: border-box;

      }


  h1 {
    text-align: center;
    margin: 0;
    padding: 0.6em 2em 0.4em;
    color: #fff;
    font-weight: bold;
    font-family: 'Montserrat', sans-serif;
    font-size: 2em;
  }
  h1 strong {
    font-weight: bolder;
    font-family: 'Montserrat', sans-serif;
  }
  h2 {
    font-size: 1.5em;
    font-weight:bold;
  }

  .title {
    border: 1px solid black;
    font-weight: bold;
    position: relative;
    float: right;
    width: 150px;
    text-align: center;
    padding: 10px 0 10px 0;
    margin-top: 0;
  }

  .description {
    padding: 45px 10px 5px 10px;
    clear: right;
    padding: 15px;
  }

  .section {
    padding-left: 3%;
   margin-bottom: 10px;
  }

  img {

    padding: 2px;
    margin: 2px;
  }
  a:hover img {
    padding: 2px;
    margin: 2px;
  }

  :link {
    color: rgb(199, 252, 77);
    text-shadow:
  }
  :visited {
    color: rgb(122, 206, 255);
  }
  a:hover {
    color: rgb(16, 44, 122);
  }
  .row {
    width: 100%;
    padding: 0 10px 0 10px;
  }

  footer {
    padding-top: 6em;
    margin-bottom: 6em;
    text-align: center;
    font-size: xx-small;
    overflow:hidden;
    clear: both;
  }

  .summary {
    font-size: 140%;
    text-align: center;
  }

  #rocky-poweredby img {
    margin-left: -10px;
  }

  #logos img {
    vertical-align: top;
  }

  /* Desktop  View Options */

  @media (min-width: 768px)  {

    body {
      padding: 10em 20% !important;
    }

    .col-md-1, .col-md-2, .col-md-3, .col-md-4, .col-md-5, .col-md-6,
    .col-md-7, .col-md-8, .col-md-9, .col-md-10, .col-md-11, .col-md-12 {
      float: left;
    }

    .col-md-1 {
      width: 8.33%;
    }
    .col-md-2 {
      width: 16.66%;
    }
    .col-md-3 {
      width: 25%;
    }
    .col-md-4 {
      width: 33%;
    }
    .col-md-5 {
      width: 41.66%;
    }
    .col-md-6 {
      border-left:3px ;
      width: 50%;


    }
    .col-md-7 {
      width: 58.33%;
    }
    .col-md-8 {
      width: 66.66%;
    }
    .col-md-9 {
      width: 74.99%;
    }
    .col-md-10 {
      width: 83.33%;
    }
    .col-md-11 {
      width: 91.66%;
    }
    .col-md-12 {
      width: 100%;
    }
  }

  /* Mobile View Options */
  @media (max-width: 767px) {
    .col-sm-1, .col-sm-2, .col-sm-3, .col-sm-4, .col-sm-5, .col-sm-6,
    .col-sm-7, .col-sm-8, .col-sm-9, .col-sm-10, .col-sm-11, .col-sm-12 {
      float: left;
    }

    .col-sm-1 {
      width: 8.33%;
    }
    .col-sm-2 {
      width: 16.66%;
    }
    .col-sm-3 {
      width: 25%;
    }
    .col-sm-4 {
      width: 33%;
    }
    .col-sm-5 {
      width: 41.66%;
    }
    .col-sm-6 {
      width: 50%;
    }
    .col-sm-7 {
      width: 58.33%;
    }
    .col-sm-8 {
      width: 66.66%;
    }
    .col-sm-9 {
      width: 74.99%;
    }
    .col-sm-10 {
      width: 83.33%;
    }
    .col-sm-11 {
      width: 91.66%;
    }
    .col-sm-12 {
      width: 100%;
    }
    h1 {
      padding: 0 !important;
    }
  }


  </style>
  </head>
  <body>
    <h1>HTTP Server <strong>Test Page</strong></h1>

    <div class='row'>

      <div class='col-sm-12 col-md-6 col-md-6 '></div>
          <p class="summary">This page is used to test the proper operation of
            an HTTP server after it has been installed on a Rocky Linux system.
            If you can read this page, it means that the software is working
            correctly.</p>
      </div>

      <div class='col-sm-12 col-md-6 col-md-6 col-md-offset-12'>


        <div class='section'>
          <h2>Just visiting?</h2>

          <p>This website you are visiting is either experiencing problems or
          could be going through maintenance.</p>

          <p>If you would like the let the administrators of this website know
          that you've seen this page instead of the page you've expected, you
          should send them an email. In general, mail sent to the name
          "webmaster" and directed to the website's domain should reach the
          appropriate person.</p>

          <p>The most common email address to send to is:
          <strong>"webmaster@example.com"</strong></p>

          <h2>Note:</h2>
          <p>The Rocky Linux distribution is a stable and reproduceable platform
          based on the sources of Red Hat Enterprise Linux (RHEL). With this in
          mind, please understand that:

        <ul>
          <li>Neither the <strong>Rocky Linux Project</strong> nor the
          <strong>Rocky Enterprise Software Foundation</strong> have anything to
          do with this website or its content.</li>
          <li>The Rocky Linux Project nor the <strong>RESF</strong> have
          "hacked" this webserver: This test page is included with the
          distribution.</li>
        </ul>
        <p>For more information about Rocky Linux, please visit the
          <a href="https://rockylinux.org/"><strong>Rocky Linux
          website</strong></a>.
        </p>
        </div>
      </div>
      <div class='col-sm-12 col-md-6 col-md-6 col-md-offset-12'>
        <div class='section'>

          <h2>I am the admin, what do I do?</h2>

        <p>You may now add content to the webroot directory for your
        software.</p>

        <p><strong>For systems using the
        <a href="https://httpd.apache.org/">Apache Webserver</strong></a>:
        You can add content to the directory <code>/var/www/html/</code>.
        Until you do so, people visiting your website will see this page. If
        you would like this page to not be shown, follow the instructions in:
        <code>/etc/httpd/conf.d/welcome.conf</code>.</p>

        <p><strong>For systems using
        <a href="https://nginx.org">Nginx</strong></a>:
        You can add your content in a location of your
        choice and edit the <code>root</code> configuration directive
        in <code>/etc/nginx/nginx.conf</code>.</p>

        <div id="logos">
          <a href="https://rockylinux.org/" id="rocky-poweredby"><img src="icons/poweredby.png" alt="[ Powered by Rocky Linux ]" /></a> <!-- Rocky -->
          <img src="poweredby.png" /> <!-- webserver -->
        </div>
      </div>
      </div>

      <footer class="col-sm-12">
      <a href="https://apache.org">Apache&trade;</a> is a registered trademark of <a href="https://apache.org">the Apache Software Foundation</a> in the United States and/or other countries.<br />
      <a href="https://nginx.org">NGINX&trade;</a> is a registered trademark of <a href="https://">F5 Networks, Inc.</a>.
      </footer>

  </body>
</html>
```

🦦 **Vérifier les logs d'accès**

```bash
[et0@web nginx]$ sudo tail -n 3 access.log
10.1.1.1 - - [22/Feb/2024:22:24:16 +0100] "GET /poweredby.png HTTP/1.1" 200 368 "http://10.1.1.12/" "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/121.0.0.0 Safari/537.36" "-"
10.1.1.1 - - [22/Feb/2024:22:24:16 +0100] "GET /favicon.ico HTTP/1.1" 404 3332 "http://10.1.1.12/" "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/121.0.0.0 Safari/537.36" "-"
10.1.1.1 - - [22/Feb/2024:22:24:44 +0100] "GET / HTTP/1.1" 200 7620 "-" "curl/8.4.0" "-"
```

## 5. Modif de la conf du serveur web

🦦 **Changer le port d'écoute**

```bash
[et0@web nginx]$ cat nginx.conf | grep listen
        listen       8080;
        listen       [::]:8080;
#        listen       443 ssl http2;
#        listen       [::]:443 ssl http2;
```

```bash
[et0@web ~]$ sudo ss -ltnep | grep nginx
LISTEN 0      511          0.0.0.0:8080      0.0.0.0:*    users:(("nginx",pid=4443,fd=6),(nginx",pid=4442,fd=6),("nginx",pid=4441,fd=6)) ino:30015 sk:1002 cgroup:/system.slice/ngin.service <->
LISTEN 0      511             [::]:8080         [::]:*    users:(("nginx",pid=4443,fd=7),(nginx",pid=4442,fd=7),("nginx",pid=4441,fd=7)) ino:30016 sk:1003 cgroup:/system.slice/ngin.service v6only:1 <->
```

```bash
stan@MacBook-Pro-de-Stanislas ~ % curl 10.1.1.12:8080
<!doctype html>
<html>
  <head>
    <meta charset='utf-8'>
    <meta name='viewport' content='width=device-width, initial-scale=1'>
    <title>HTTP Server Test Page powered by: Rocky Linux</title>
    <style type="text/css">
      /*<![CDATA[*/

      html {
        height: 100%;
        width: 100%;
      }
        body {
  background: rgb(20,72,50);
  background: -moz-linear-gradient(180deg, rgba(23,43,70,1) 30%, rgba(0,0,0,1) 90%)  ;
  background: -webkit-linear-gradient(180deg, rgba(23,43,70,1) 30%, rgba(0,0,0,1) 90%) ;
  background: linear-gradient(180deg, rgba(23,43,70,1) 30%, rgba(0,0,0,1) 90%);
  background-repeat: no-repeat;
  background-attachment: fixed;
  filter: progid:DXImageTransform.Microsoft.gradient(startColorstr="#3c6eb4",endColorstr="#3c95b4",GradientType=1);
        color: white;
        font-size: 0.9em;
        font-weight: 400;
        font-family: 'Montserrat', sans-serif;
        margin: 0;
        padding: 10em 6em 10em 6em;
        box-sizing: border-box;

      }


  h1 {
    text-align: center;
    margin: 0;
    padding: 0.6em 2em 0.4em;
    color: #fff;
    font-weight: bold;
    font-family: 'Montserrat', sans-serif;
    font-size: 2em;
  }
  h1 strong {
    font-weight: bolder;
    font-family: 'Montserrat', sans-serif;
  }
  h2 {
    font-size: 1.5em;
    font-weight:bold;
  }

  .title {
    border: 1px solid black;
    font-weight: bold;
    position: relative;
    float: right;
    width: 150px;
    text-align: center;
    padding: 10px 0 10px 0;
    margin-top: 0;
  }

  .description {
    padding: 45px 10px 5px 10px;
    clear: right;
    padding: 15px;
  }

  .section {
    padding-left: 3%;
   margin-bottom: 10px;
  }

  img {

    padding: 2px;
    margin: 2px;
  }
  a:hover img {
    padding: 2px;
    margin: 2px;
  }

  :link {
    color: rgb(199, 252, 77);
    text-shadow:
  }
  :visited {
    color: rgb(122, 206, 255);
  }
  a:hover {
    color: rgb(16, 44, 122);
  }
  .row {
    width: 100%;
    padding: 0 10px 0 10px;
  }

  footer {
    padding-top: 6em;
    margin-bottom: 6em;
    text-align: center;
    font-size: xx-small;
    overflow:hidden;
    clear: both;
  }

  .summary {
    font-size: 140%;
    text-align: center;
  }

  #rocky-poweredby img {
    margin-left: -10px;
  }

  #logos img {
    vertical-align: top;
  }

  /* Desktop  View Options */

  @media (min-width: 768px)  {

    body {
      padding: 10em 20% !important;
    }

    .col-md-1, .col-md-2, .col-md-3, .col-md-4, .col-md-5, .col-md-6,
    .col-md-7, .col-md-8, .col-md-9, .col-md-10, .col-md-11, .col-md-12 {
      float: left;
    }

    .col-md-1 {
      width: 8.33%;
    }
    .col-md-2 {
      width: 16.66%;
    }
    .col-md-3 {
      width: 25%;
    }
    .col-md-4 {
      width: 33%;
    }
    .col-md-5 {
      width: 41.66%;
    }
    .col-md-6 {
      border-left:3px ;
      width: 50%;


    }
    .col-md-7 {
      width: 58.33%;
    }
    .col-md-8 {
      width: 66.66%;
    }
    .col-md-9 {
      width: 74.99%;
    }
    .col-md-10 {
      width: 83.33%;
    }
    .col-md-11 {
      width: 91.66%;
    }
    .col-md-12 {
      width: 100%;
    }
  }

  /* Mobile View Options */
  @media (max-width: 767px) {
    .col-sm-1, .col-sm-2, .col-sm-3, .col-sm-4, .col-sm-5, .col-sm-6,
    .col-sm-7, .col-sm-8, .col-sm-9, .col-sm-10, .col-sm-11, .col-sm-12 {
      float: left;
    }

    .col-sm-1 {
      width: 8.33%;
    }
    .col-sm-2 {
      width: 16.66%;
    }
    .col-sm-3 {
      width: 25%;
    }
    .col-sm-4 {
      width: 33%;
    }
    .col-sm-5 {
      width: 41.66%;
    }
    .col-sm-6 {
      width: 50%;
    }
    .col-sm-7 {
      width: 58.33%;
    }
    .col-sm-8 {
      width: 66.66%;
    }
    .col-sm-9 {
      width: 74.99%;
    }
    .col-sm-10 {
      width: 83.33%;
    }
    .col-sm-11 {
      width: 91.66%;
    }
    .col-sm-12 {
      width: 100%;
    }
    h1 {
      padding: 0 !important;
    }
  }


  </style>
  </head>
  <body>
    <h1>HTTP Server <strong>Test Page</strong></h1>

    <div class='row'>

      <div class='col-sm-12 col-md-6 col-md-6 '></div>
          <p class="summary">This page is used to test the proper operation of
            an HTTP server after it has been installed on a Rocky Linux system.
            If you can read this page, it means that the software is working
            correctly.</p>
      </div>

      <div class='col-sm-12 col-md-6 col-md-6 col-md-offset-12'>


        <div class='section'>
          <h2>Just visiting?</h2>

          <p>This website you are visiting is either experiencing problems or
          could be going through maintenance.</p>

          <p>If you would like the let the administrators of this website know
          that you've seen this page instead of the page you've expected, you
          should send them an email. In general, mail sent to the name
          "webmaster" and directed to the website's domain should reach the
          appropriate person.</p>

          <p>The most common email address to send to is:
          <strong>"webmaster@example.com"</strong></p>

          <h2>Note:</h2>
          <p>The Rocky Linux distribution is a stable and reproduceable platform
          based on the sources of Red Hat Enterprise Linux (RHEL). With this in
          mind, please understand that:

        <ul>
          <li>Neither the <strong>Rocky Linux Project</strong> nor the
          <strong>Rocky Enterprise Software Foundation</strong> have anything to
          do with this website or its content.</li>
          <li>The Rocky Linux Project nor the <strong>RESF</strong> have
          "hacked" this webserver: This test page is included with the
          distribution.</li>
        </ul>
        <p>For more information about Rocky Linux, please visit the
          <a href="https://rockylinux.org/"><strong>Rocky Linux
          website</strong></a>.
        </p>
        </div>
      </div>
      <div class='col-sm-12 col-md-6 col-md-6 col-md-offset-12'>
        <div class='section'>

          <h2>I am the admin, what do I do?</h2>

        <p>You may now add content to the webroot directory for your
        software.</p>

        <p><strong>For systems using the
        <a href="https://httpd.apache.org/">Apache Webserver</strong></a>:
        You can add content to the directory <code>/var/www/html/</code>.
        Until you do so, people visiting your website will see this page. If
        you would like this page to not be shown, follow the instructions in:
        <code>/etc/httpd/conf.d/welcome.conf</code>.</p>

        <p><strong>For systems using
        <a href="https://nginx.org">Nginx</strong></a>:
        You can add your content in a location of your
        choice and edit the <code>root</code> configuration directive
        in <code>/etc/nginx/nginx.conf</code>.</p>

        <div id="logos">
          <a href="https://rockylinux.org/" id="rocky-poweredby"><img src="icons/poweredby.png" alt="[ Powered by Rocky Linux ]" /></a> <!-- Rocky -->
          <img src="poweredby.png" /> <!-- webserver -->
        </div>
      </div>
      </div>

      <footer class="col-sm-12">
      <a href="https://apache.org">Apache&trade;</a> is a registered trademark of <a href="https://apache.org">the Apache Software Foundation</a> in the United States and/or other countries.<br />
      <a href="https://nginx.org">NGINX&trade;</a> is a registered trademark of <a href="https://">F5 Networks, Inc.</a>.
      </footer>

  </body>
</html>
```

🦦 **Changer l'utilisateur qui lance le service**

```bash
[et0@web nginx]$ sudo cat nginx.conf | grep user
user server;
    log_format  main  '$remote_addr - $remote_user [$time_local] "$request" '
                      '"$http_user_agent" "$http_x_forwarded_for"';
```

```bash
[et0@web ~]$ sudo ps -ef | grep nginx
root        4527       1  0 22:42 ?        00:00:00 nginx: master process /usr/sbin/nginx
server      4528    4527  0 22:42 ?        00:00:00 nginx: worker process
server      4529    4527  0 22:42 ?        00:00:00 nginx: worker process
et0         4537    4218  0 22:42 pts/0    00:00:00 grep --color=auto nginx
```

**Il est temps d'utiliser ce qu'on a fait à la partie 2 !**

🦦 **Changer l'emplacement de la racine Web**

```bash
[et0@web nginx]$ sudo cat nginx.conf | grep root
        root         /var/www/site_web_1;
#        root         /usr/share/nginx/html;
```

```bash
stan@MacBook-Pro-de-Stanislas ~ % curl 10.1.1.12:8080
<!doctype html>
<html lang="fr">
<head>
  <meta charset="utf-8">
  <title>Titre de la page</title>
  <link rel="stylesheet" href="style.css">
  <script src="script.js"></script>
</head>
<body>
  ...
  <h1>MEOW</h1>
  ...
</body>
</html>
```

## 6. Deux sites web sur un seul serveur

Dans la conf NGINX, vous avez du repérer un bloc `server { }` (si c'est pas le cas, allez le repérer, la ligne qui définit la racine web est contenu dans le bloc `server { }`).

Un bloc `server { }` permet d'indiquer à NGINX de servir un site web donné.

Si on veut héberger plusieurs sites web, il faut donc déclarer plusieurs blocs `server { }`.

**Pour éviter que ce soit le GROS BORDEL dans le fichier de conf**, et se retrouver avec un fichier de 150000 lignes, on met chaque bloc `server` dans un fichier de conf dédié.

Et le fichier de conf principal contient une ligne qui inclut tous les fichiers de confs additionnels.

🦦 **Repérez dans le fichier de conf**

```bash
[et0@web nginx]$ sudo cat nginx.conf | grep conf.d
    # Load modular configuration files from the /etc/nginx/conf.d directory.
    include /etc/nginx/conf.d/*.conf;
```

🦦 **Créez le fichier de configuration pour le premier site**

```bash
[et0@web conf.d]$ sudo cat site_web_1.conf
server {
        listen       8080;
        listen       [::]:8080;
        server_name  _;
        root         /var/www/site_web_1;

        # Load configuration files for the default server block.
        include /etc/nginx/default.d/*.conf;

        error_page 404 /404.html;
        location = /404.html {
        }

        error_page 500 502 503 504 /50x.html;
        location = /50x.html {
        }
}
```

🦦 **Créez le fichier de configuration pour le deuxième site**

```bash
[et0@web conf.d]$ sudo cat site_web_2.conf
server {
        listen       8888;
        listen       [::]:8888;
        server_name  _;
        root         /var/www/site_web_2;

        # Load configuration files for the default server block.
        include /etc/nginx/default.d/*.conf;

        error_page 404 /404.html;
        location = /404.html {
        }

        error_page 500 502 503 504 /50x.html;
        location = /50x.html {
        }
}
```

```bash
[et0@web ~]$ sudo ss -ltnep | grep nginx
LISTEN 0      511          0.0.0.0:8080      0.0.0.0:*    users:(("nginx",pid=4644,fd=6),(nginx",pid=4643,fd=6),("nginx",pid=4642,fd=6)) ino:33166 sk:56 cgroup:/system.slice/nginx.service <->
LISTEN 0      511          0.0.0.0:8888      0.0.0.0:*    users:(("nginx",pid=4644,fd=8),(nginx",pid=4643,fd=8),("nginx",pid=4642,fd=8)) ino:33168 sk:57 cgroup:/system.slice/nginx.service <->
LISTEN 0      511             [::]:8080         [::]:*    users:(("nginx",pid=4644,fd=7),(nginx",pid=4643,fd=7),("nginx",pid=4642,fd=7)) ino:33167 sk:58 cgroup:/system.slice/nginx.service v6only:1 <->
LISTEN 0      511             [::]:8888         [::]:*    users:(("nginx",pid=4644,fd=9),(nginx",pid=4643,fd=9),("nginx",pid=4642,fd=9)) ino:33169 sk:59 cgroup:/system.slice/nginx.service v6only:1 <->
```

🦦 **Prouvez que les deux sites sont disponibles**

```bash
stan@MacBook-Pro-de-Stanislas ~ % curl 10.1.1.12:8888
<!doctype html>
<html lang="fr">
<head>
  <meta charset="utf-8">
  <title>Titre de la page</title>
  <link rel="stylesheet" href="style.css">
</head>
<body>
  <h1>MEOW site 2</h1>
</body>
</html>
```

```bash
stan@MacBook-Pro-de-Stanislas ~ % curl 10.1.1.12:8080
<!doctype html>
<html lang="fr">
<head>
  <meta charset="utf-8">
  <title>Titre de la page</title>
  <link rel="stylesheet" href="style.css">
</head>
<body>
  <h1>MEOW site 1</h1>
</body>
</html>
```
