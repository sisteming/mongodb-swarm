#!/bin/bash

echo "Configuring replica set: rs1"
IP=`docker ps | grep rs1a |awk '{print $12}' | awk -F: '{print $1}'`
mongo --host $IP --port 27027 < rs-rs1.js  > rs1.log

echo "Configuring replica set: rs2"
IP=`docker ps | grep rs2a |awk '{print $12}' | awk -F: '{print $1}'`
mongo --host $IP --port 27037 < rs-rs2.js > rs2.log

echo "Configuring replica set: rs3"
IP=`docker ps | grep rs3a |awk '{print $12}' | awk -F: '{print $1}'`
mongo --host $IP --port 27047 < rs-rs3.js  > rs3.log

echo "Configuring replica set: cfg-svr"
IP=`docker ps | grep cfgsvr-a |awk '{print $12}' | awk -F: '{print $1}'`
mongo --host $IP --port 27057 < rs-cfgsvr.js  > cfg.log