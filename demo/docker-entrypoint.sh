#!/bin/bash
set -e

if [ "${1:0:1}" = '-' ]; then
	set -- mongod "$@"
fi

if [ "$1" = 'mongod' ]; then
	ulimit -n 64000 && ulimit -u 64000
	 # DATA DIRECTORY SETUP
 	mkdir -p /data/db && chown -R mongodb:mongodb /data/db

	chown -R mongodb /data/db
	numa='numactl --interleave=all'
	if $numa true &> /dev/null; then

		set -- $numa "$@"
	fi
	exec gosu mongodb "$@"
fi

exec "$@" 
