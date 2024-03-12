Create work load to Couchbase Server for:

- Make JSON: true
- Random JSO Values: true
- JSON Size: 900 to 1100 bytes
- Number of JSON Docs: "limited"
- Number of threads: 1
- Rate Limit Number of Operations Per Second: 1000/sec
- Read/Write ratio of: 90/10
- Add Prefix/string to front of key: "100 to 1m"


## RUNNING

The above scripts have be simplifed into a simple script were you pass in a varibale of
1h ,1k, 10k, 100k or 1m

``` terminal
./run-load-gen.sh 1k
```

### DETAILS BELOW

**100 Docs:**

``` terminal
./cbc-pillowfight --json  -R --min-size 900 --max-size 1100 --num-items 100 --set-pct 10 -U couchbase://127.0.0.1:8091/perfTesting -u Administrator -P password  -t 1 --rate-limit 1000 −−key−pr
```

**1K Docs:**

``` terminal
./cbc-pillowfight --json  -R --min-size 900 --max-size 1100 --num-items 1000 --set-pct 10 -U couchbase://127.0.0.1:8091/perfTesting -u Administrator -P password  -t 1 --rate-limit 1000 −−key−prefix 1k: --collection=testing.data
```

**10K Docs:**

``` terminal
./cbc-pillowfight --json -R --min-size 900 --max-size 1100 --num-items 100000 --set-pct 10 -U couchbase://127.0.0.1:8091/perfTesting -u Administrator -P password  -t 1 --rate-limit 1000 −−key−prefix 10k: --collection=testing.data
```


**100K Docs:**

``` terminal
./cbc-pillowfight --json  -R --min-size 900 --max-size 1100 --num-items 100000 --set-pct 10 -U couchbase://127.0.0.1:8091/perfTesting -u Administrator -P password  -t 1 --rate-limit 1000 −−key−prefix 100k: --collection=testing.data
```


**1M Docs:**

``` terminal
./cbc-pillowfight --json  -R --min-size 900 --max-size 1100 --num-items 1000000 --set-pct 10 -U couchbase://127.0.0.1:8091/perfTesting -u Administrator -P password  -t 1 --rate-limit 1000 −−key−prefix 1m: --collection=testing.data
```


**Extra:**
adding scopes and collections to pillow fight

`--collection=_scopeName.collectionName_`  Access data based on full collection name path. Multiple --collection filters can specify the different scopes with different collection names. Note that default collection will not be used if the collection was specified, to enable default collection along with the named ones, it should be specified explicitly --collection=_default._default.

**Docs:**
https://docs.couchbase.com/sdk-api/couchbase-c-client-2.4.0/md_cbc-pillowfight.html


**Pillowfight binary location:** 

``` terminal
/opt/couchbase/bin/cbc-pillowfight
```


**Sync Gateway Sync Function:**

``` JavaScript
function(doc,oldDoc){
   var a = doc._id.split(":");
   channel(a[0]);
}
```

**Creating Sync Gateway User:**

``` terminal
curl -X PUT http://{sg-admin-host}:4985/sgTesting/_user/test -d '{"username":"test","password":"password","admin_channels":["1h","1k","10k","100k","1m"]}' -H "Content-Type: application/json"
```