+++
title = "Static Site on Amazon S3"
weight = 1
linktitle = "Amazon S3"
[menu.main]
	parent = "Static Sites"
+++

Amazon Web Services is by far the most popular public cloud provider in use
right now. One of the marquee services of the platform is the Simple Storage
Service, or "S3." S3 is an object storage API, which essentially just means you
can upload and retrieve files using it. Amazon officially supports hosting a
static website via Amazon S3, and in this guide we will walk you through setting
up all the necessary parts.

## Why Would You Do This

This is a very popular option for a few key reasons.

* **It's cheap** &mdash; AWS is known for generally being very affordable,
  especially for file storage and CDN purposes. With this setup and
  low-to-moderate traffic, we'll be looking at just a couple dollars per month,
  worst-case. For a high traffic site, with full-page videos and many assets,
  we're still looking at under $100 per month, which is incredible when compared
  to the cost of hosting the same site on servers yourself.
* **Lower risk** &mdash; Since there are no servers to maintain, the
  responsibility of security and stability are offset to Amazon.
* **Ease** &mdash; With no servers to maintain, you can "set-and-forget". You
  don't need to install updates on a small fleet of Linux machines just to run
  your static site.

## Why Would You Not Do This

While this option has may positives, it also has some downsides.

* **No room to grow** &mdash; if you want to add more dynamic components, such
  as a contact form or CMS, you will be out-of-luck in most cases and have to
  rely on external services. S3 just stores files, nothing more; you can't run
  any programming languages or pre-processors without completely re-platforming
  to "real" servers or something like AWS Lambda.
* **Confusing** &mdash; There are a lot of moving parts to this setup. AWS isn't
  the simplest cloud service, and their UX is generally quite horrible.
  Understanding each part of this deployment and how it works could be a
  difficult task to someone unfamiliar with AWS.

As long as you're comfortable with these pitfalls, then let's begin!

## Before You Begin

There are a couple things you'll need before embarking on this #serverless
journey.

1. **A static site**. Hopefully this is obvious, but you'll need at least a
   simple HTML file that will serve as the site you are deploying.
2. **An AWS account**. Head on over to [aws.amazon.com](https://aws.amazon.com/)
   and create an account, filling out your billing information and enabling
   2-factor authentication while you're there.

## Creating the Bucket

From the top bar, find "S3" in the giant index of product offerings under
"Services".

From there, click the "Create Bucket" button. **Note**: bucket names are
globally unique across the entire AWS platform -- this means you won't be able
to pick something generic like `website`, you'll likely need to make it
specific, like `alex-super-sweet-site`. This can be the domain name of your site
if you wish, but for the purposes guide it does not matter what it is called.

In the "Properties" pane of the S3 console, expand the "Static Website Hosting"
panel. Fill out the "Index document" and "Error document" accordingly (eg.,
`index.html` and `5xx.html`, respectively).

While we're in here, expand "Permissions" and click "Add bucket policy". Enter a
policy similar to below:

```
{
	"Version": "2008-10-17",
	"Statement": [
	{
		"Sid": "AllowPublicRead",
		"Effect": "Allow",
		"Principal": {
			"AWS": "*"
		},
		"Action": "s3:GetObject",
		"Resource": "arn:aws:s3:::my-bucket-name/*"
	}
	]
}
```

Of course, replacing `my-bucket-name` with the name of the bucket. Hit "Save".

We're now done configuring the bucket itself. Before we leave, take note of the
"Endpoint" under the "Static Website Hosting" section. We will need this later.

## Creating a User

Before we can upload our site, we need permissions to do so. While we could just
use our administrative credentials for our current user, the "correct" way is to
create a separate user inside of AWS that only has permissions to your site's
bucket; this reduces the risk if someone was to compromise the access keys, as
the attacker wouldn't be able to access anything outside of your site's bucket.

To set this up, we'll head back up to that daunting "Services" menu and find our
way to "IAM".

1. Click on "Users" in the sidebar, and click "Create New Users".
2. Enter a username for the user (this can be anything you like); for example,
   `site-deploy`. Make sure "Generate an access key for each user" is checked.
3. Hit "Create", and you should be presented with an option to "Show User
   Security Credentials". You won't be able to see the Secret Access Key again,
   so write it down somewhere so you don't lose it (you can always generate new
   keys, however, if you do lose it).
4. Click "Close" twice.

Now click on the user in the list, and head to the "Permissions" tab. By
default, an IAM user has no permissions at all.

We're going to create an inline custom policy for this user, as that is the
simplest way to achieve what we want.

Expand "Inline Policies" and "click here". Expand "Custom Policy" and click
"Select". Name the policy something like `site-deploy-s3-only`; the policy
itself should look something like this:

```json
{
	"Version": "2012-10-17",
	"Statement": [
	{
		"Effect": "Allow",
		"Action": "s3:*",
		"Resource": [
			"arn:aws:s3:::my-bucket-name",
			"arn:aws:s3:::my-bucket-name/*"
		]
	}
	]
}
```

Of course, replacing `my-bucket-name` with the name of your bucket.

Finally, hit "Validate Policy" to make sure you didn't make any typos, and then
"Apply Policy".

## Uploading our Site

We're nearly ready to upload our static site to S3. First, we need to install
and configure the AWS command-line utility. Alternatively, you could use a GUI
application like [Panic Transmit](https://panic.com/transmit/), but for this
guide we'll be sticking to the official AWS tools.

### Installing the AWS CLI

The AWS CLI is written in Python and thus can be installed simply via `pip`:

```
$ sudo pip install awscli
```

This should work on any UNIX system, including macOS.

If you're on a distribution of Linux, you may need to install `python-pip`, or a
similarly-named package.

### Configure the AWS CLI

Create a folder in your home directory called `.aws`, and create a file inside
called `credentials`. This is an INI-style file that defines our "profiles".

```
[default]
access_key_id=AKIAEXAMPLEKEY
secret_access_key=2CRRvlTk...
```

### Upload the site files

Now we're finally ready to upload our site to S3. `cd` into the directory with
your static website (the build output, if you're using any pre-processors), and
use the `aws` command to sync to S3:

```
$ aws s3 sync . s3://my-bucket-name
```

A breakdown of what that command does:

* `aws` is the AWS CLI
* `s3` is the service we want to use
* `sync` will upload any files that have changed (since the bucket is empty,
  _all_ files have changed)
* `.` means the current folder; this is the first of two locations, so it is the
  source.
* `s3://my-bucket-name` indicates to the AWS CLI that this is a bucket; as the
  second of two locations, this is the destination.

If we load that Endpoint URL we noted back when creating the bucket, we should
now get our `index.html`. You may think "Great, we're done!", but we have a
couple steps to go still!

## Making it memorable

A domain is an essential part of any modern website. As of recently, AWS now
provides domain registration via a partnership with Gandi. This means you can
get that sweet domain without having to ever leave the AWS complex.

If you already have a domain, just skip the registering part, but follow
everything past that.

Head on up to our favourite "Services" menu, and find "Route53".

### Registering a Domain With Route53

Find and navigate to "Registered Domains" in the sidebar, and click "Register
Domain".

Follow the prompts and fill out any information it asks for. It may take a few
hours for the domain request to be processed.

Once it is, you'll have a Hosted Zone appear for it.

### Setting Up An Existing Domain

If you already have a domain, we will still need to use Route53 for its DNS.
Head to "Hosted Zones" in the sidebar and click "Create Hosted Zone". Enter the
domain name and click "Create".

In the table, you will have a handful of nameserver addresses. You'll need to
update your domain registrar with these new nameservers. Unfortunately, this is
incredibly variable, so check with your registrar on how to do this if you are
unsure.

## Making it Secure

Pretty much every site these days has SSL. With the advent of HTTP/2, it's even
mandatory! The thought of this may install fear in a lot of you. Perhaps you've
had to request SSL certificates before, and are loathing the upcoming `openssl`
commands that you have to copy-paste&hellip; **Fear not!**

Amazon, in January 2016, announced their internal SSL registration service,
Amazon Certificate Manager. Through this we can provision and configure SSL for
our site with just a couple button clicks. The best part: it's included with
every AWS account and is free for as many certificates as you need!

The only downside to this approach is the SSL certificate cannot be exported
from AWS, and thus can only be used with AWS services. If you want to move off
of AWS or use the certificate for a service outside of AWS's offerings, you'll
need to generate a new one using traditional methods.

If you wanted, you could provision a certificate using traditional methods, and
import it into ACM, instead of provisioning a certificate directly from Amazon.
We will leave it as an exercise for the reader if they wish to investigate that
avenue.

With that said, let's get started.

1. Navigate your way to "Certificate Manager" from the Services menu
2. Click "Request a certificate"
3. Add as many domains to the certificate as you need. For most websites, you'll
   likely only need the apex domain and the `www` subdomain version. It's worth
   noting that you are able to specify a wildcard subdomain if you are unsure of
   how many subdomains you'll need.
4. Click "Review and request"
5. Check your email. Amazon will send the WHOIS owner of the domain a
   verification email.

Once confirmed, you should now have a valid SSL certificate for use with AWS
services! This will become useful in the next section.

## Making it fast

We could just CNAME the bucket endpoint to a subdomain and call it a day, but
that's not _technically_ correct ([the best kind of correct](https://www.youtube.com/watch?v=hou0lU8WMgo))
so we must do better! We have to add one more service, and that is CloudFront.

CloudFront is Amazon's global content distribution network. Essentially, it's a
bunch of really fast servers spread around the globe, which your "origin" (S3
bucket) will be propogated to. CloudFront is designed to be extremely scalable,
and optimised for very fast reads; whereas S3 isn't really optimised at all, and
is just meant for storing and retieving, not serving to the world.

CloudFront, like S3, is incredibly cheap, so we'll be getting substatial
scalability and speed for very little extra cost.

### Creating our Distribution

Head up to that now-familiar "Services" menu and hunt for "CloudFront".

Hit "Create Distribution". We're deploying a website, so under "Web" click "Get
Started".

Note: if we don't mention a setting here, just leave it at its default value.

* **Origin Settings**
  * **Origin Domain Name**: DO NOT select the S3 bucket from the autocomplete,
    instead paste in the Endpoint URL from the Static Website Hosting section
    we noted when configuring the bucket.
* **Default Cache Behaviour**
  * **Viewer Protocol Policy**: Redirect HTTP to HTTPS
* **Distribution Settings**
  * **Alternate domain names** should contain the domains that this bucket
	should be associated with. Generally, this will just be `www.example.com`,
	where `example.com` is the domain you registered previously.
  * **SSL Certificate**: select "Custom SSL Certificate" and choose the SSL
	certificate we registered previously from the dropdown.
  * **Custom SSL Client Support**: ENSURE this is set to "SNI"! If this option
	is changed, you will be charged $600USD per month for dedicated servers.
  * **Supported HTTP versions**: HTTP/2, HTTP/1.1, HTTP/1.0
  * **Enable IPv6**: yes! Finally, we've reached 1999.

Now click "Create Distribution" and go get a coffee and probably lunch as well.
CloudFront can take quite a while to set itself up (up to an hour, sometimes).

## Adding DNS Records

By this point, we are assuming you have changed your nameservers, or your domain
has been registered with Route53. We are now ready to start adding DNS records.

AWS has the concept of an "Alias record", which just means we can tell Route53
that a particular subdomain refers to an AWS service, and it will automatically
map it to IP addresses for us, and update it automatically if they change.

We'll create one to start, and point it to our CloudFront distribution.
**Note**: the CloudFront distribution has to be in the "Deployed" state before
this step. If it is still "InProgress", wait for it to finish.

Click "Create Record Set".

* **Name**: `www`
* **Type**: "A &mdash; IPv4 Address"
* **Alias**: Yes
* **Alias Target**: click in this field and wait for it to load (it will take
  several seconds), then choose your CloudFront Distribution.

Click "Save Record Set". Now our site will be available over IPv4, but if you
remember, CloudFront supports IPv6, so we need to add a record for that as well.

Click "Create Record Set".

* **Name**: `www`
* **Type**: "AAAA &mdash; IPv6 Address"
* **Alias**: Yes
* **Alias Target**: click in this field choose your CloudFront Distribution.

Click "Save Record Set".

In many cases, these changes are nearly immediate, but sometimes it may take a
few minutes to take effect.

Once the DNS propogates, you should be able to visit `https://www.example.com`
(where `example.com` is your domain) and you should be greeted with your static
site.

## Fixing the Apex Domain

People are inconsistent. We can't trust all visitors, especially ones who may be
manually typing the address, to remember to add `www`. To combat this, we'll
want to redirect visitors to the "apex domain" (or, as some say, "naked domain")
to our `www` subdomain. AWS makes this fairly simple with the use of an empty S3
bucket.

First, we'll set up the bucket:

1. Navigate to S3 from the Services menu and click "Create Bucket".
2. Name the bucket whatever you wish; for example, `example-com-apex`.
3. In the "Properties" pane to the right, expand "Static Website Hosting"
4. Select "Redirect all requests to another host name" and put in
   `www.example.com` (where `example.com` is your domain name).
5. Before leaving, take note of the "Endpoint" URL that is listed. We will need
   to use this in the next section.
6. Click "Save".

This will work great for HTTP redirects, but our site is HTTPS, so we should
support HTTPS as well. One way to accomplish this is via a second CloudFront
distribution.

1. Navigate to CloudFront from the Services menu.
2. Click "Create Distribution".
3. Follow the same steps as in [Making it fast](#making-it-fast), but using the
   Endpoint URL from our newly-created bucket as the origin, and adding the apex
   domain as the Alternate Name.
4. Once that distribution is deployed, add another Alias DNS record, as we did
   previously, but leaving "Name" blank so it applies to the apex.
