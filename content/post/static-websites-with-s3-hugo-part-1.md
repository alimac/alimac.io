---
title: Static Websites with S3 and Hugo, Part 1
date: 2018-03-15
categories:
  - Guides
tags:
  - aws
  - s3
  - hugo
  - docker
showSocial: false
comments: false
---

I don't often update my website, but when I do... I switch to another static site generator, or write a blost post about it.
<!--more-->

In the first part of this series, I will discuss how to build a static website hosted on AWS Simple Storage Service (S3) with Terraform.
In the second part, I will focus on my website [build and deploy process with Hugo and Docker](/static-websites-with-s3-hugo-part-2).

## Goals

### HTTPS with custom domain

Once upon a time, I used to host my website on the GitHub Pages platform. It was simple. My website was stored in a special branch (named *gh-pages*). By adding a CNAME file into the repo and pointing corresponding DNS record to the right IP address, I could have a custom domain, too.

However, GitHub Pages did not (and does not) offer native support for HTTPS for custom domains. There is an option to [use CloudFlare](https://hackernoon.com/set-up-ssl-on-github-pages-with-custom-domains-for-free-a576bdf51bc) with GitHub Pages, but after some research, I decided to switch to a different platform altogether.

If you are not yet convinced that you should be using HTTPS for personal or static websites, consider that starting in July 2018, the [Chrome browser will mark HTTP sites as not secure](https://blog.chromium.org/2018/02/a-secure-web-is-here-to-stay.html) in the URL bar. Slowly but surely, we are moving in the direction of encrypted web traffic everywhere.

### A static website

Why static? After spending years managing websites that use content management systems (CMS), typically backed by a relational database for their datastore, I wanted to do as little of website maintenance as possible.

I did not want to worry about CMS vulnerabilities, keeping up with core and plugin updates, or database performance and maintenance.

Static was a good choice for me, because:

- I am comfortable with the command line.
- I find Markdown to be adequate for authoring content.
- I like the ease of portability of my content.

Some of the tradeoffs of a static website include:

- **No interactive components such as a contact form.** I don't particularly have a need for one (contacting me on Twitter is always an option), but there are [third-party alternatives available](https://discourse.gohugo.io/t/is-it-possible-to-add-a-contact-form-to-a-site/1550) for forms.
- **No search functionality**. Again, [solutions exist](https://gohugo.io/tools/search/) to address this need.

Static site generators are enjoying a rennaisance these days, with options available in [pretty much any programming language](https://www.staticgen.com/), even Perl (I used to work with Perl extensively, and still have a fondness for it).

In the past I have used Middleman (Ruby) and Sculpin (PHP). Given that my current go-to ;) language is Go, I decided to give [Hugo](https://gohugo.io/) a try. Okay, I was also inspired by [Arrested DevOps migrating to Hugo](https://discourse.gohugo.io/t/arrested-devops-is-live-with-our-new-hugo-based-site/1871).

### Automated process for creating and deploying

When I first moved the site to AWS, I configured the components (Route 53, Certificate Manager, CloudFront and S3) manually, via the AWS Console. This makes sense -- I was new to AWS and its jargon, and had to tinker with various settings to get everything to work. Using a web interface was a good way to absorb new concepts and make changes quickly.

However, when the site was configured, I did not have a record of the whole setup. If I wanted to build another static site, I would have to look up how the existing site is set up, which can be time-consuming.

There was also an annoying bug: the site was served with both the www and the apex hostname at the same time, instead of one redirecting to the other (`https://www.alimac.io` redirecting to `https://alimac.io`).

This is the story of how I addressed the final goal of storing the infrastructure for the site in code (and how I squashed that pesky bug).

## Platform and tools

For the hosting platform, I am using Amazon Web Services (AWS), with the following components:

- **Route 53** for DNS resolution
- **Certificate Manager** for the SSL certificate
- **CloudFront** for content delivery
- **S3** for storage

For new accounts, AWS offers a free tier for one year. Outside of the free tier, the cost of hosting the site (given its traffic) is less than $1/month:

| Component     | Cost per month |
|:-------------:|:---------------|
| Route 53      | $0.50          |
| CloudFront    | $0.25          |
| S3            | $0.05          |
| Data Transfer | $0.05          |

 If you are looking for a completely free solution, though, something like Netlify might be a better option (and I might explore using Terraform with Netlify in the future).

## Prerequisites

Here are the things you will need to set up a static site on S3 with Terraform.

### AWS account

If you don't already have one, open an AWS account. Instead of using the root user credentials, [create an IAM user with programmatic access](https://docs.aws.amazon.com/IAM/latest/UserGuide/id_users_create.html), and apply the *AdministratorAccess* policy.

Alternatively, use a more limited set of policies:

- *AmazonRoute53FullAccess*
- *CloudFrontFullAccess*
- *AmazonS3FullAccess*
- *AWSCertificateManagerFullAccess*

Access can be restricted even further. In fact, I just created a todo to figure out the minimum access needed :)

[Install AWS command line interface](https://docs.aws.amazon.com/cli/latest/userguide/installing.html) (CLI) and [configure your AWS profile](https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-getting-started.html) with the `aws configure --profile myprofile` command. You will be prompted to provide the access key ID and the access key.

Finally, set environment variables that Terraform will use. For convenience, I set these in my shell profile.

```
export AWS_PROFILE=myprofile
export AWS_DEFAULT_REGION=us-east-1
```

I recommend using `us-east-1`, because CloudFront will only work with SSL certificates in that region. Sad, but true.

### Terraform

[Install Terraform](https://www.terraform.io/intro/getting-started/install.html). Terraform is a tool for storing your infrastructure setup as code. Or, *"an open source tool that codifies APIs into declarative configuration files that can be shared amongst team members, treated as code, edited, reviewed, and versioned"*.

The idea of immutable architecture is very interesting to me, especially figuring out where we choose to draw the boundaries of immutability. This [blog post](https://blog.gruntwork.io/why-we-use-terraform-and-not-chef-puppet-ansible-saltstack-or-cloudformation-7989dad2865c) has a pretty good overview of Terraform, and how it compares to tools like Chef, Puppet, Ansible, Salt, or CloudFormation.

If you are new to Terraform, [Getting Started](https://www.terraform.io/intro/getting-started/install.html) documentation gives a good overview of how to use it and what to expect. I followed this guide when I first got started!

## Steps

Here are the steps Terraform will automate:

1. **Create a hosted zone** for the custom domain.
2. **Generate the SSL certificate**, using DNS for domain validation.
3. **Create two S3 buckets**, one for hosting website content, and one for the redirect.
4. **Create two CloudFront distributions**, one for each bucket. We need CloudFront in order to use the SSL certificate with the static site.

Here is a diagram of the setup for *alimac.io*:

<img src="/images/static-website-s3-diagram.svg"
  alt="Diagram showing AWS components: hosted zone, A records, CloudFront distributions, SSL certificate, and S3 buckets">


Sidenote: I created the preceding diagram using [mermaid](https://mermaidjs.github.io/). Here is the code:

```
graph TD
A[Route 53 Hosted Zone: alimac.io]
A -- A Record: www.alimac.io. --> C1
A -- A Record: alimac.io. --> C2
subgraph CloudFront Distribution
  C1[www.alimac.io] --> E(Multi-domain SSL Certificate)
  C2[alimac.io] --> E
end
E --> D1[S3 bucket: www.alimac.io]
E --> D2[S3 bucket: alimac.io]
D1 -- redirect www to apex --> D2
```

## Terraform code

I made the Terraform code available at https://github.com/alimac/terraform-s3. Grab the repository, and I will break down the process in the following sections.

```
git clone git@github.com:alimac/terraform-s3.git
cd terraform-s3
```

Run `terraform init` to download the AWS provider plugin.

### Primary and secondary domain

Terraform will prompt you to provide two variables:

- `primary_domain` - this is your canonical domain (in my case, `alimac.io`)
- `secondary_domain` - this is the domain that will redirect to the canonical domain (here, `www.alimac.io`)

The S3 bucket names will be set to the primary and secondary domain, respectively.

If you don't want to be prompted for the variable values each time, create a file named `terraform.tfvars` and set the values for each (substitute the domain for your own):

```
primary_domain = "example.com"
secondary_domain = "www.example.com"
```

### Note about name severs

AWS will assign random name servers for your hosted zone. If, like me, you are not using AWS as your domain registrar, you will have to update the name servers associated with your domain using your registrar's website. Depending on your registrar, it may take some time before the update takes effect.

To mitigate this, you can create the hosted zone first (and no other components) by using the `-target` attribute:

```
terraform apply -target aws_route53_zone.zone
```
Source: https://github.com/alimac/terraform-s3/blob/master/zone.tf#L1-L9

Terraform will present a **plan**, and if you approve of the actions listed in the plan, enter *yes* at the prompt.
Once the zone is created, Terraform will output a list of name servers associated with the zone. For example:

```
Outputs:

name_servers = [
  ns-1248.awsdns-28.org,
  ns-1941.awsdns-50.co.uk,
  ns-824.awsdns-39.net,
  ns-104.awsdns-13.com
]
```

Update your registrar with the name servers from the output. When the update is in effect, you should see them listed in the output of the following command:

```
dig +short NS alimac.io
```

### SSL certificate

With the hosted zone created and name servers updated, continue the remainder of the setup:

```
terraform apply
```

For the certificate, Terraform will:

1. Request a certificate for the primary and secondary domains using Subject Alternative Name (SAN).
2. Create two CNAME records for domain validation (one for each domain)
3. Wait for domain validation to complete

Source: https://github.com/alimac/terraform-s3/blob/master/ssl-certificate.tf

By default, Terraform will wait up to 45 minutes for the certificate to be issued. This value can be adjusted. In my experience, validation is completed in 5-10 minutes.

Sometimes Terraform considers domain validation completed too early, and you will see this error:

> The specified SSL certificate doesn't exist, isn't in us-east-1 region, isn't valid, or doesn't include a valid certificate chain.

Running `terraform apply` again after some time will resolve this error.

### S3 buckets

Next, Terraform creates the two S3 buckets:

1. **primary domain bucket**, to host the static website content
2. **seecondary domain bucket**, to redirect to the first bucket

Additionally, Terraform will upload an HTML file to the primary domain bucket so that there is sample "Hello, world" content to view.

Source: https://github.com/alimac/terraform-s3/blob/master/buckets.tf

### CloudFront distributions

CloudFront is the glue that will bring all of the components together.

Terraform will create:

1. A CloudFront distribution for the primary domain and bucket
2. A CloudFront distribution for the secondary domain and bucket
3. Two A records that point to each distribution

Each distribution will use the same multi-domain SSL certificate.

Using two CloudFront distributions  - one for each bucket - instead of a single distribution was the key to solving the bug I mentioned earlier. If this seems like a complicated way to implement a redirect, I agree.

CloudFront distributions support a list of `aliases`. It would be nice if one of aliases could be designated as a primary, and all other aliases redirected to the primary at the CloudFront layer since this is where SSL termination takes place.

Source: https://github.com/alimac/terraform-s3/blob/master/cloudfront.tf

#### Origin types

I wish AWS documentation explained the difference between origin types ([S3 origin versus custom origin](https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/DownloadDistS3AndCustomOrigins.html)) a little clearer. My understanding is that if a bucket is configured as a website endpoint, you have to go with custom origin.

Because of this, [traffic between CloudFront and the origin is not encrypted](https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/using-https-cloudfront-to-s3-origin.html):

> If your Amazon S3 bucket is configured as a website endpoint, you can't configure CloudFront to use HTTPS to communicate with your origin because Amazon S3 doesn't support HTTPS connections in that configuration.

While it is possible to use an S3 origin instead of a custom origin, I found that this broke Hugo's default setting of [pretty URLs](https://gohugo.io/content-management/urls/#pretty-urls) for subpages. For instance, a request to `https://alimac.io/about/` rendered an error:

> **NoSuchKey**

> The specified key does not exist.

One possibility would be to use [ugly URLs](https://gohugo.io/content-management/urls/#ugly-urls) instead. There might also be a way to use redirection rules on the bucket, but I am leaving this as something to research and test at another time.

## End result

At this point we should have a website hosted at the primary domain:

```
curl https://alimac.io
```
```
<html>
  <head>
    <title>Hello, world</title>
  </head>
<body>
  Hello, world
</body>
</html>
```

And a redirect from secondary (www) to primary (apex) domain:
```
curl -I https://www.alimac.io
```
```
HTTP/2 301
content-length: 0
location: https://alimac.io/
...
```

Also, both `http://alimac.io` and `http://www.alimac.io` should redirect to their HTTPS counterparts. Neat!

What would you improve about this design? Which parts could be explained in more detail? Did you find this post useful? Ping me on Twitter [@alimacio](https://twitter.com/alimacio) to let me know.

