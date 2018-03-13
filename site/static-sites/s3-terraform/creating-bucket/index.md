In the [original guide][1], we had to copy around some JSON and click a bunch of
buttons. In Terraform, we just define a single resource.

```
resource "aws_s3_bucket" "my-website" {
  bucket = "my-website"
  acl    = "public-read"
  policy = "${file("s3_public.json")}"
}
```

And in `s3_public.json` we define our normal Bucket Policy:

```json
{
  "Version": "2008-10-17",
  "Statement": [{
    "Sid": "AllowPublicRead",
    "Effect": "Allow",
    "Principal": {
      "AWS": "*"
    },
    "Action": "s3:GetObject",
    "Resource": "arn:aws:s3:::my-website/*"
  }]
}
```

To break it down:

* `resource` takes two arguments: the type of resource (`aws_s3_bucket`) and a
  name of this specific instance of the resource (`my-website`). We can refer to
  attributes of this resource by its name via `aws_s3_bucket.my-website.*`.
* `bucket` is the name of the bucket, in this case `my-website`.
* `acl` applies a "pre-baked" ACL from S3, in this case allowing "public read"
  access to the bucket (i.e. everyone can view its contents).
* `policy` defines a Bucket Policy. We're keeping it in a separate file to keep
  our Terraform readable and clean, but you could also define it inline if you
  really wanted. We're using interpolation syntax `${}` and the helper function
  `file` to read the contents of the file into this attribute.

[1]: /static-sites/s3/

### Running our first Terraform

We're finally ready to run Terraform and have it create our new resource.

Running terraform is easy:

```
$ terraform apply
```

This will present you with a diff, explaining all the resources it wants to
create, update, or destroy. Always review this diff carefully (especially in
production environments).

```
An execution plan has been generated and is shown below.
Resource actions are indicated with the following symbols:
  + create

Terraform will perform the following actions:

  + aws_s3_bucket.my-website
      id:                  <computed>
      acceleration_status: <computed>
      acl:                 "public-read"
      arn:                 <computed>
      bucket:              "deployawebsite-test"
      bucket_domain_name:  <computed>
      force_destroy:       "false"
      hosted_zone_id:      <computed>
      policy:              "[...]"
      region:              <computed>
      request_payer:       <computed>
      versioning.#:        <computed>
      website_domain:      <computed>
      website_endpoint:    <computed>


Plan: 1 to add, 0 to change, 0 to destroy.

Do you want to perform these actions?
  Terraform will perform the actions described above.
  Only 'yes' will be accepted to approve.

  Enter a value:
```

And once you are satisfied it is correct respond with `yes` and Terraform will
create our bucket.
