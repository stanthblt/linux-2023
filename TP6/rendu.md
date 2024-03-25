# Partie 1 : Mise en place et maîtrise du serveur Web

Dans cette partie on va installer le serveur web, et prendre un peu la maîtrise dessus, en regardant où il stocke sa conf, ses logs, etc. Et en manipulant un peu tout ça bien sûr.

On va installer un serveur Web très très trèèès utilisé autour du monde : le serveur Web Apache.

- [Partie 1 : Mise en place et maîtrise du serveur Web](#partie-1--mise-en-place-et-maîtrise-du-serveur-web)
  - [1. Installation](#1-installation)
  - [2. Avancer vers la maîtrise du service](#2-avancer-vers-la-maîtrise-du-service)

![Tipiii](../img/linux_is_a_tipi.jpg)

## 1. Installation

🖥️ **VM web.tp6.linux**

**N'oubliez pas de dérouler la [📝**checklist**📝](../README.md#checklist).**

| Machine         | IP          | Service     |
| --------------- | ----------- | ----------- |
| `web.tp6.linux` | `10.6.1.11` | Serveur Web |

🌞 **Installer le serveur Apache**

```bash
[et0@web ~]$ sudo dnf install httpd
Last metadata expiration check: 0:29:26 ago on Tue Mar  5 11:03:22 2024.
Package httpd-2.4.57-5.el9.aarch64 is already installed.
Dependencies resolved.
Nothing to do.
Complete!
```

```bash
[et0@web ~]$ sudo cat /etc/httpd/conf/httpd.conf
[sudo] password for et0:

ServerRoot "/etc/httpd"

Listen 80

Include conf.modules.d/*.conf

User apache
Group apache


ServerAdmin root@localhost


<Directory />
    AllowOverride none
    Require all denied
</Directory>


DocumentRoot "/var/www/html"

<Directory "/var/www">
    AllowOverride None
    Require all granted
</Directory>

<Directory "/var/www/html">
    Options Indexes FollowSymLinks

    AllowOverride None

    Require all granted
</Directory>

<IfModule dir_module>
    DirectoryIndex index.html
</IfModule>

<Files ".ht*">
    Require all denied
</Files>

ErrorLog "logs/error_log"

LogLevel warn

<IfModule log_config_module>
    LogFormat "%h %l %u %t \"%r\" %>s %b \"%{Referer}i\" \"%{User-Agent}i\"" combined
    LogFormat "%h %l %u %t \"%r\" %>s %b" common

    <IfModule logio_module>
      LogFormat "%h %l %u %t \"%r\" %>s %b \"%{Referer}i\" \"%{User-Agent}i\" %I %O" combinedio
    </IfModule>


    CustomLog "logs/access_log" combined
</IfModule>

<IfModule alias_module>


    ScriptAlias /cgi-bin/ "/var/www/cgi-bin/"

</IfModule>

<Directory "/var/www/cgi-bin">
    AllowOverride None
    Options None
    Require all granted
</Directory>

<IfModule mime_module>
    TypesConfig /etc/mime.types

    AddType application/x-compress .Z
    AddType application/x-gzip .gz .tgz



    AddType text/html .shtml
    AddOutputFilter INCLUDES .shtml
</IfModule>

AddDefaultCharset UTF-8

<IfModule mime_magic_module>
    MIMEMagicFile conf/magic
</IfModule>


EnableSendfile on

IncludeOptional conf.d/*.conf
```

🌞 **Démarrer le service Apache**

```bash
[et0@web ~]$ sudo systemctl enable httpd
```

```bash
[et0@web ~]$ sudo ss -alntp | grep httpd
LISTEN 0      511                *:80              *:*    users:(("httpd",pid=4401,fd=4),("httpd",pid=4400,fd=4),("httpd",pid=4399,fd=4),("httpd",pid=4396,fd=4))
```

**En cas de problème** (IN CASE OF FIIIIRE) vous pouvez check les logs d'Apache :

```bash
# Demander à systemd les logs relatifs au service httpd
$ sudo journalctl -xe -u httpd

# Consulter le fichier de logs d'erreur d'Apache
$ sudo cat /var/log/httpd/error_log

# Il existe aussi un fichier de log qui enregistre toutes les requêtes effectuées sur votre serveur
$ sudo cat /var/log/httpd/access_log
```

🌞 **TEST**

```bash
[et0@web ~]$ curl localhost
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

## 2. Avancer vers la maîtrise du service

🌞 **Le service Apache...**

```bash
[et0@web ~]$ sudo cat /usr/lib/systemd/system/httpd.service
[sudo] password for et0:
# See httpd.service(8) for more information on using the httpd service.

# Modifying this file in-place is not recommended, because changes
# will be overwritten during package upgrades.  To customize the
# behaviour, run "systemctl edit httpd" to create an override unit.

# For example, to pass additional options (such as -D definitions) to
# the httpd binary at startup, create an override unit (as is done by
# systemctl edit) and enter the following:

#	[Service]
#	Environment=OPTIONS=-DMY_DEFINE

[Unit]
Description=The Apache HTTP Server
Wants=httpd-init.service
After=network.target remote-fs.target nss-lookup.target httpd-init.service
Documentation=man:httpd.service(8)

[Service]
Type=notify
Environment=LANG=C

ExecStart=/usr/sbin/httpd $OPTIONS -DFOREGROUND
ExecReload=/usr/sbin/httpd $OPTIONS -k graceful
# Send SIGWINCH for graceful stop
KillSignal=SIGWINCH
KillMode=mixed
PrivateTmp=true
OOMPolicy=continue

[Install]
WantedBy=multi-user.target
```

🌞 **Déterminer sous quel utilisateur tourne le processus Apache**

```bash
[et0@web ~]$ sudo cat /etc/httpd/conf/httpd.conf

ServerRoot "/etc/httpd"

Listen 80

Include conf.modules.d/*.conf

User 🦦 apache 🦦
Group 🦦 apache 🦦
```

```bash
[et0@web ~]$ ps -ef | grep apache
apache       710     679  0 11:04 ?        00:00:00 php-fpm: pool www
apache       711     679  0 11:04 ?        00:00:00 php-fpm: pool www
apache       712     679  0 11:04 ?        00:00:00 php-fpm: pool www
apache       713     679  0 11:04 ?        00:00:00 php-fpm: pool www
apache       714     679  0 11:04 ?        00:00:00 php-fpm: pool www
apache      4398    4396  0 11:13 ?        00:00:00 /usr/sbin/httpd -DFOREGROUND
apache      4399    4396  0 11:13 ?        00:00:02 /usr/sbin/httpd -DFOREGROUND
apache      4400    4396  0 11:13 ?        00:00:02 /usr/sbin/httpd -DFOREGROUND
apache      4401    4396  0 11:13 ?        00:00:02 /usr/sbin/httpd -DFOREGROUND
```

```bash
[et0@web testpage]$ ls -al
total 12
drwxr-xr-x.  2 root root   24 Mar  5 11:01 .
drwxr-xr-x. 92 root root 4096 Mar  5 11:04 ..
-rw-r--r--.  1 root root 7620 Feb 21 14:12 index.html
```

🌞 **Changer l'utilisateur utilisé par Apache**

```bash
[et0@web testpage]$ sudo adduser web
[et0@web testpage]$ sudo usermod -d /usr/share/httpd -s /sbin/nologin web
```

```bash
[et0@web testpage]$ sudo cat /etc/httpd/conf/httpd.conf | grep User | head -n 1 
User web
```

```bash
[et0@web testpage]$ sudo systemctl restart httpd
[et0@web testpage]$ sudo systemctl status httpd
● httpd.service - The Apache HTTP Server
     Loaded: loaded (/usr/lib/systemd/system/httpd.service; enabled; preset: di>
    Drop-In: /etc/systemd/system/httpd.service.d
             └─php-fpm.conf
     Active: active (running) since Tue 2024-03-05 12:22:51 CET; 4s ago
       Docs: man:httpd.service(8)
   Main PID: 4842 (httpd)
     Status: "Started, listening on: port 80"
      Tasks: 213 (limit: 4251)
     Memory: 28.4M
        CPU: 114ms
     CGroup: /system.slice/httpd.service
             ├─4842 /usr/sbin/httpd -DFOREGROUND
             ├─4843 /usr/sbin/httpd -DFOREGROUND
             ├─4844 /usr/sbin/httpd -DFOREGROUND
             ├─4845 /usr/sbin/httpd -DFOREGROUND
             └─4846 /usr/sbin/httpd -DFOREGROUND

Mar 05 12:22:50 web.tp6.linux systemd[1]: Starting The Apache HTTP Server...
Mar 05 12:22:51 web.tp6.linux systemd[1]: Started The Apache HTTP Server.
Mar 05 12:22:51 web.tp6.linux httpd[4842]: Server configured, listening on:
```

```bash
[et0@web ~]$ ps -u web
    PID TTY          TIME CMD
   1572 ?        00:00:00 httpd
   1573 ?        00:00:00 httpd
   1574 ?        00:00:00 httpd
   1575 ?        00:00:00 httpd
```

🌞 **Faites en sorte que Apache tourne sur un autre port**

```bash
[et0@web ~]$ sudo cat /etc/httpd/conf/httpd.conf | grep Listen
Listen 443
```
```bash
[et0@web ~]$ sudo ss -alntp | grep httpd
LISTEN 0      511                *:443              *:*    users:(("httpd",pid=1872,fd=4),("httpd",pid=1871,fd=4),("httpd",pid=1870,fd=4),("httpd",pid=1868,fd=4))
```

```bash
stan@MacBook-Pro-de-Stanislas ~ % curl 10.1.1.12:443
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

📁 **Fichier `/etc/httpd/conf/httpd.conf`**

➜ **Si c'est tout bon vous pouvez passer à [la partie 2.](../part2/README.md)**

# Partie 2 : Mise en place et maîtrise du serveur de base de données

Petite section de mise en place du serveur de base de données sur `db.tp6.linux`. On ira pas aussi loin qu'Apache pour lui, simplement l'installer, faire une configuration élémentaire avec une commande guidée (`mysql_secure_installation`), et l'analyser un peu.

🖥️ **VM db.tp6.linux**

**N'oubliez pas de dérouler la [📝**checklist**📝](#checklist).**

| Machines        | IP            | Service                 |
|-----------------|---------------|-------------------------|
| `web.tp6.linux` | `10.6.1.11` | Serveur Web             |
| `db.tp6.linux`  | `10.6.1.12` | Serveur Base de Données |

🌞 **Install de MariaDB sur `db.tp6.linux`**

```bash
[et0@db ~]$ sudo dnf install mariadb-server
[sudo] password for et0: 
Last metadata expiration check: 3:02:06 ago on Mon Mar 25 14:36:20 2024.
Package mariadb-server-3:10.5.22-1.el9_2.aarch64 is already installed.
Dependencies resolved.
Nothing to do.
Complete!
```
```bash
[et0@db ~]$ sudo systemctl start mariadb
```
```bash
[et0@db ~]$ sudo systemctl enable mariadb
Created symlink /etc/systemd/system/mysql.service → /usr/lib/systemd/system/mariadb.service.
Created symlink /etc/systemd/system/mysqld.service → /usr/lib/systemd/system/mariadb.service.
Created symlink /etc/systemd/system/multi-user.target.wants/mariadb.service → /usr/lib/systemd/system/mariadb.service.
```
```bash
[et0@db ~]$ sudo mysql_secure_installation
```
```bash
[et0@db ~]$ mysql -u root -p
Enter password: 
Welcome to the MariaDB monitor.  Commands end with ; or \g.
Your MariaDB connection id is 3
Server version: 10.5.22-MariaDB MariaDB Server

Copyright (c) 2000, 2018, Oracle, MariaDB Corporation Ab and others.

Type 'help;' or '\h' for help. Type '\c' to clear the current input statement.

MariaDB [(none)]> 
```

🌞 **Port utilisé par MariaDB**

```bash
[et0@db ~]$ sudo ss -alntp | grep mariadbd
LISTEN 0      80                 *:3306             *:*    users:(("mariadbd",pid=849,fd=19))   
```
```bash 
[et0@db ~]$ sudo firewall-cmd --add-port=3306/tcp --permanent
success
[et0@db ~]$ sudo firewall-cmd --reload
success
[et0@db ~]$ sudo firewall-cmd --list-all | grep ports:
  ports: 3306/tcp
```


🌞 **Processus liés à MariaDB**

```bash
[et0@db ~]$ ps -ef | grep mariadb
mysql        849       1  0 17:36 ?        00:00:00 /usr/libexec/mariadbd --basedir=/usr
```

➜ **Une fois la db en place, go sur [la partie 3.](../part3/README.md)**

# Partie 3 : Configuration et mise en place de NextCloud

Enfin, **on va setup NextCloud** pour avoir un site web qui propose de vraies fonctionnalités et qui a un peu la classe :)

- [Partie 3 : Configuration et mise en place de NextCloud](#partie-3--configuration-et-mise-en-place-de-nextcloud)
  - [1. Base de données](#1-base-de-données)
  - [2. Serveur Web et NextCloud](#2-serveur-web-et-nextcloud)
  - [3. Finaliser l'installation de NextCloud](#3-finaliser-linstallation-de-nextcloud)

## 1. Base de données

Dans cette section, on va préparer le service de base de données pour que NextCloud puisse s'y connecter.

Le but :

- créer une base de données dans le serveur de base de données
- créer une utilisateur dans le serveur de base de données
- donner tous les droits à cet utilisateur sur la base de données qu'on a créé

> Note : ici on parle d'un utilisateur de la base de données. Il n'a rien à voir avec les utilisateurs du système Linux qu'on manipule habituellement. Il existe donc un système d'utilisateurs au sein d'un serveur de base de données, qui ont des droits définis sur des bases précises.

🌞 **Préparation de la base pour NextCloud**

```sql
MariaDB [(none)]> CREATE USER 'nextcloud'@'10.1.1.12' IDENTIFIED BY 'pewpewpew';
Query OK, 0 rows affected (0.006 sec)
```
```sql
MariaDB [(none)]> CREATE DATABASE IF NOT EXISTS nextcloud CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;
Query OK, 1 row affected (0.001 sec)
```
```sql
MariaDB [(none)]> GRANT ALL PRIVILEGES ON nextcloud.* TO 'nextcloud'@'10.1.1.12';
Query OK, 0 rows affected (0.003 sec)
```
```sql
MariaDB [(none)]> FLUSH PRIVILEGES;
Query OK, 0 rows affected (0.001 sec)
```

🌞 **Exploration de la base de données**

```bash
[et0@web ~]$ mysql --version
mysql  Ver 8.0.36 for Linux on aarch64 (Source distribution)
```
```sql
mysql> SHOW DATABASES;
+--------------------+
| Database           |
+--------------------+
| information_schema |
| nextcloud          |
+--------------------+
2 rows in set (0.01 sec)
```
```sql
mysql> USE nextcloud;
Database changed
```
```sql
mysql> SHOW TABLES;
Empty set (0.01 sec)
```

🌞 **Trouver une commande SQL qui permet de lister tous les utilisateurs de la base de données**

```sql
MariaDB [(none)]> USE mysql;
Reading table information for completion of table and column names
You can turn off this feature to get a quicker startup with -A
```
```sql
Database changed
MariaDB [mysql]> SELECT User, Host FROM user;
+-------------+-----------+
| User        | Host      |
+-------------+-----------+
| nextcloud   | 10.1.1.12 |
| mariadb.sys | localhost |
| mysql       | localhost |
| root        | localhost |
+-------------+-----------+
4 rows in set (0.004 sec)
```

## 2. Serveur Web et NextCloud

⚠️⚠️⚠️ **N'OUBLIEZ PAS de réinitialiser votre conf Apache avant de continuer. En particulier, remettez le port et le user par défaut.**

🌞 **Install de PHP**

```bash
[et0@web ~]$ sudo dnf install php
Last metadata expiration check: 1:53:00 ago on Mon Mar 25 18:03:12 2024.
Package php-8.0.30-3.el9.remi.aarch64 is already installed.
Dependencies resolved.
Nothing to do.
Complete!
```

🌞 **Récupérer NextCloud**

- créez le dossier `/var/www/tp6_nextcloud/`
  - ce sera notre *racine web* (ou *webroot*)
  - l'endroit où le site est stocké quoi, on y trouvera un `index.html` et un tas d'autres marde, tout ce qui constitue NextCloud :D
```bash
[et0@web ~]$ sudo dnf install wget
[sudo] password for et0: 
Last metadata expiration check: 2:00:53 ago on Mon Mar 25 18:03:12 2024.
Package wget-1.21.1-7.el9.aarch64 is already installed.
Dependencies resolved.
Nothing to do.
Complete!
```
```bash
[et0@web ~]$ wget https://download.nextcloud.com/server/releases/latest.zip
--2024-03-25 19:58:56--  https://download.nextcloud.com/server/releases/latest.zip
Resolving download.nextcloud.com (download.nextcloud.com)... 5.9.202.145, 2a01:4f8:210:21c8::145
Connecting to download.nextcloud.com (download.nextcloud.com)|5.9.202.145|:443... connected.
HTTP request sent, awaiting response... 200 OK
Length: 220492795 (210M) [application/zip]
Saving to: ‘latest.zip’

latest.zip          100%[===================>] 210.28M  1.17MB/s    in 3m 20s  

2024-03-25 20:02:16 (1.05 MB/s) - ‘latest.zip’ saved [220492795/220492795]
```
```bash
[et0@web ~]$ sudo dnf install unzip
Last metadata expiration check: 2:02:43 ago on Mon Mar 25 18:03:12 2024.
Package unzip-6.0-56.el9.aarch64 is already installed.
Dependencies resolved.
Nothing to do.
Complete!
```
```bash
[et0@web ~]$ sudo cat /var/www/tp6_nextcloud/index.html
<!DOCTYPE html>
<html>
<head>
	<script> window.location.href="index.php"; </script>
	<meta http-equiv="refresh" content="0; URL=index.php">
</head>
</html>
```
```bash
[et0@web ~]$ sudo chown -R apache:apache /var/www/tp6_nextcloud
```

🌞 **Adapter la configuration d'Apache**

- regardez la dernière ligne du fichier de conf d'Apache pour constater qu'il existe une ligne qui inclut d'autres fichiers de conf
- créez en conséquence un fichier de configuration qui porte un nom clair et qui contient la configuration suivante :

```apache
<VirtualHost *:80>
  # on indique le chemin de notre webroot
  DocumentRoot /var/www/tp6_nextcloud/
  # on précise le nom que saisissent les clients pour accéder au service
  ServerName  web.tp6.linux

  # on définit des règles d'accès sur notre webroot
  <Directory /var/www/tp6_nextcloud/> 
    Require all granted
    AllowOverride All
    Options FollowSymLinks MultiViews
    <IfModule mod_dav.c>
      Dav off
    </IfModule>
  </Directory>
</VirtualHost>
```

🌞 **Redémarrer le service Apache** pour qu'il prenne en compte le nouveau fichier de conf

![NextCloud error](../img/nc_install.png)

## 3. Finaliser l'installation de NextCloud

➜ **Sur votre PC**

- modifiez votre fichier `hosts` (oui, celui de votre PC, de votre hôte)
  - pour pouvoir joindre l'IP de la VM en utilisant le nom `web.tp6.linux`
- avec un navigateur, visitez NextCloud à l'URL `http://web.tp6.linux`
  - c'est possible grâce à la modification de votre fichier `hosts`
- normalement une belle page NextCloud qui s'affiche **pour te dire qu'il manque des modules PHP**

🌞 **Installez les deux modules PHP dont NextCloud vous parle**

- vous pouvez les installer avec `dnf`, ils sont aussi fournis par Rocky !
- à faire sur la machine sur laquelle vous avez installé NextCloud bien entendu :)

🌞 **Pour que NextCloud utilise la base de données, ajoutez aussi**

- le module PHP `php-pdo`
- le module PHP `php-mysqlnd`
- à faire sur la machine sur laquelle vous avez installé NextCloud bien entendu :)

➜ **Sur votre PC**

- retournez sur la page
- on va vous demander un utilisateur et un mot de passe pour créer un compte admin
  - ne saisissez rien pour le moment
- cliquez sur "Storage & Database" juste en dessous
  - choisissez "MySQL/MariaDB"
  - saisissez les informations pour que NextCloud puisse se connecter avec votre base
- saisissez l'identifiant et le mot de passe admin que vous voulez, et validez l'installation

🌴 **C'est chez vous ici**, baladez vous un peu sur l'interface de NextCloud, faites le tour du propriétaire :)

🌞 **Exploration de la base de données**

- connectez vous en ligne de commande à la base de données après l'installation terminée
- déterminer combien de tables ont été crées par NextCloud lors de la finalisation de l'installation
  - ***bonus points*** si la réponse à cette question est automatiquement donnée par une requête SQL

➜ **NextCloud est tout bo, en place, tu peux go sur [la partie 4.](../part4/README.md)**