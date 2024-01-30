# TP1 : Casser avant de construire

**Dans ce TP on va casser des VMs.**

Pour le plaisir ("for fun and profit" comme on dit) mais aussi pour :

- vous pousser à explorer l'environnement par vous-mêmes
- appréhender par vous-mêmes le début de certaines notions
- vous rendre compte qu'on casse pas une machine par hasard, et donc ne pas avoir peur de taper des commandes !

Au début je vous indique des façons de casser la machine, et dans un deuxième temps, je vous laisse être créatifs pour trouver par vos propres moyens d'autres façons de péter la machine.

## Sommaire

- [TP1 : Casser avant de construire](#tp1--casser-avant-de-construire)
  - [Sommaire](#sommaire)
- [I. Setup](#i-setup)
- [II. Casser](#ii-casser)
  - [1. Objectif](#1-objectif)
  - [2. Fichier](#2-fichier)
  - [3. Utilisateurs](#3-utilisateurs)
  - [4. Disques](#4-disques)
  - [5. Malware](#5-malware)
  - [6. You own way](#6-you-own-way)

# I. Setup

# II. Casser

## 1. Objectif

➜ **Vous devez rendre la VM inutilisable. Par inutilisable on entend :**

- elle ne démarre (boot) même plus
- ça boot, mais on ne peut plus se connecter de aucune façon
- ça boot, on peut se co, mais on arrive sur un environnement tellement dégradé qu'il est pas utilisable

➜ **Tout doit être fait depuis le terminal de la VM**

> Si vous avez des doutes sur la validité de votre cassage, demandez-moi !

## 2. Fichier

🦦 **Supprimer des fichiers**

```
Last login: Tue Dec 19 09:21:03 on ttys001
stanislasthabault@MacBook-Pro-de-Stanislas ~ % ssh et0@10.1.1.11  
et0@10.1.1.11's password: 
Last login: Tue Dec 19 09:24:33 2023
[et0@tp1 ~]$ su
Password: 
[root@tp1 et0]# cd ..
[root@tp1 home]# cd ..
[root@tp1 /]# ls
afs  boot  etc   lib    media  opt   root  sbin  sys  usr
bin  dev   home  lib64  mnt    proc  run   srv   tmp  var
[root@tp1 /]# cd boot
[root@tp1 boot]# ls
System.map-5.14.0-284.11.1.el9_2.aarch64
System.map-5.14.0-284.30.1.el9_2.aarch64
config-5.14.0-284.11.1.el9_2.aarch64
config-5.14.0-284.30.1.el9_2.aarch64
dtb
dtb-5.14.0-284.11.1.el9_2.aarch64
dtb-5.14.0-284.30.1.el9_2.aarch64
efi
grub2
initramfs-0-rescue-873435a3b1864a01bc814d23ceed5904.img
initramfs-5.14.0-284.11.1.el9_2.aarch64.img
initramfs-5.14.0-284.11.1.el9_2.aarch64kdump.img
initramfs-5.14.0-284.30.1.el9_2.aarch64.img
initramfs-5.14.0-284.30.1.el9_2.aarch64kdump.img
loader
symvers-5.14.0-284.11.1.el9_2.aarch64.gz
symvers-5.14.0-284.30.1.el9_2.aarch64.gz
vmlinuz-0-rescue-873435a3b1864a01bc814d23ceed5904
vmlinuz-5.14.0-284.11.1.el9_2.aarch64
vmlinuz-5.14.0-284.30.1.el9_2.aarch64
[root@tp1 boot]# rm vmlinuz*
rm: remove regular file 'vmlinuz-0-rescue-873435a3b1864a01bc814d23ceed5904'? y
rm: remove regular file 'vmlinuz-5.14.0-284.11.1.el9_2.aarch64'? y
rm: remove regular file 'vmlinuz-5.14.0-284.30.1.el9_2.aarch64'? y
[root@tp1 boot]# ls
System.map-5.14.0-284.11.1.el9_2.aarch64
System.map-5.14.0-284.30.1.el9_2.aarch64
config-5.14.0-284.11.1.el9_2.aarch64
config-5.14.0-284.30.1.el9_2.aarch64
dtb
dtb-5.14.0-284.11.1.el9_2.aarch64
dtb-5.14.0-284.30.1.el9_2.aarch64
efi
grub2
initramfs-0-rescue-873435a3b1864a01bc814d23ceed5904.img
initramfs-5.14.0-284.11.1.el9_2.aarch64.img
initramfs-5.14.0-284.11.1.el9_2.aarch64kdump.img
initramfs-5.14.0-284.30.1.el9_2.aarch64.img
initramfs-5.14.0-284.30.1.el9_2.aarch64kdump.img
loader
symvers-5.14.0-284.11.1.el9_2.aarch64.gz
symvers-5.14.0-284.30.1.el9_2.aarch64.gz
```

## 3. Utilisateurs

🦦 **Mots de passe**

```
Last login: Tue Dec 19 09:50:55 2023
[et0@tp1 ~]$ su
Password: 
[root@tp1 et0]# cd ..
[root@tp1 home]# cd ..
[root@tp1 /]# cd etc
[root@tp1 etc]# cd pam.d
[root@tp1 pam.d]# ls
config-util       passwd         runuser           su           systemd-user
crond             password-auth  runuser-l         su-l         vlock
fingerprint-auth  polkit-1       smartcard-auth    sudo
login             postlogin      sshd              sudo-i
other             remote         sssd-shadowutils  system-auth
[root@tp1 pam.d]# rm -f systemd-user system-auth password-auth passwd login
```

🦦 **Another way ?**

```
Last login: Tue Dec 19 09:50:55 2023
[et0@tp1 ~]$ su
Password: 
[root@tp1 et0]# cd ..
[root@tp1 home]# cd ..
[root@tp1 /]# cd etc
[root@tp1 etc]# cd pam.d
[root@tp1 pam.d]# ls
config-util       polkit-1             runuser-l              su           
crond             postlogin            smartcard-auth         su-l         
fingerprint-auth  postlogin            sshd                   sudo 
login             remote               sssd-shadowutils       sudo-i       
other             runuser              sssd-shadowutils       vlock
[root@tp1 pam.d]# rm -f login
```

## 4. Disques

🦦 **Effacer le contenu du disque dur**

```
[et0@tp1 ~]$ sudo dd if=/dev/zero of=/dev/mapper/rl-root bs=4M status=progress
[sudo] password for et0: 
5737807872 bytes (5.7 GB, 5.3 GiB) copied, 7 s, 816 MB/s
dd: error writing '/dev/mapper/rl-root': No space left on device
1437+0 records in
1436+0 records out
6023020544 bytes (6.0 GB, 5.6 GiB) copied, 7.38416 s, 816 MB/s
Illegal instruction
[et0@tp1 ~]$ df -h
Segmentation fault
```

## 5. Malware

🦦 **Reboot automatique**

```
Last login: Tue Dec 19 11:03:16 2023
[et0@tp1 ~]$ sudo cat ~/.bashrc
[sudo] password for et0: 
# .bashrc

# Source global definitions
if [ -f /etc/bashrc ]; then
	. /etc/bashrc
fi

# User specific environment
if ! [[ "$PATH" =~ "$HOME/.local/bin:$HOME/bin:" ]]
then
    PATH="$HOME/.local/bin:$HOME/bin:$PATH"
fi
export PATH

# Uncomment the following line if you don't like systemctl's auto-paging feature:
# export SYSTEMD_PAGER=

# User specific aliases and functions
if [ -d ~/.bashrc.d ]; then
	for rc in ~/.bashrc.d/*; do
		if [ -f "$rc" ]; then
			. "$rc"
		fi
	done
fi

unset rc

sudo reboot
```

## 6. You own way

🦦 **Trouvez 4 autres façons de détuire la machine**

Fork Bomb
```
[et0@tp1 ~]$ sudo cat bomb.sh
trap "exec $0" SIGINT
fork_bomb(){
	fork_bomb | fork_bomb &
}

fork_bomb
[et0@tp1 ~]$ sudo cat ~/.bashrc
# .bashrc

# Source global definitions
if [ -f /etc/bashrc ]; then
	. /etc/bashrc
fi

# User specific environment
if ! [[ "$PATH" =~ "$HOME/.local/bin:$HOME/bin:" ]]
then
    PATH="$HOME/.local/bin:$HOME/bin:$PATH"
fi
export PATH

# Uncomment the following line if you don't like systemctl's auto-paging feature:
# export SYSTEMD_PAGER=

# User specific aliases and functions
if [ -d ~/.bashrc.d ]; then
	for rc in ~/.bashrc.d/*; do
		if [ -f "$rc" ]; then
			. "$rc"
		fi
	done
fi

unset rc

sudo bash ~/bomb.sh
```

Delete bash
```
[et0@tp1 ~]$ cd ../../bin
[et0@tp1 bin]$sudo rm bash
```
