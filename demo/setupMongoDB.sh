#!/bin/bash
echo "Setting up each shard as a replica set"
./replSet.sh

echo "Adding the shards through the mongos"
./shards.sh
