def alias($data): {
  Type: "AWS::CloudFormation::Stack",
  Properties: {
    TemplateURL: "../src/http_alias.cfn.yaml",
    Parameters: {
      HostedZone: { Ref: "HostedZone" },
      Region: { Ref: "Region" },
      AliasFrom: $data.AliasFrom,
      AliasToRoute: $data.AliasToRoute,
      AliasToProtocol: $data.AliasToProtocol
    }
  }
};

def generate_aliases($raw): $raw | map({ (.slug): alias({
  AliasFrom: { "Fn::Sub": (.slug + ".${DomainName}") },
  AliasToRoute: .route,
  AliasToProtocol: .protocol
}) } ) | add;

{
  Parameters: $parameters,
  Resources: (generate_aliases(.) * {
    apexDomainAliasToDocs: alias({
      AliasFrom: "invisi.link",
      AliasToProtocol: "https",
      AliasToRoute: "github.com/alexanderbird/invisi.link"
    })
  })
}
