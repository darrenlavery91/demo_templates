#!/bin/bash

cluster_name="vcluster-01"

echo "Creating a virtual cluster named $cluster_name..."
vcluster create $cluster_name --namespace "$cluster_name" &> "$cluster_name-create.log" &
echo "Virtual cluster $cluster_name is being created in the background. Logs are being saved to $cluster_name-create.log"

# Sleep for 45 seconds to give vcluster time to start
sleep 45

# Check if the vcluster is connected
connection_status=$(vcluster list | grep "$cluster_name" | awk '{print $5}')

if [ "$connection_status" == "True" ]; then
    echo "Connection to the virtual cluster $cluster_name is successful."
else
    echo "Failed to connect to the virtual cluster $cluster_name. Please check the logs."
fi
