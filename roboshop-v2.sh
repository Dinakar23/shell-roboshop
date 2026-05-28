#!/bin/bash

AMI_ID="ami-0220d79f3f480ecf5"
ZONE_ID="Z0522495674LVI9OE7CB"
DOMAIN_NAME="dinakardevops.online"

# validation
if [ $# -ne 2 ]; then
    echo -e "$R ERROR:: Atleast 2 arguments required $N"
    echo "USAGE : $0 [create/delete] [instace1] [instace2]"
    exit 1
fi

ACTION=$1
shift # First argument will be removed .

if  [ "$ACTION" != "create" ] && [ "$ACTION" != "delete" ]; then
    echo "ERROR:: First argument must be either create or delete"
    echo "USAGE : $0 [create/delete] [instace1] [instace2]"
    ecit 1
fi 
