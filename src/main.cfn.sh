#!/bin/bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

cat redirects | sed "s/\([a-z0-9]*\) *\(https*\):\/\/\(.*\)/{ \"slug\": \"\1\", \"protocol\": \"\2\", \"route\": \"\3\"}/" |
  jq -s --argfile parameters $DIR/main.parameters.cfn.json -f $DIR/main.cfn.jq
