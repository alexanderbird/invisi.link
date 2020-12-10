#!/bin/bash
aws cloudformation describe-stack-events --stack-name InvisiLinkDNSEntries \
  | jq -r ".StackEvents[] | [.LogicalResourceId, .ResourceStatus, .ResourceStatusReason] | @tsv" \
  | column -ts $'\t'
