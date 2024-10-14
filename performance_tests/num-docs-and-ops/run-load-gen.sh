#!/bin/bash

# Define the base command with common parameters
BASE_CMD="/opt/couchbase/bin/cbc-pillowfight --json -R --min-size 900 --max-size 1100 --set-pct 10 -U couchbase://127.0.0.1:8091/perfTesting -u Administrator -P password -t 1 --rate-limit 1000 --collection=testing.data"

# Check if the argument is provided
if [ $# -eq 0 ]; then
    echo "Usage: $0 {1h|1k|10k|100k|1m}"
    exit 1
fi

# Execute the command based on the input argument
case $1 in

    1h)
        $BASE_CMD --num-items 100 --key-prefix 1h:
        ;;
    1k)
        $BASE_CMD --num-items 1000 --key-prefix 1k:
        ;;
    10k)
        $BASE_CMD --num-items 10000 --key-prefix 10k:
        ;;
    100k)
        $BASE_CMD --num-items 100000 --key-prefix 100k:
        ;;
    1m)
        $BASE_CMD --num-items 1000000 --key-prefix 1m:
        ;;
    *)
        echo "Invalid argument: $1. Please use one of the following: 1h ,1k, 10k, 100k, 1m."
        exit 2
        ;;
esac
