#!/bin/bash

bash /data/configmap/init.sh &

/usr/bin/entrypoint.sh \
    --auth=none \
    --bind-addr=0.0.0.0:18080 \
    .