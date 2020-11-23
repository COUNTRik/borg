#!/bin/bash

# Client and server name
CLIENT=root
SERVER=192.168.50.10

# Repository
REPOSITORY=$CLIENT@$SERVER:/var/backup

export BORG_PASSPHRASE='otus'

# Backup
borg create -v --stats --list $REPOSITORY::etc-'{now:%Y-%m-%d-%H-%M}' /etc
# Prune
if [$(date +%m) > 8]
then
	borg prune -v --show-rc --list $REPOSITORY --keep-daily=1 --keep-within=1y 
else
	borg prune -v --show-rc --list $REPOSITORY --keep-monthly=1 --keep-within=1y 