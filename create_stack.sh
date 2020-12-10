#!/bin/bash
aws cloudformation create-stack --stack-name InvisiLinkDNSEntries --template-body file://./dns-template.yaml
