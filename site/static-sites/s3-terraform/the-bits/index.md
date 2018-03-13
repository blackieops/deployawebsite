# Terraform's Bits

We won't need in-depth knowledge of Terraform for this guide, but some basics
will greatly help in understanding.

The biggest parts of Terraform are:

* **Resources** - a configuration definition for an external entity. For
  example, `aws_vpc`, or `aws_s3_bucket` map to AWS VPCs and Amazon S3 Buckets,
  respectively.
* **Data** - similar to a resource, but only exposes the attributes of an
  existing entity read-only. This is very useful for things created
  automatically by AWS that you might not have a resource for, but need
  information about.
* **Modules** - a "module" is basically just a folder that contains Terraform.
  Terraform will include all `*.tf` files in a directory, and make those
  available as a "module" with the same name as the directory. By default the
  directory you are running the `terraform` command inside of is called the
  "root module".
* **Providers** - a "provider" is just what it sounds like. For the purposes of
  this guide, we will only be using the `aws` provider, but Terraform supports
  [many more][1], providing wonderous multi-cloud possibilities.

[1]: https://www.terraform.io/docs/providers/index.html
