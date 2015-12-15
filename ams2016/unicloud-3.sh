#!/bin/bash
set -x 

# Restart the VM and run eval again
docker-machine restart unidata-server
eval "$(docker-machine env unidata-server)"
