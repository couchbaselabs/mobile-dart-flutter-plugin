#!/bin/bash
# Set the username and password variables
cbHost="localhost:8091"
username="Administrator"
password="password"
cbBucket="message" 
cbScope="chat"
<<<<<<< Updated upstream
cbHost="localhost:8091"
sgDb="examplechat"
sgAdminHost="localhost:4985"
=======
cbCollections=("message")
sgRbacUser="syncGatewayUser"
sgRbacUserPass="password"
>>>>>>> Stashed changes
vb=" -v "


#make bucket
curl -u $username:$password $vb -X POST http://$cbHost/pools/default/buckets -d name=$cbBucket -d ramQuota=100 -d bucketType=couchbase  -d storageBackend=couchstore -d maxTTL=0
sleep 10

#make scope
curl -u $username:$password $vb -X POST http://$cbHost/pools/default/buckets/$cbBucket/scopes -d name=$cbScope
sleep 2

<<<<<<< Updated upstream
# Define the list of collection names
collections=("messages")

=======
>>>>>>> Stashed changes
# Iterate through the collections and make the corresponding API calls
for cbCollection in "${cbCollections[@]}"
do
  curl -u $username:$password $vb -X POST http://$cbHost/pools/default/buckets/$cbBucket/scopes/$cbScope/collections -d name=$cbCollection -d maxTTL=0
done

#make RBAC user for Sync Gateway to connect to buckets
curl -u $username:$password $vb -X PUT http://$cbHost/settings/rbac/users/local/$sgRbacUser -d password=$sgRbacUserPass -d roles=mobile_sync_gateway[*]