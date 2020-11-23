# Резервное копирование с помощью BorgBackup

Запустить машины *vagrant up*. Запустятся две машины *client* и *backup*.
Все нужные пакеты установятся с помощью *borg.yml*.
После необходимо сгенерировать ssh ключ на *client*  

	[vagrant@client ~]$ ssh-keygen
	Generating public/private rsa key pair.
	Enter file in which to save the key (/home/vagrant/.ssh/id_rsa): 
	Enter passphrase (empty for no passphrase): 
	Enter same passphrase again: 
	Your identification has been saved in /home/vagrant/.ssh/id_rsa.
	Your public key has been saved in /home/vagrant/.ssh/id_rsa.pub.

Потом скопировать получившийся публичный ключ пользователю *root*в *backup* в *.ssh/authorized_keys*.
Проверяем соединение с *backup*

	[vagrant@client ~]$ ssh root@192.168.50.10 hostname
	backup

Инициализируем репозиторий

	[vagrant@client ~]$ borg init --encryption=repokey root@192.168.50.10:/var/backup
	Enter new passphrase: 
	Enter same passphrase again: 
	Do you want your passphrase to be displayed for verification? [yN]: y
	Your passphrase (between double-quotes): "otus"
	Make sure the passphrase displayed above is exactly what you wanted.

	By default repositories initialized with this version will produce security
	errors if written to with an older version (up to and including Borg 1.0.8).

	If you want to use these older versions, you can disable the check by running:
	borg upgrade --disable-tam ssh://root@192.168.50.10/var/backup

	See https://borgbackup.readthedocs.io/en/stable/changes.html#pre-1-0-9-manifest-spoofing-vulnerability for details about the security implications.

	IMPORTANT: you will need both KEY AND PASSPHRASE to access this repo!
	Use "borg key export" to export the key, optionally in printable format.
	Write down the passphrase. Store both at safe place(s).

Запускаем *backup.yml*

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

	PLAY RECAP ***************************************************************************
	client                     : ok=5    changed=3    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   

