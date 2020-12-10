# Invisilink

DNS-driven url shortener so meta-tags from the destination are passed through. 

AWS Route53 + AWS S3 (via CloudFormation)

## Why

Just a toy project. I wanted to explore CloudFormation templates, and I noticed
.link domains are only $5/year. 

## Usage


## Publishing

    ./build.sh > build/cloudformation.yaml
    ./update-stack.sh

### Monitor progress with

    ./describe_stack_events.sh
