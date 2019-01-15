![Jazz Logo](logo.png)

[![Build Status](https://travis-ci.org/tmobile/jazz-installer.svg?branch=master)](https://travis-ci.org/tmobile/jazz-installer)
[![Gitter](https://img.shields.io/gitter/room/badges/shields.svg)](https://gitter.im/TMO-OSS/Jazz)
[![Slack Chat](https://img.shields.io/badge/Chat-Slack-ff69b4.svg)](https://tmo-oss-getinvite.herokuapp.com/)

# Jazz Serverless Platform

**Seamlessly build, deploy & manage cloud-native applications.**

Jazz addresses gaps and pain points with serverless, particularly for production applications. It is not another FaaS implementation. Rather, it enhances the usability of existing FaaS systems. Jazz has a beautiful UI designed to let developers quickly self-start and focus on code. Its modular design makes it easy to add new integrations:

* **Services** - Today devs can build functions, APIs and static websites. The template-based system makes it easy to define new ones.
* **Deployment Targets** - Currently we deploy to AWS (Lambda, API gateway and S3). We plan to support Azure Functions.

* Now Jazz supports ECS Fargate

* **Features** - Services seamlessly integrate features like monitoring (CloudWatch), logging (ElasticSearch), authentication (Cognito) and secret management (KMS, Vault coming soon).
* **Deployment & CI/CD** - We leverage [Serverless Framework](http://www.serverless.com) and Git/Bitbucket/Jenkins.

Jazz is [open-sourced](http://opensource.t-mobile.com) and under active development by T-Mobile's Cloud Center of Excellence.

[Watch the video preview here.](https://www.youtube.com/watch?v=6Kp1yxMjn1k)

## Install

You can [install Jazz](https://github.com/tmobile/jazz-installer/wiki) in your account using the automated installer.

## Try Jazz!
You can try out public preview version of Jazz by registering with your email address [here](http://try.tmo-jazz.net). You will need a registration code which can be requested by joining [slack](https://tmo-oss-getinvite.herokuapp.com/). Once in slack, go to `#jazz-serverless` channel to get a working registration code.

## User Guide

For more details, see the [Wiki](https://github.com/tmobile/jazz-installer/wiki).

## Development
If you're interested in submitting a PR, it would be a good idea to set up your editor/IDE to use the following checkers:
* [editorconfig](https://editorconfig.org/) so your editor follows the same whitespace/line-ending/indent rules as everyone else.
* [flake8](http://flake8.pycqa.org/en/latest/) for Python linting
* [tflint](https://github.com/wata727/tflint) for Terraform script linting
* [foodcritic](http://www.foodcritic.io/) for Chef script linting

### Tooling
New contributions should consist entirely of Python(2, soon to be 3) code or Terraform scripts. No new shell script code will be accepted, we have too much of it and it's not particularly maintainable. If you want to add a new optional feature (rather than simply bugfix) please chat with the maintainers in Slack before starting, and take a look at the `feature-extensions` subdirectory for an example of how we currently structure such things.

### Branching/release flow
1. Breaking/nontrivial features first go into named feature branches cut from `develop`
2. When/if a feature branch is chosen to be included in the next release, it is merged into `develop`
3. Release testing happens in `develop`
4. When confirmed/vetted, `develop` is merged into `master`, and `master` becomes the current release.
5. Small fixes explicitly intended for the next release can be PRed directly into `develop` without first needing a feature branch.

tl;dr `master` is always the current release, `develop` is always the current state of the next release. If you want to contribute a PR, recommend you fork and work in a branch off of `develop`, then PR against `develop`. Project owners will move you into a feature branch if they deem it necessary.

## License

Jazz is released under the [Apache 2.0 License](http://www.apache.org/licenses/LICENSE-2.0).
