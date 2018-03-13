Terraform's power really comes into play when you genericize your resources such
that you can apply them to as many different sites and situations as you desire,
thereby significantly reducing the effort involved with deploying similar sites.

To accomplish separation between sites, we will use **workspaces**. A workspace
isolates state, meaning you can use the same Terraform across many environments
without causing conflicts between resources.

For each workspace we create, Terraform will start with a blank state, meaning
it will have no knowledge of any entities that have been previously created, and
will not try and update existing resources with a different domain.

This will not on its own be enough, however. We must also store different values
for the ACM certificate ARN. So we will need **variables**.

In all, we must change only a few things:

First, **add a variable** for our domain name:

```
variable "domain_name" {
  type = "string"
}
```

Then, we also need to **add a variable** for our ACM certificate ARN:

```
variable "acm_arn" {
  type = "string"
}
```

Then we can update our resources to use those variables, with
`${var.domain_name}` and `${var.acm_arm}`:

1. The CloudFront distribution aliases and viewer certificate:

	```
	resource "aws_cloudfront_distribution" "my-website" {
	  [...]
	  aliases = ["www.${var.domain_name}"]
	  [...]
	  viewer_certificate {
	    acm_certificate_arn = "${var.acm_arn}"
	  }
	}

	resource "aws_cloudfront_distribution" "my-website-apex" {
	  [...]
	  aliases = ["${var.domain_name}"]
	  [...]
	  viewer_certificate {
	    acm_certificate_arn = "${var.acm_arn}"
	  }
	}
	```
2. The Route 53 Hosted Zone data:

	```
	data "aws_route53_zone" "myzone" {
	  name = "${var.domain_name}"
	}
	```
3. The Route 53 DNS record:

	```
	resource "aws_route53_record" "apex" {
	  [...]
	  name    = "${var.domain_name}"
	  [...]
	}
	```
4. The bucket name also must be different for each site, so we'll use the
   domain as part of the name to ensure each is unique:

	```
	resource "aws_s3_bucket" "my-website" {
	  bucket = "${var.domain_name}-site"
	  [...]
	}
	```

	And the apex redirect bucket, similarly:

	```
	resource "aws_s3_bucket" "apex" {
	  bucket = "${var.domain_name}-redirect"
	  acl = "public-read"

	  website {
		redirect_all_requests_to = "https://www.${var.domain_name}"
	  }
	}
   ```


With that, our terraform is abstracted enough to apply to any site without
conflicts. Our next step is to create a new workspace for our second site!

First, we can check our current workspace; by default, this will be `default`:

```
$ terraform workspace show
default
```

To do this, we just use the `terraform workspace` command:

```
$ terraform workspace new othersite
```

This will create a new workspace called `othersite` and switch to it. We can
switch between these workspaces with the `select` sub-command:

```
$ terraform workspace select default
```

Each workspace will have its own state, stored under `.terraform.tfstate.d`,
meaning no resources in any workspace will know of each other.

Now when we run Terraform, it will ask us for all our variables. While you could
copy-paste the values in every time, that's not very nice, and is prone to
human error. Instead, we can keep some predefined variables in a `tfvars` file.

Let's create `default.tfvars`, and put our variable values in there:

```
domain_name = "example.com"
acm_arn = "arn:aws:acm:us-east-1:123456:certificate:a1b2c3d4..."
```

Now we pass this to Terraform when we run it, and the values will be populated:

```
$ terraform plan -var-file=default.tfvars
```

### Putting it all together

Now we have multiple workspaces and multiple `tfvars` files, how do we actually
deal with multiple sites? By naming your workspaces the same as your `tfvars`
you can reduce confusion considerably; then for each site, you just:

```
$ terraform workspace select myothersite
$ terraform apply -vars-file=myothersite.tfvars
```
