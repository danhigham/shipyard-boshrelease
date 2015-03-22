#!/usr/bin/env bash

##
# Helper functions used to do initial management of shipyard cluster
#

##
# Register an engine with the cluster
#
# Example usage:

register_node http://10.10.1.10:8080 http://10.1.2.3:2375 4 8192 NEW_NODE

register_node() {

  # Nodes should be registered over https, this is a todo;
  #
  # https://docs.docker.com/articles/https/

  ADDR=$1
  ENGINE_ADDR=$2
  CPU=$3
  MEM=$4
  ID=$5

  # 1. login to controller and gain auth_token
  AUTH="$(curl -s -H "Content-Type: application/json" -d '{ "username": "admin", "password": "shipyard" }' \
    -XPOST $ADDR/auth/login | python -c 'import sys, json; print json.load(sys.stdin)["auth_token"]')"

  echo $AUTH

  # 2. request service token
  TOKEN="$(curl -s -H "Content-Type: application/json" -H "X-Access-Token: admin:$AUTH" \
    -d '{}' -XPOST $ADDR/api/servicekeys | python -c 'import sys, json; print json.load(sys.stdin)["key"]')"

  #3. Register the node
  RET="$(curl -s -H "X-Service-Key: $TOKEN" \
    -d '{ "id": "local", "ssl_cert": "", "ssl_key": "", "ca_cert": "", "engine": { "id": "local", "addr": "$ENGINE_ADDR", "cpus": 4.0, "memory": 8192, "labels": ["local", "dev"] } }' \
    -XPOST $ADDR/api/engines)"

  echo $TOKEN
}
