MongoDB sharded cluster on Docker containers: Demo
===========

Below there is a brief description of each compose file used to deploy a native MongoDB sharded cluster in Docker containers
===========

Compose files
-----
**`mdb_base.yaml`**

This is the base and starting file where we define the service for each shard (as a replica set). 

		i.e. mongodb_replset_1

This file contains the following definitions:

**image**: Docker image for mongod process with the 3.4.0-rc3 release.

		image: marcob/mongodb-3.4.0-rc3

**labels**: Labels added to each container for this service. These will be used to map the role of each container (mongod, cfgsvr, mongos) and the replica set it belongs to

    	labels:
      		- "role=mongod"
      		- "replset=rs1"

	
**`mdb_repl.yaml`**

This file extends *mdb_base.yaml* and expands each service previously defined into 3 containers for each service. Here we address individual container options for each replica set / shard.

	i.e.  rs1a: extends mongodb_replset_1

This file contains the following definitions:

**ports**: ports mapping HOST:CONTAINER for the mongod process. The ports on the host should be all different to avoid multiple containers trying to map on the same port on a single host.

    ports:
      - 27027:27017

 **volumes**: Data volume mapping HOST:container. Each container will use the /data/ directory for its mongod process. This directory will then be mounted on the host as the /mnt/data/rs1. The mount directory on the host should ideally:
 
* Be a different volume for each container (provisioned from different disks)
* Have enough space and performance

This allow us for instance to access the datafiles for normal operations or just tail the mongod.log file

    volumes:
      - /mnt/data/rs1:/data

**hostname**: hostname associated to this container. This will be used by Swarm multi-host networking for hostname resolution between multiple swarm nodes

    hostname: rs1a

**container_name**: Name of the container to refer to it with Docker tools / logs
    	
    container_name: rs1a

**labels**: Additional label to tag a container with its initial state. This is then use with a soft constraint to try to prevent having multiple primary mongod processes on the same worker node.

    labels:
      - "initialstate=primary"


**command**: Command to be run by the container to start the mongod process inside the container

	   command: mongod --dbpath /data/ --logpath /data/mongod_27027.log --logappend --replSet replset_1 --wiredTigerCacheSizeGB 3


**`mdb_cgroup.yaml`**

This file extends *mdb_repl.yaml* to add the cgroups limits associated to each container. 

This file contains the following definitions:

**cpuset**: Core (or set of cores) where this container will be executed from

    cpuset: "0"

**mem_limit**: Memory (resident only) limit associated to this container

    mem_limit: "6442450944"
    	
**memswap_limit**: Memory (resident + swap) limit associated to this container

    memswap_limit: "6442450944"

**`docker-compose.yml`**

This file extends mdb_cgroup.yaml and the services for each container to glue them all together and add constraint and affinity filters:

This file contains the following definitions:

    
**environment** variables: Here we will define our filters based on the labels defined in mdb_repl.yaml

    environment:
      - "affinity:replset!=rs1" 

Affinity filter to avoid deploying a new container for replset rs1 if there is already on on that node
      
      - "affinity:initialstate!=~primary" 

Affinity soft filter to avoid deploying a new container with a primary initial state if there is already on on that node
      
      - "constraint:node!=marcob-MDBW-swarm-master"

Constraint filter to avoid or force the deployment of a container to a specific swarm node

Steps to a MongoDB sharded cluster with mongod processes
-----
Once we have a Swarm cluster deployed using Docker Machine (and after having all pre-required binaries installed), we can deploy it with the following commands:

**Move to demo directory**

	cd docker-MDB

**Source the Docker environment variables to connect to the Swarm master**	

	eval $(docker-machine env --swarm marcob-swarm-master)

**Deploy all required mongod containers to our Docker swarm nodes (on AWS)**

	docker-compose up -d
	
**Check all containers are deployed**

	docker ps

**Configure each shard as replica set**

The following script will connect to the first instance for each shard (including the config server replica set) and configure the replic set.

	./replSet.sh

**Configure shards for the cluster**

The following script will connect to the mongos and add all three shards for the cluster.

	./addShard.sh

**Connect to the mongos**

At this point, our sharded cluster on docker containers is deployed on the swarm and configured to be used.

Connect to the mongos by getting its host IP from `docker ps` and connecting with the mongo shell:

	mongo --host $mongos_host_ip 

**Confirm the cluster status**

Run the following command to verify the three existing shards:

	sh.status()
	
ToDo
----	
- Create DAB to package and automate the deployment
