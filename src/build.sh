#!/bin/bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

touch $DIR/../.env
source $DIR/../.env

set -e
set -x

templates_bucket=invisi.link.internal.templates
templates_bucket_s3="s3://$templates_bucket"

if [ "$1" == "--clean" ]; then
  aws s3 rb $templates_bucket_s3 --force | :
  aws s3api create-bucket --bucket $templates_bucket --region us-west-2 --create-bucket-configuration LocationConstraint=us-west-2
fi

rm -rf $DIR/../tmp
mkdir -p $DIR/../tmp
relative_template_file="$DIR/../tmp/$(date +%s)-relative-invisi.link.cfn.json"
template_file="$DIR/../tmp/$(date +%s)-invisi.link.cfn.yaml"

$DIR/main.cfn.sh > $relative_template_file

aws cloudformation package --s3-bucket $templates_bucket --template-file $relative_template_file --output-template-file $template_file

if [ "$1" == "--clean" ]; then
  aws cloudformation delete-stack --stack-name InvisiLinkAliases
  aws cloudformation wait stack-delete-complete --stack-name InvisiLinkAliases
  aws cloudformation create-stack --stack-name InvisiLinkAliases --template-body file://$template_file
  aws cloudformation wait stack-create-complete --stack-name InvisiLinkAliases
else 
  aws cloudformation update-stack --stack-name InvisiLinkAliases --template-body file://$template_file \
    && aws cloudformation wait stack-update-complete --stack-name InvisiLinkAliases
fi

