---
title: to S3 and CloudFront with Terraform
article_section: Redirecting the Apex
next_link: /static-sites/s3-terraform/workspaces/
next_text: Making it Generic
previous_link: /static-sites/s3-terraform/dns/
previous_text: Terraforming DNS
---

So now we have the main site active on `www.`, but we still need to redirect
users that may hit our "bare domain" (often called the "apex"). Instead of
failing to load anything, we should helpfully redirect them to `www`.

There are a number of ways we could do this, but the easiest is likely to use an
empty S3 bucket, configured only to return a redirect, then we can put that
behind CloudFront to have TLS, and set up another Alias record for that.

As you may guess, we've done most of the work already; we can just copy some
Terraform blocks, change a couple fields, and we'll be done.

### The Bucket

This is easy enough, we just need to create a bucket with a "website endpoint"
set to redirect to another URL. This is a built-in feature of S3's website
hosting ability.

```hcl
resource "aws_s3_bucket" "apex" {
  bucket = "example.com-redirect"
  acl = "public-read"

  website {
    redirect_all_requests_to = "https://www.example.com"
  }
}
```

This creates a bucket named `example.com-redirect`, and enables the static
website hosting feature, instructing it to redirect all requests to our actual
website.

### Adding CloudFront

CloudFront will provide us with TLS for this redirect. It may seem like
overkill, but it provides important usability for visitors that still type in
URLs.

Luckily, since our infrastructure is code, we can just copy-paste our existing
CloudFront distribution and change a few things. Here's a diff between the
existing distribution, and what needs to change on this one:

```diff
--- a/main.tf
+++ b/main.tf
@@ -51,16 +51,16 @@ resource "aws_cloudfront_distribution" "my-website" {
   }
 }

-resource "aws_cloudfront_distribution" "my-website" {
+resource "aws_cloudfront_distribution" "my-website-apex" {
   enabled         = true
   is_ipv6_enabled = true

   origin {
-    domain_name = "${aws_s3_bucket.my-website.bucket_domain_name}"
-    origin_id   = "myWebsiteS3"
+    domain_name = "${aws_s3_bucket.apex.website_domain}"
+    origin_id   = "myWebsiteS3Apex"
   }

-  aliases = ["www.example.com"]
+  aliases = ["example.com"]

   restrictions {
     geo_restriction {
@@ -69,7 +69,7 @@ resource "aws_cloudfront_distribution" "my-website" {
   }

   default_cache_behavior {
-    target_origin_id = "myWebsiteS3"
+    target_origin_id = "myWebsiteS3Apex"

     allowed_methods = ["GET", "HEAD"]
     cached_methods  = ["GET", "HEAD"]
```

The changes in detail:

* We first change the name of the resource; now with two CloudFront resources,
  the need for the second parameter (the name) of resources becomes clear.
* `domain_name` is updated to point at the website endpoint for the S3 bucket.
* `origin_id` is updated to reflect what the origin is.
* `aliases` is updated to contain only the apex domain.
* `target_origin_id` is updated accordingly.

Now we just need to copy-paste the Route53 record resources for our apex domain.
This highlights a great feature of the Alias record type: you can use it to
refer to a CNAME on the apex record, something DNS forbids (since Alias records
translate into A records, this is allowed).

A similar diff for our A and AAAA records:

```diff
--- a/main.tf
+++ b/main.tf
@@ -109,14 +109,14 @@ resource "aws_route53_record" "www" {
   }
 }

-resource "aws_route53_record" "www" {
+resource "aws_route53_record" "apex" {
   zone_id = "${data.aws_route53_zone.myzone.zone_id}"
-  name    = "www.example.com"
+  name    = "example.com"
   type    = "A"

   alias {
-    name                   = "${aws_cloudfront_distribution.my-website.domain_name}"
-    zone_id                = "${aws_cloudfront_distribution.my-website.hosted_zone_id}"
+    name                   = "${aws_cloudfront_distribution.my-website-apex.domain_name}"
+    zone_id                = "${aws_cloudfront_distribution.my-website-apex.hosted_zone_id}"
     evaluate_target_health = true
   }
 }
```

Once again we can `terraform apply`, and after about an hour your new CloudFront
distribution should be fully configured and available on the apex of your
domain.

---

If all you wished to accomplish was to launch one site, then congratulations:
you have completed everything necessary. However, if you wish to genericize some
of the Terraform you have written so it can be applied to any site you want,
continue on.
