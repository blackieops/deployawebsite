## Terraforming CloudFront

Now that we have a bucket, we can create the CloudFront distribution to ensure
it can handle production-level traffic. For now, we're going to be using the
default CloudFront TLS certificate, and not adding any CNAMEs -- that will come
in a later section.

With Terraform, this is again only a single resource, however it has an absurd
amount of options. Complexity is unavoidable when dealing with AWS,
unfortunately; not even Terraform can solve that.

```
resource "aws_cloudfront_distribution" "my-website" {
  enabled         = true
  is_ipv6_enabled = true

  origin {
    domain_name = "${aws_s3_bucket.my-website.bucket_domain_name}"
    origin_id   = "myWebsiteS3"
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  default_cache_behavior {
    target_origin_id = "myWebsiteS3"

    allowed_methods = ["GET", "HEAD"]
    cached_methods  = ["GET", "HEAD"]

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    default_ttl            = 7200
    max_ttl                = 86400
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }
}
```

There's a lot to take in, so let's break it down piece-by-piece.

* `enabled` is hopefully self-expanatory.
* `is_ipv6_enabled` enables IPv6 connectivity on this distribution. This is an
  obvious "yes" for modern-day deployments.
* `origin` defines the S3 bucket CloudFront should serve.
	* `domain_name` is the subdomain endpoint of the S3 bucket. Notice we're
	  using interpolation (`${}`) here to pull the bucket's domain name off of
	  the `aws_s3_bucket` we created previously. This way, if the bucket ever
	  changes, CloudFront will be updated accordingly, without an intervention
	  from us.
	* `origin_id` is just an identifier for the origin. This can be anything,
	  really.
* `restrictions` defines content restrictions for this bucket, and is required.
	* `geo_restriction` allows us to define which CloudFront points-of-presence
	  we want the distribution to be active in. If you, for whatever reason,
	  need to exclude your content from being hosted in a specific part of the
	  world, you can do so with this. In our example, we're not enabling any of
	  restrictions.
* `default_cache_behaviour` defines options on how we want caching to behave.
	* `target_origin_id` this has to match `origin_id` from the `origin` block
	  above. This is due to a weird quirk with how CloudFront works, and is
	  evidence of Terraform struggling to cleanly deal with it.
	* `allowed_methods` is a whitelist of HTTP verbs to allow. Since this is a
	  static site, we will only allow `GET` and `HEAD` requests.
	* `cached_methods` should always be read-only HTTP verbs only; in this case,
	  the same `GET` and `HEAD`.
	* `forwarded_values` defines what request parts should be forwarded along to
	  S3.
		* `query_string` - we're not interested in sending query strings to S3.
		* `cookies` - we're not interested in forwarding cookies to S3.
	* `viewer_protocol_policy` - here we're telling CloudFront to redirect HTTP
	  to HTTPS.
	* `min_ttl` - minimum time a URL can be cached
	* `default_ttl` - if no `Cache-Control` is sent from S3, this is how long a
	  URL will be kept in the cache.
	* `max_ttl` - if a `Cache-Control` is sent from S3, it will only cache up to
	  this many seconds, even if the provided age is larger.
* `viewer_certificate` - for now, we're using the default CloudFront
  certificate. In a later section, we will set up custom TLS certificates.

---

Phew.

Now let's create the distribution. All we need to do now is run the same command
as before:

```
$ terraform apply
```

Terraform will complete quickly, but CloudFront's distribution creation is async
and can take _almost an hour_ to create a distribution, sometimes. Be patient;
perhaps grab a coffee. Best to log into the AWS Console, go to CloudFront, and
wait until your new distribution goes from "In Progress" to "Deployed".
