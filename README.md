# Invisilink

DNS-driven url shortener (it's a toy I built to get more comfortable with
AWS CloudFormation templates) 

Built with AWS Route53 + AWS S3.

## Why

Just a toy project to explore these tools. I wanted to explore CloudFormation
templates, I noticed .link domains are only $5/year, and I wanted to know if I
could build a URL shortener without application layer code.

It can't be done with DNS alone, so there has to be some application layer
code... but S3 redirects is pretty low down in the stack so I'm still satisfied
with the results. 

I'm not suggesting this is a good idea for operating a url shortener at scale.
It's also too read-optimized in my opinion ... to write a new shortened url it
could take minutes since it's a `cloudformation update-stack` call which needs
to make a new Route53 record (and a new S3 bucket). 

I don't see any significant improvement over looking up the slug in a database
and generating an http redirect response on the fly. But, I think what I've
built is interesting and marginally useful, so I'm satisfied. 

### Are you interested in using this?

You're welcome to use this under your own domain. You could fork & customize, or
if you want I'd accept a PR that makes the domain customizable. 

## Usage

Add an entry to [`./redirects`](./redirects) and then re-publish.

## Publishing

    ./build.sh > build/cloudformation.yaml
    ./update-stack.sh

### Monitor progress with

    ./describe_stack_events.sh

### TODO
 - publish as a GitHub action
