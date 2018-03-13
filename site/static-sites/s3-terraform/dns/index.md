If you are satisfied manually managing your DNS records, or with a provider
other than Amazon Route 53, then feel free to skip this section. However, if you
wish to automate the management of DNS records for your new static site using
Route 53 and Terraform, this guide is for you.

### Create the Hosted Zone

If you already have a hosted zone in Route 53, you can skip to the next section.

Unfortunately, similar to setting up TLS certificates, this is better to do by
hand rather than automate.

Creating a hosted zone is quite easy, just click "Create Hosted Zone" and enter
the domain. Once it's created, log into your domain registrar and update the
Nameservers for your domain to use the ones listed in the `NS` record in Route
53.

This can take anywhere from a few minutes to 48 hours, depending on your
registrar. Give it time, and plan accordingly.

### Using Route 53 in Terraform

With a Hosted Zone created, we can start using it in Terraform to automate the
creation and updating of DNS records.

To create our DNS entry, we'll need two things:

1. The ID from the hosted zone, and
2. The domain of the CloudFront resource.

Luckily, we already have all the attributes from the CloudFront distribution
from the resource in Terraform, but since we don't have a resource for the Route
53 Hosted Zone, we'll need to either hardcode the Zone ID, or fetch it
dynamically. Hard-coding is no fun, so let's fetch it! This is where Terraform's
`data` block comes in.

```
data "aws_route53_zone" "myzone" {
  name = "example.com"
}
```

This will reach out and provide access to all the attributes of the Route 53
Hosted Zone with the given domain name.

Now we can put it all together and create a `A` record.

```
resource "aws_route53_record" "www-a" {
  zone_id = "${data.aws_route53_zone.myzone.zone_id}"
  name    = "www.example.com"
  type    = "A"

  alias {
    name                   = "${aws_cloudfront_distribution.my-website.domain_name}"
    zone_id                = "${aws_cloudfront_distribution.my-website.hosted_zone_id}"
    evaluate_target_health = false
  }
}
```

And, since we enabled IPv6 on the distribution, we should add a corresponding
AAAA record so that can be utilized. Simply copy the same `aws_route53_record`
block, but change `type = "A"` to `type = "AAAA"`.

So, what exactly is going on here?

* `zone_id` is our Hosted Zone ID, pulled from the `aws_route53_zone` data.
* `name` is the full name (including the domain itself) this record should serve
* `type` is the type of DNS record; for this `A` and `AAAA` for IPv4 and IPv6,
  respectively.
* `alias` configures the "alias" for this record: a proprietary AWS feature
  allowing this record to "mirror" another record -- commonly, to mirror the DNS
  name of an AWS resource such as ELB or CloudFront distribution.
	* `name` is the alias target; here, the `cloudfront.net` subdomain for our
	  distribution.
	* `zone_id` is the Hosted Zone ID of the **target**. This is a bit weird,
	  and exposes how Alias records work; essentially, this will be the Hosted
	  Zone ID for "cloudfront.net", which Terraform handily provides for us via
	  `hosted_zone_id` on the Cloudfront distribution resource.
	* `evaluate_target_health` is an advanced feature of Route 53, allowing you
	  to swap or disable DNS when the alias target fails to respond to health
	  checks. This cannot be enabled for CloudFront targets.

Run `terraform apply` once again, and once DNS propagates you should have your
site, globally-distributed on a CDN, available on your own domain, secured with
TLS.
