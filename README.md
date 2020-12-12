# Invisilink

DNS-driven url shortener (it's a toy I built to get more comfortable with
AWS CloudFormation templates) 

Built with AWS Route53 + AWS S3.

## Why

Just a toy project to explore these tools. I wanted to explore CloudFormation
templates, I noticed .link domains are only $5/year, and I wanted to know if I
could build a URL shortener without application layer code.

And.... no, I couldn't. See "How does it work" below

As summarized in [this Stack Overflow answer](https://stackoverflow.com/a/9444094/3012550)

> No, what you ask is not possible. DNS is name resolution system and knows nothing about HTTP.

### This is probably not a good idea

I'm not suggesting this is a good idea for operating a url shortener at scale.
It's too read-optimized in my opinion ... to write a new shortened url it could
take minutes since it's a `cloudformation update-stack` call which needs to make
a new Route53 record (and a new S3 bucket). 

I don't see any significant improvement over looking up the slug in a database
and generating an http redirect response on the fly. But, I think what I've
built is interesting and marginally useful, so I'm satisfied. 

## Usage

Add an entry to [`./redirects`](./redirects) and then re-publish.

## Publishing

    src/build.sh


### TODO
 - Add GitHub action to update CFN stack on push
 - I think CFN supports nested stacks... but one way or another, it would be
   nice to replace the `bash` house of cards build scripts with something more
   sensible and idiomatic. 

## How does it work

First, let's compare with what we get when we `curl` a bit.ly URL

```
$ curl -v bit.ly/36CLbfg
*   Trying 67.199.248.10...
* TCP_NODELAY set
* Connected to bit.ly (67.199.248.10) port 80 (#0)
> GET /36CLbfg HTTP/1.1
> Host: bit.ly
> User-Agent: curl/7.54.0
> Accept: */*
>
< HTTP/1.1 301 Moved Permanently
< Server: nginx
< Date: Fri, 11 Dec 2020 00:05:42 GMT
< Content-Type: text/html; charset=utf-8
< Content-Length: 124
< Cache-Control: private, max-age=90
< Location: https://www.healthylivingcottage.com/
< Set-Cookie: _bit=kbb05G-0fa3c505dfb5b90b9a-00R; Domain=bit.ly; Expires=Wed, 09 Jun 2021 00:05:42 GMT
< Via: 1.1 google
<
<html>
<head><title>Bitly</title></head>
<body><a href="https://www.healthylivingcottage.com/">moved here</a></body>
* Connection #0 to host bit.ly left intact
```

The interesting bits: bit.ly returns
  - an HTTP 301 response
  - a `Location` header with the new destination
  - a `Server` header that tells us bit.ly uses nginx
  - some HTML with a link to the new page -- which [RFC 2616 (which describes
    HTTP 301)](https://tools.ietf.org/html/rfc2616#page-62) says "SHOULD" be
    present in the response:
     - "Unless the request method was HEAD, the entity of the
       response SHOULD contain a short hypertext note with a hyperlink to
       the new URI(s)."

And here's `invisi.link`

```
$ curl -v search.invisi.link
* Rebuilt URL to: search.invisi.link/
*   Trying 52.95.146.145...
* TCP_NODELAY set
* Connected to search.invisi.link (52.95.146.145) port 80 (#0)
> GET / HTTP/1.1
> Host: search.invisi.link
> User-Agent: curl/7.54.0
> Accept: */*
> 
< HTTP/1.1 301 Moved Permanently
< x-amz-id-2: HuCfFNGEF5gaeJNifXbch2n6F6HwsPJC+53MLthfLjJcY8C4PnaLLbDpsoxz4i7VaFTAEvxT19k=
< x-amz-request-id: EA6559746AC9F219
< Date: Fri, 11 Dec 2020 00:09:39 GMT
< Location: https://google.com/
< Content-Length: 0
< Server: AmazonS3
< 
* Connection #0 to host search.invisi.link left intact
```
The important stuff is the same thing: HTTP 301 with a Location header. Also
 - the `Server` header indicates it's `AmazonS3`
 - there's no HTML response

### So what's different?

1. invisi.link uses DNS entries instead of database entries for mapping shortened urls to full
   urls. Technically this is faster for reads, but it's way more complicated for
   writes... and does anyone need a faster URL shortener? I don't think so. 
2. invisi.link uses Amazon S3 instead of NGINX + custom code for returning the
   HTTP status codes... which might seem like less operational load, except that
   each link needs its own bucket which is a separate deployment, so it would
   probably be way more painful to operate.
3. Apparently Amazon S3 ignores the "SHOULD" note from the HTTP 301 RFC by not
   sending any HTML with the link to the new page. But... unless your browser
   doesn't know what to do with HTTP 301 (?!), I can't see this being a problem.
    - &lt;pedantry&gt;In any case [SHOULD is optional if you have a good reason](https://tools.ietf.org/html/rfc2119)
     so it's not technically deviating from the spec as long as for the folks in Amazon S3 it's true that
     "the full implications [are] understood and carefully weighed before choosing
     [this] different course" 😉
