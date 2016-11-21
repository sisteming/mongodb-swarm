#!/bin/bash
eval "$(docker-machine env --swarm marcob-swarm-master)"

docker-machine ssh marcob-swarm-node-1 'sudo mkdir -p /mnt/data/rs1 /mnt/data/rs2 /mnt/data/rs3 /mnt/data/cfg 2> /dev/null; sudo chmod -R 777 /mnt/data/'
docker-machine ssh marcob-swarm-node-2 'sudo mkdir -p /mnt/data/rs1 /mnt/data/rs2 /mnt/data/rs3 /mnt/data/cfg 2> /dev/null; sudo chmod -R 777 /mnt/data/'
docker-machine ssh marcob-swarm-node-3 'sudo mkdir -p /mnt/data/rs1 /mnt/data/rs2 /mnt/data/rs3 /mnt/data/cfg 2> /dev/null; sudo chmod -R 777 /mnt/data/'
docker-machine ssh marcob-swarm-master 'sudo mkdir -p /mnt/data/mongos 2> /dev/null; sudo chmod -R 777 /mnt/data/'

docker-machine ssh marcob-swarm-node-1 'sudo rm -rf /mnt/data/rs1/* /mnt/data/rs2/* /mnt/data/rs3/* /mnt/data/cfg/*'
docker-machine ssh marcob-swarm-node-2 'sudo rm -rf /mnt/data/rs1/* /mnt/data/rs2/* /mnt/data/rs3/* /mnt/data/cfg/*'
docker-machine ssh marcob-swarm-node-3 'sudo rm -rf /mnt/data/rs1/* /mnt/data/rs2/* /mnt/data/rs3/* /mnt/data/cfg/*'
docker-machine ssh marcob-swarm-master 'sudo rm -rf /mnt/data/mongos/*'

docker-machine ssh marcob-swarm-node-1 'sudo sh -c "echo never > /sys/kernel/mm/transparent_hugepage/enabled"'
docker-machine ssh marcob-swarm-node-2 'sudo sh -c "echo never > /sys/kernel/mm/transparent_hugepage/enabled"'
docker-machine ssh marcob-swarm-node-3 'sudo sh -c "echo never > /sys/kernel/mm/transparent_hugepage/enabled"'
docker-machine ssh marcob-swarm-master 'sudo sh -c "echo never > /sys/kernel/mm/transparent_hugepage/enabled"'

docker-machine ssh marcob-swarm-node-1 'sudo sh -c "echo never > /sys/kernel/mm/transparent_hugepage/defrag"'
docker-machine ssh marcob-swarm-node-2 'sudo sh -c "echo never > /sys/kernel/mm/transparent_hugepage/defrag"'
docker-machine ssh marcob-swarm-node-3 'sudo sh -c "echo never > /sys/kernel/mm/transparent_hugepage/defrag"'
docker-machine ssh marcob-swarm-master 'sudo sh -c "echo never > /sys/kernel/mm/transparent_hugepage/defrag"'


docker-machine ssh marcob-swarm-node-1 'ls -la /mnt/data/*'
docker-machine ssh marcob-swarm-node-2 'ls -la /mnt/data/*'
docker-machine ssh marcob-swarm-node-3 'ls -la /mnt/data/*'
docker-machine ssh marcob-swarm-master 'ls -la /mnt/data/*'
