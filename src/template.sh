slug=$1
protocol=$2
route=$3

cat << EOF
  ${slug}S3Redirect:
    Type: "AWS::S3::Bucket"
    Properties: 
      BucketName: !Sub $slug.\${DomainName}
      AccessControl: PublicRead
      WebsiteConfiguration:
        RedirectAllRequestsTo:
          HostName: $route
          Protocol: $protocol
  ${slug}S3BucketPolicy:
    Type: "AWS::S3::BucketPolicy"
    Properties: 
      Bucket: !Ref ${slug}S3Redirect
      PolicyDocument: 
        Version: "2012-10-17"
        Statement:
          -
            Sid: PublicReadGetObject
            Effect: Allow
            Principal: "*"
            Action:
              - s3:GetObject
            Resource: !Sub "arn:aws:s3:::$slug.\${DomainName}/*"
  ${slug}Route53:
    Type: AWS::Route53::RecordSet
    Properties: 
      HostedZoneId: !Ref HostedZone
      Name: !Sub $slug.\${DomainName}
      Type: A
      AliasTarget:
        HostedZoneId:
          Fn::FindInMap: [ RegionMap, ca-central-1, S3HostedZoneID ]
        DNSName:
          Fn::FindInMap: [ RegionMap, ca-central-1, S3AliasTarget ]
EOF
