# Резервное копирование с помощью BorgBackup

Запустить машины *vagrant up*. Запустятся две машины *client* и *backup*.
Все нужные пакеты установятся с помощью *borg.yml*
Так как для автоматизации borgbackup использует ssh ключ без ввода пароля необходимо сгенерировать ssh ключ для пользоватля *root* на *client* и добавить для пользователя *root* на *backup* в файл *authorized_keys* (root нужен так как скрипт будет запускаться с помощью systemd и копировать файлы из папки /etc).

	[root@client ~]# ssh-keygen
	Generating public/private rsa key pair.
	Enter file in which to save the key (/root/.ssh/id_rsa): 
	Created directory '/root/.ssh'.
	Enter passphrase (empty for no passphrase): 
	Enter same passphrase again: 
	Your identification has been saved in /root/.ssh/id_rsa.
	Your public key has been saved in /root/.ssh/id_rsa.pub.
	The key fingerprint is:
	SHA256:xEBhvtZ5/WaHyA8EI6vKiOQtReHMNyUjpvtp65N7qcA root@client
	The key's randomart image is:
	+---[RSA 2048]----+
	|     .=.         |
	|   + = +         |
	|  * o = + o      |
	| . = o + + +     |
	|  o . + S . o    |
	|.. . . . . o o . |
	| Eo o o     + = .|
	|oooO +       = . |
	|..=*O         .  |
	+----[SHA256]-----+

Проверим ssh соединение

	[root@client ~]# ssh root@192.168.50.10 hostname
	backup

Инициализируем репозиторий запустив команду *borg init* на машине *client*, в данном случае *passphrase* является *otus*.

	[root@client ~]# borg init --encryption=repokey root@192.168.50.10:/var/backup
	Enter new passphrase: 
	Enter same passphrase again: 
	Do you want your passphrase to be displayed for verification? [yN]: y
	Your passphrase (between double-quotes): "otus"
	Make sure the passphrase displayed above is exactly what you wanted.

Если есть желание, то *passphrase* можно задать свой, главное его потом вставить в *borg.sh* в переменную *BORG_PASSPHRASE*.

После запускаем playbook *backup.yml*, который скопирует необходимые файлы и скипты на *client*, а также добавит в автозагрузку сервис и таймер *backup*

	$ ansible-playbook ansible/playbook/backup.yml
	PLAY [Borgbackup] ********************************************************************

	TASK [Gathering Facts] ***************************************************************
	ok: [client]

	TASK [Copy service] ******************************************************************
	changed: [client]

	TASK [Copy timer] ********************************************************************
	changed: [client]

	TASK [Change permissions] ************************************************************
	changed: [client]

	TASK [reload systemd] ****************************************************************
	ok: [client]

	TASK [Start service backup] **********************************************************
	changed: [client]

	TASK [Enable service backup] *********************************************************
	changed: [client]

	TASK [Start timer backup] ************************************************************
	changed: [client]

	TASK [Enable timer backup] ***********************************************************
	changed: [client]

	PLAY RECAP ***************************************************************************
	client                     : ok=9    changed=7    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   

Проверим состояние нашего репозитория

	[root@client vagrant]# borg list root@192.168.50.10:/var/backup
	Enter passphrase for key ssh://root@192.168.50.10/var/backup: 
	etc-2020-11-24-11-34                 Tue, 2020-11-24 11:34:06 [28305e4b6aa4e4d6e161f6158a5e54328291749abbbd019a225fdbff51dad063]

30 минут полет нормальный.

	[root@client vagrant]borg list root@192.168.50.10:/var/backup
	Enter passphrase for key ssh://root@192.168.50.10/var/backup: 
	etc-2020-11-24-11-34                 Tue, 2020-11-24 11:34:06 [28305e4b6aa4e4d6e161f6158a5e54328291749abbbd019a225fdbff51dad063]
	etc-2020-11-24-11-39                 Tue, 2020-11-24 11:39:40 [24a7da2c7446a7379b437e122794b75b6b54713ce11fb0188e163333a43959f6]
	etc-2020-11-24-11-45                 Tue, 2020-11-24 11:45:40 [de5e2fc4c18bd501eb381b948323538802effa9fcbc1b48c73987557218e5384]
	etc-2020-11-24-11-51                 Tue, 2020-11-24 11:51:40 [c1eb84d738ecb52612f4d058d7d6406087cfaaef06466d2fd279094cf6c61285]
	etc-2020-11-24-11-57                 Tue, 2020-11-24 11:57:40 [73771498381c860b98d80235bd37b73a5674ba84ebf44d5fad5c61464e77c1e0]
	etc-2020-11-24-12-02                 Tue, 2020-11-24 12:02:40 [c7a81cd3d40a8b1108a5ace30e2160394dd57c1ffaab888ef690043a400ad851]
	etc-2020-11-24-12-08                 Tue, 2020-11-24 12:08:40 [fde9ead5c73b00d83b08a39480023b7e2c081faef18688acf5f79b9bfa281b40]
	etc-2020-11-24-12-14                 Tue, 2020-11-24 12:14:40 [dcf8142d61c8efb672b3591bc780eff28fd5f75342379f77b7469ea3895e2e5d]

Можем примонтировать архив бэкапа для копирования нужных файлов

	[root@client vagrant]# borg mount root@192.168.50.10:/var/backup::etc-2020-11-24-12-14 /mnt
	Enter passphrase for key ssh://root@192.168.50.10/var/backup: 

Как мы видим, папка *etc* появилась в /mnt

	[root@client vagrant]# ls -l /mnt
	total 0
	drwxr-xr-x. 1 root root 0 Nov 24 11:21 etc


Восстановим файлы например в текущую папку из архива *etc-2020-11-24-12-14* указав его имя в команде *borg extract*

	[root@client vagrant]# borg extract root@192.168.50.10:/var/backup::etc-2020-11-24-12-14
	Enter passphrase for key ssh://root@192.168.50.10/var/backup: 
	Warning: File system encoding is "ascii", extracting non-ascii filenames will not be supported.
	Hint: You likely need to fix your locale setup. E.g. install locales and use: LANG=en_US.UTF-8

Смотрим восстановленные файлы

	[root@client vagrant]# ls /etc/
	DIR_COLORS               fuse.conf       my.cnf             rwtab
	DIR_COLORS.256color      gcrypt          my.cnf.d           rwtab.d
	DIR_COLORS.lightbgcolor  gnupg           netconfig          samba
	GREP_COLORS              groff           networks           sasl2
	NetworkManager           group           nfs.conf           securetty
	X11                      group-          nfsmount.conf      security
	adjtime                  grub.d          nsswitch.conf      selinux
	aliases                  grub2.cfg       nsswitch.conf.bak  services
	aliases.db               gshadow         openldap           sestatus.conf
	alternatives             gshadow-        opt                shadow
	anacrontab               gss             os-release         shadow-
	audisp                   gssproxy        pam.d              shells
	audit                    host.conf       passwd             skel
	bash_completion.d        hostname        passwd-            ssh
	bashrc                   hosts           pkcs11             ssl
	binfmt.d                 hosts.allow     pki                statetab
	centos-release           hosts.deny      pm                 statetab.d
	centos-release-upstream  idmapd.conf     polkit-1           subgid
	chkconfig.d              init.d          popt.d             subuid
	chrony.conf              inittab         postfix            sudo-ldap.conf
	chrony.keys              inputrc         ppp                sudo.conf
	cifs-utils               iproute2        prelink.conf.d     sudoers
	cron.d                   issue           printcap           sudoers.d
	cron.daily               issue.net       profile            sysconfig
	cron.deny                krb5.conf       profile.d          sysctl.conf
	cron.hourly              krb5.conf.d     protocols          sysctl.d
	cron.monthly             ld.so.cache     python             system-release
	cron.weekly              ld.so.conf      qemu-ga            system-release-cpe
	crontab                  ld.so.conf.d    rc.d               systemd
	crypttab                 libaudit.conf   rc.local           tcsd.conf
	csh.cshrc                libnl           rc0.d              terminfo
	csh.login                libuser.conf    rc1.d              tmpfiles.d
	dbus-1                   locale.conf     rc2.d              tuned
	default                  localtime       rc3.d              udev
	depmod.d                 login.defs      rc4.d              vconsole.conf
	dhcp                     logrotate.conf  rc5.d              vimrc
	dracut.conf              logrotate.d     rc6.d              virc
	dracut.conf.d            machine-id      redhat-release     vmware-tools
	e2fsck.conf              magic           request-key.conf   wpa_supplicant
	environment              man_db.conf     request-key.d      xdg
	ethertypes               mc              resolv.conf        xinetd.d
	exports                  mke2fs.conf     rpc                yum
	exports.d                modprobe.d      rpm                yum.conf
	filesystems              modules-load.d  rsyncd.conf        yum.repos.d
	firewalld                motd            rsyslog.conf
	fstab                    mtab            rsyslog.d
