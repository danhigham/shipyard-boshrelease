#!/usr/bin/env bash

##
# Helper functions used to do initial management of shipyard cluster
#

##
# Register an engine with the cluster
#
# Example usage:

# register_node http://10.10.1.10:8080 http://10.1.2.3:2375 4 8192 NEW_NODE

register_node() {

  # Nodes should be registered over https, this is a todo;
  #
  # https://docs.docker.com/articles/https/

  ADDR=$1
  ENGINE_ADDR=$2
  CPU=$3
  MEM=$4
  ID=$5

  echo "Registering with controller"

  # 1. login to controller and gain auth_token
  AUTH="$(curl -s -H "Content-Type: application/json" -d '{ "username": "admin", "password": "shipyard" }' \
    -XPOST $ADDR/auth/login | /var/vcap/bosh/bin/ruby -e "require 'json'; puts JSON.parse(ARGF.read)['auth_token']")"
  echo "AUTH: $AUTH"

  # 2. request service token
  TOKEN="$(curl -s -H "Content-Type: application/json" -H "X-Access-Token: admin:$AUTH" \
    -d '{}' -XPOST $ADDR/api/servicekeys | /var/vcap/bosh/bin/ruby -e "require 'json'; puts JSON.parse(ARGF.read)['key']")"
  echo $TOKEN

  #3. Register the node
  RET="$(curl -i -H "X-Service-Key: $TOKEN" \
    -d "{\"engine\":{\"id\":\"$ID\",\"addr\":\"$ENGINE_ADDR\",\"cpus\":4,\"memory\":8192,\"labels\":[\"local\", \"dev\"]}}" \
    -XPOST $ADDR/api/engines)"
  echo $RET
}
