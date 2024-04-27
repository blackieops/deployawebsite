---
title: Deploy a static site to DigitalOcean
publishDate: 2024-04-27
tags: ["digitalocean", "static-site"]
lede: Deploy your static site on a global CDN automatically using the DigitalOcean App Platform.
---

<div class="box">
<div class="box-content">

{{< anchor "0-preparations" "0. Preparations" >}}

Before continuing, you need to have a few things created:

1. A **[DigitalOcean]** account.
2. A static site. We'll use **Hugo**, but you can use any tool that outputs static HTML. We'll introduce **Docker** later to handle building the static site for production.
3. A Git repository. We'll use **GitHub** but DigitalOcean also supports **GitLab**, if you prefer.
4. (Optionally) A domain name, if this is a production site.

The DigitalOcean App Platform will handle automatic deployments, CDN caching, and TLS certificates for us. You shouldn't need anything else!

[DigitalOcean]: https://www.digitalocean.com/

</div>
</div>

<div class="box box-figure">
<figure>

```dockerfile
# Dockerfile
FROM ubuntu:24.04
RUN apt-get update && \
    apt-get install -y hugo
ADD . /src
RUN hugo -d /src/public
```

</figure>

<div class="box-content">

{{< anchor "1-set-up-docker" "1. Set up Docker" >}}

DigitalOcean supports many common tools out of the box, but it doesn't leave us
with much control or flexibility. Instead, we can provide a Dockerfile to have
DigitalOcean build our site in a container and then deploy the results.

While this doesn't bring us much benefit up-front, it allows for us to control
what version of Hugo we build with, and allows us to configure other build tools
like `npm` if we need to as the site grows. We could even replace Hugo entirely
in the future, and only the Dockerfile has to change - DigitalOcean will be
none the wiser.

Put this code in a `Dockerfile` - note that since the DigitalOcean App Platform
just uses the Dockerfile to build the site, we're not setting up the container
to run a server.

</div>
</div>

<div class="box box-figure">

<figure>
  <img src="/images/static-sites/digitalocean/create-app.webp" alt="Creating an app in DigitalOcean App Platform">
</figure>

<div class="box-content">

{{< anchor "2-create-app" "2. Create App" >}}

1. Log in to your DigitalOcean account.
2. Click the **Create** button in the top right.
3. Select **App Platform** from the list of options.
4. Choose either **GitHub** or **GitLab** and authorize access to the repository with your site in it.
5. Select the repository from the list and ensure "Autodeploy" is enabled.
6. Click **Next**.

</div>
</div>

<div class="box box-figure">

<figure>
  <img src="/images/static-sites/digitalocean/resources.webp" alt="Editing app resources.">
</figure>

<div class="box-content">

{{< anchor "3-configure-resources" "3. Configure Resources" >}}

DigitalOcean may have autodetected the Dockerfile as a container app, which is
not what we want. Hit "Edit" on the resource, and change the "Resource Type" to
"Static Site". You will also need to edit the "Output Directory" to be the path
to the generated output - for the container we created earlier, this will be
`/src/public`.

Once you're done, click "Back", then "Skip to Review" (or manually click
through "Next" a couple more times).

</div>
</div>

<div class="box">
<div class="box-content">

{{< anchor "4-deploy" "4. Deploy" >}}

Once the app is created, it will start building and deploying automatically.

At this point, we're done the basic setup. The latest deploy should show near
the top of the page and give you the link when it's ready. It may take a few
minutes before everything is available.

If you have a custom domain, you can add it under "Settings" &rarr; "Domains",
and follow the given instructions to add the necessary DNS records.

If you enabled "Autodeploy" during the setup, every push to the main branch of
the repository will automatically be deployed within seconds.

Enjoy your new site!

</div>
</div>
