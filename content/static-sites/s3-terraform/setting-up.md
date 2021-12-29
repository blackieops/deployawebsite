---
title: to S3 and CloudFront with Terraform
article_section: Setting up
next_link: /static-sites/s3-terraform/creating-bucket/
next_text: Creating a Bucket
previous_link: /static-sites/s3-terraform/the-bits/
previous_text: Terraform's Bits
---

Now that we have a general idea of what's involved, we can get started. The
first thing we must do is configure our provider. In this case, `aws`.

Terraform will read from the standard Boto configuration (`~/.aws/credentials`).
If you have a `[default]` profile there, it will be used without any further
steps. If you have named profiles, eg., `[personal]`, you can set the
`AWS_PROFILE` environment variable:

```bash
$ export AWS_PROFILE=personal
```

... and Terraform will use that profile when authenticating.

### The root module

The directory in which you invoke `terraform` becomes the "root module". This
just means all `*.tf` files will be loaded and parsed, and any subfolders will
become importable sub-modules.

For our simple deployment, we likely won't need to split our configuration into
multiple modules, but the flexibility is there if you need to expand in the
future.

To "create" a root module, we just make a folder. For this guide, we'll call it
`static-site-ops`. You can call this whatever makes sense to you, it doesn't
matter.

```bash
$ mkdir static-site-ops
```

Congratulations, you now have a Terraform module.

### Configuring the provider

The provider configuration is incredibly simple.

First, we need to create `main.tf`. Inside it, we configure the provider:

```hcl
provider "aws" {
}
```

It's good practice to lock the version of a provider, however, so we should
ensure we specify this. The easiest way is to leave the version out at first,
then see what version it downloads and use that.

To download the provider, we need to run:

```bash
$ terraform init
```

This command is idempotent and non-destructive; you can run it whenever you
wish, as many times as you wish. In the output, you should be able to find the
version of `aws` that was downloaded (snipped for brevity):

```bash
$ terraform init

[...]

* provider.aws: version = "~> 1.11"

Terraform has been successfully initialized!

[...]
```

The change is simple:

```hcl
provider "aws" {
  version = "~> 1.11"
}
```

But, AWS likes to know _where_ you want to create things, so we should set a
default region as well. S3 and CloudFront work best in `us-east-1` due to
various weird reasons within AWS, so it is recommended to use that (at least as
a default).

```hcl
provider "aws" {
  version = "~> 1.11"
  region = "us-east-1"
}
```

Now we're done! You can run `terraform init` just to be sure, but all should be
well. You're ready to start defining resources.
