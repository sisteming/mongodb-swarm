echo "Configuring shards: "
IP=`docker ps | grep mongos |awk '{print $11}' | awk -F: '{print $1}'`
mongo --host $IP --port 27017 < addShard.js
