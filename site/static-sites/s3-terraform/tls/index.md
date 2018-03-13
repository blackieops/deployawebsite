At this point you should have a CloudFront distribution serving your site over a
generated CloudFront domain -- we're nearly there! All we need to do now is
set up TLS certificates and configure CloudFront to use our own domain.

Unfortunately, we have to get off the automation bandwagon for a minute for
this: there are a few manual steps, especially around verification, that make
this process much easier when done by hand. Luckily, it is quite simple.

### Get you a TLS

The first step is to either request or import a TLS certificate and key into AWS
Certificate Manager (ACM). We will only be covering the former in this guide.

If you wanted, you could provision a certificate from traditional CA, and import
it into ACM, instead of provisioning a certificate directly from Amazon.  We
will leave it as an exercise for the reader if they wish to investigate that
avenue.

With that said, let's get started.

1. Navigate your way to "Certificate Manager" from the Services menu
2. Click "Request a certificate"
3. Add as many domains to the certificate as you need. For most websites, you'll
   likely only need the apex domain and the `www` subdomain version. It's worth
   noting that you are able to specify a wildcard subdomain if you are unsure of
   how many subdomains you'll need.
4. Choose a validation method: DNS or Email. DNS is often easier. Follow the
   instructions given for whatever method you choose.
5. Click "Review" then "Confirm and request"

Once the validation passes, you should now have a valid TLS certificate!

### Adding TLS to CloudFront

Now that we have a certificate in ACM for our domain, we can configure
CloudFront to use this certificate instead of its default `*.cloudfront.net`.

All we need to do is set the certificate in the `viewer_certificate` block of
our `aws_cloudfront_distribution` resource:

```
resource "aws_cloudfront_distribution" "my-website" {

  [...]

  viewer_certificate {
    acm_certificate_arn = "arn:aws:acm:us-east-1:123456:certificate:a1b2-..."
  }

}
```

The ARN of the certificate is shown in the details of a certificate in the ACM
console.

Additionally, we can now add valid CNAMEs to the distribution:

```
resource "aws_cloudfront_distribution" "my-website" {

  [...]

  aliases = ["www.example.com"]

  [...]

}
```

You will need to wait again, unfortunately, to let CloudFront propagate that
change to all the points-of-presence around the world.
