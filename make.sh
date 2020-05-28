#!/usr/bin/env bash

set -e
source vars.bash
cp cloud-config.template.yaml cloud-config.yaml
for var in ${!cc_@}
do
    value=${!var}
    sed -i "s;\${$var};$value;g" cloud-config.yaml
done
