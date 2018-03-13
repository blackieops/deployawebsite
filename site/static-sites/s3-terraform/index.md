Perhaps you have followed our original guide on [launching a static site using
Amazon S3 and CloudFront][1], but are turned off by the amount of repetitive
work you'll have to do if you have multiple sites.

[1]: /static-sites/s3/

## A fully-automated cloud

Using [Hashicorp Terraform][2], we can automate the creation and configuration
of cloud resources, especially Amazon Web Services, thus providing a
reproducible way of setting up the infrastructure for your sites.

Hashicorp Terraform is essentially a DSL for cloud resources. It allows you to
define "resources", mapping to external entities on various cloud providers.
Terraform maintains the last-known state of everything it creates, and assures
on every run the live resources match what the state says they should look like.

There are enormous benefits to this, for both corporations and individuals.

* For corporations: **increase in auditability** - if every cloud resource you
  create is tracked in version control, you know anything created outside of
  that is likely unofficial.
* For individuals: **less time spend on operations** - if you just want to
  launch a site for a friend, but don't want to spend the time setting up
  S3 bucket policies by hand, having a reusable set of Terraform resources means
  you can quickly reproduce common infrastructure.
* For corporations: **reduction in simple mistakes** - obviously humans are
  still involved, but to a much lesser degree; thus, mistakes due to fatigue or
  typos will be much harder to accomplish, especially if every change follows
  code-review practices just as application code would.

[2]: https://www.terraform.io

## Installing Terraform

Terraform is a self-contained, static binary, which makes it incredibly easy to
install. Simply [download it from the Terraform website][3] and place it
somewhere in your path (something like `/usr/local/bin` is often a good choice).
Or, just keep it in the current folder and invoke it directly.

To test, ensure you can just run `terraform` and it should print some help. Now
we can get started.

[3]: https://www.terraform.io/downloads.html
