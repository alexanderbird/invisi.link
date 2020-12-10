#!/bin/bash

cat src/top.yaml src/apex-domain.yaml \
  <(cat redirects | sed "s/\([a-z0-9]*\) *\(https*\):\/\/\(.*\)/\1 \2 \3/" | xargs -L 1 ./src/template.sh)
