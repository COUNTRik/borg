#!/bin/bash

# Environments
CLIENT=root
SERVER=192.168.50.10
REPOSITORY=$CLIENT@$SERVER:/var/backup
NOW=$(date +"%Y-%m-%d-%H-%M")

# Passphrase
export BORG_PASSPHRASE='otus'

# Backup
borg create -v --stats $REPOSITORY::etc-$NOW /etc > /vagrant/$NOW-logfile 2>&1

# Prune
if (($(date +%m)>8))
then
borg prune -v --show-rc --list $REPOSITORY --keep-daily=1 --keep-within=1y
else
borg prune -v --show-rc --list $REPOSITORY --keep-monthly=1 --keep-within=1y
fi