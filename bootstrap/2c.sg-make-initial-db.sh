#!/bin/bash
username="Administrator"
password="password"
sgDb="db"
sgAdminHost="localhost:4985"
vb=" -v "

#make Sync Gateway 

curl -u $username:$password $vb -X PUT http://$sgAdminHost/$sgDb/ -H "Content-Type: application/json" -d@"chat-message-db.json"

sleep 2

# Define the list of users
users=("bob" "tim")

# Iterate through the users and make the corresponding API calls
for user in "${users[@]}"
do
  curl -u $username:$password $vb -X PUT http://$sgAdminHost/$sgDb/_user/$user -H "Content-Type: application/json" -d@"sg-user-$user.json"
done