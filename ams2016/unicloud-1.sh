#!/bin/bash
set -x 

# Create Azure VM via docker-machine
docker-machine -D create -d azure \
               --azure-subscription-id="3.141" \
               --azure-subscription-cert="/path/to/mycert.pem" \
               --azure-size="ExtraLarge" unidata-server

# Ensure docker commands will be run with new host
eval "$(docker-machine env unidata-server)"
