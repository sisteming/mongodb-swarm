#!/usr/local/bin/zsh
#NOTE: Terminate all instances from AWS before this step (if running)

echo "Deleting KeyPairs from AWS..."
aws ec2 delete-key-pair --key-name marcob-swarm-master
aws ec2 delete-key-pair --key-name marcob-swarm-node-1
aws ec2 delete-key-pair --key-name marcob-swarm-node-2
aws ec2 delete-key-pair --key-name marcob-swarm-node-3
aws ec2 delete-key-pair --key-name marcob-consul-machine

sleep 4

echo "Deleting machines from local directory..."
rm -rf ~/.docker/machine/machines/marcob-swarm-node-* ~/.docker/machine/machines/marcob-swarm-master ~/.docker/machine/machines/marcob-consul-*

sleep 4

#Clear automatically
docker-machine rm marcob-consul-machine marcob-swarm-master marcob-swarm-node-1 marcob-swarm-node-2 marcob-swarm-node-3
sleep 5

#Create Discovery Service using Docker Machine
echo "Setting up consul..."
docker-machine create --driver amazonec2 --amazonec2-region eu-west-1 marcob-consul-machine
docker-machine env marcob-consul-machine
eval $(docker-machine env marcob-consul-machine)

#######################################################
#Start consul discovery service
#######################################################
echo "Starting consul..."
export KV_IP=$(docker-machine ssh marcob-consul-machine 'ifconfig eth0 | grep "inet addr:" | cut -d: -f2 | cut -d" " -f1')

docker run -d \
      -p ${KV_IP}:8500:8500 \
      -h consul \
      --restart always \
      progrium/consul -server -bootstrap

sleep 10

#######################################################
#Create Docker Swarm Cluster using Docker Machine
#######################################################
echo "Starting Swarm master connected to consul..."
docker-machine create --driver amazonec2 --amazonec2-region eu-west-1 \
--amazonec2-tags owner,marco.bonezzi,expire-on,2016-12-15 \
--amazonec2-root-size 80 --amazonec2-use-ebs-optimized-instance \
--amazonec2-instance-type m3.2xlarge \
--swarm --swarm-master --swarm-discovery="consul://${KV_IP}:8500" \
--engine-opt="cluster-store=consul://${KV_IP}:8500" \
--engine-opt="cluster-advertise=eth0:2376" marcob-swarm-master


sleep 10

echo "Setting env to connect to --swarm..."
eval "$(docker-machine env --swarm marcob-swarm-master)"

#Create a Swarm Master and point to the Consul discovery service:
# --swarm configures the Machine with Swarm
# --swarm-master configures the created Machine to be Swarm master
# --swarm-discovery defines address of the discovery service
# --cluster-advertise advertise the machine on the network
# --cluster-store designate a distributed k/v storage backend for the cluster
echo "Inspecting swarm master..."
docker-machine inspect --format='{{json .Driver}}'  marcob-swarm-master

#NUM_WORKERS SWARM
echo "Deploying swarm worker nodes.."
sleep 5
export NUM_WORKERS=3; for i in $(seq 1 $NUM_WORKERS); do
    echo "Creating marcob-swarm-node-$i..."
    docker-machine create --driver amazonec2 --amazonec2-region eu-west-1 \
    --amazonec2-tags owner,marco.bonezzi,expire-on,2016-12-15 \
    --amazonec2-root-size 80 --amazonec2-use-ebs-optimized-instance \
    --amazonec2-instance-type m3.2xlarge \
    --swarm --swarm-discovery="consul://${KV_IP}:8500" \
    --engine-opt="cluster-store=consul://${KV_IP}:8500" \
    --engine-opt="cluster-advertise=eth0:2376" marcob-swarm-node-${i} &
done;
wait

#######################################################
# Connect to the Swarm cluster and find some information about it:
#######################################################
eval "$(docker-machine env --swarm marcob-swarm-master)"
