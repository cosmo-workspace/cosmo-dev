#!/bin/bash

bash /data/configmap/init.sh &

/usr/bin/entrypoint.sh \
    --auth=$CS_AUTH_TYPE \
    --bind-addr=0.0.0.0:$CS_LISTEN_PORT \
    .