#!/bin/bash
aws cloudformation update-stack --stack-name InvisiLinkDNSEntries --template-body file://./build/cloudformation.yaml
