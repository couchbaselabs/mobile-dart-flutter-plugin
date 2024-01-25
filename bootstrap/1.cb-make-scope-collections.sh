#!/bin/bash

# Set the username and password variables
username="Administrator"
password="password"
cbBucket="message" 
cbScope="chat"
cbHost="localhost:8091"
sgDb="examplechat"
sgAdminHost="localhost:4985"
vb=" -v "

#make scope
curl -u $username:$password $vb -X POST http://$cbHost/pools/default/buckets/$cbBucket/scopes -d name=$cbScope

sleep 2

# Define the list of collection names
collections=("messages")

# Iterate through the collections and make the corresponding API calls
for collection in "${collections[@]}"
do
  curl -u $username:$password $vb -X POST http://$cbHost/pools/default/buckets/$cbBucket/scopes/$cbScope/collections -d name=$collection -d maxTTL=0
done
