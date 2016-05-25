<h3 align="center">
  <a href="https://github.com/fastlane/fastlane/tree/master/fastlane">
    <img src="assets/fastlane.png" width="150" />
    <br />
    fastlane
  </a>
</h3>
<p align="center">
  <a href="https://github.com/fastlane/fastlane/tree/master/deliver">deliver</a> &bull;
  <a href="https://github.com/fastlane/fastlane/tree/master/snapshot">snapshot</a> &bull;
  <a href="https://github.com/fastlane/fastlane/tree/master/frameit">frameit</a> &bull;
  <a href="https://github.com/fastlane/fastlane/tree/master/pem">pem</a> &bull;
  <a href="https://github.com/fastlane/fastlane/tree/master/sigh">sigh</a> &bull;
  <a href="https://github.com/fastlane/fastlane/tree/master/produce">produce</a> &bull;
  <a href="https://github.com/fastlane/fastlane/tree/master/cert">cert</a> &bull;
  <a href="https://github.com/fastlane/fastlane/tree/master/spaceship">spaceship</a> &bull;
  <a href="https://github.com/fastlane/fastlane/tree/master/pilot">pilot</a> &bull;
  <a href="https://github.com/fastlane/boarding">boarding</a> &bull;
  <a href="https://github.com/fastlane/fastlane/tree/master/gym">gym</a> &bull;
  <a href="https://github.com/fastlane/fastlane/tree/master/scan">scan</a> &bull;
  <a href="https://github.com/fastlane/fastlane/tree/master/match">match</a> &bull;
  <b>apprepo</b>
</p>
<br/>
<hr/>
<br/>

<p align="center">
  <img src="assets/apprepo.png" height="110">
</p>

apprepo
============

**This project is now in preparation phase. It is secure, therefore none of it works except for tests against test server with sample account & shared public key.**

[![Twitter: @igraczech](https://img.shields.io/badge/contact-%40igraczech-green.svg?style=flat)](https://twitter.com/igraczech)
[![License](https://img.shields.io/badge/license-MIT-green.svg?style=flat)](https://github.com/fastlane/fastlane/blob/master/deliver/LICENSE)
[![Gem](https://img.shields.io/gem/v/apprepo.svg?style=flat)](http://rubygems.org/gems/apprepo)
[![Build Status](https://img.shields.io/circleci/project/suculent/apprepo.svg?style=flat)](https://circleci.com/gh/suculent/apprepo)

###### Deliver IPAs, icons & manifest.json to AppRepo (or any other SFTP server) using a single command.

`apprepo` can upload ipa files, app icons and manifest.json to your Enterprise iOS distribution site from the command line. 

You can vote for Android support as well, Michal.

Get in contact with the developer on Twitter: [@igraczech](https://twitter.com/igraczech)

-------
<p align="center">
    <a href="#features">Features</a> &bull;
    <a href="#installation">Installation</a> &bull;
    <a href="#quick-start">Quick Start</a> &bull;
    <a href="#usage">Usage</a> &bull;
    <a href="#tips">Tips</a> &bull;
    <a href="#need-help">Need help?</a>
</p>

-------

<h5 align="center"><code>apprepo</code> is now just a couple days old 3rd party extension of <a href="https://fastlane.tools">fastlane</a>: The easiest way to automate building and releasing your iOS and Android apps. I'm in contact with Felix Krause to make this part of Fastlane as open SFTP uploader adjacent to `Deliver`.</h5>

# Future Features
- Submit to AppRepo completely automatically
- Upload a new ipa file to AppRepo without Xcode from any Mac
- Maintain your app manifest locally and push changes to AppRepo
- Easily implement a real Continuous Deployment process using [fastlane](https://fastlane.tools)
- Store the configuration in git to easily deploy from **any** Mac, including your Continuous Integration server

To upload builds to AppStore check out [deliver](https://github.com/fastlane/fastlane/tree/master/deliver).

To upload builds to TestFlight check out [pilot](https://github.com/fastlane/fastlane/tree/master/pilot).


# Installation

Install the gem

    sudo gem install apprepo

Make sure, you have the latest version of the Xcode command line tools installed:

    xcode-select --install

# Quick Start

The guide will create all the necessary files for you, [in future also] using the existing app manifest.json from AppRepo (if any). AppRepo on-premise service has nothing to do with iTunesConnect or AppStore Distribution. Its purpose is solely for Enterprise In-House distribution and can leverage your Apple Developer Account credentials to fetch currently valid applications and their bundle identifiers.

Delivery module for your custom SFTP server (e.g. AppRepo, where it specifically supports custom manifest.json format instead of default plist manifest [future todo]).

- ```cd [your_project_folder]```
- ```apprepo init```
- Enter your AppRepo credentials (absolute path to RSA private key for your SFTP server)
- Enter your `APPREPO` APPCODE for this application in AppRepo, you can omit this for own SFTP server (or expect it to be a directory at your SFTP home path as we don't want to limit your creativity).
- Enjoy a good drink, while the computer does all the work for you

From now on, you can run `apprepo` to deploy a new update, or just upload new app manifest.json and icons.


# Usage

... to be done ...

# Credentials

... to be done ...


# Fastlane Tips

## [`fastlane`](https://fastlane.tools) Toolchain

- [`fastlane`](https://fastlane.tools): The easiest way to automate building and releasing your iOS and Android apps
- [`snapshot`](https://github.com/fastlane/fastlane/tree/master/snapshot): Automate taking localized screenshots of your iOS app on every device
- [`frameit`](https://github.com/fastlane/fastlane/tree/master/frameit): Quickly put your screenshots into the right device frames
- [`pem`](https://github.com/fastlane/fastlane/tree/master/pem): Automatically generate and renew your push notification profiles
- [`sigh`](https://github.com/fastlane/fastlane/tree/master/sigh): Because you would rather spend your time building stuff than fighting provisioning
- [`produce`](https://github.com/fastlane/fastlane/tree/master/produce): Create new iOS apps on iTunes Connect and Dev Portal using the command line
- [`cert`](https://github.com/fastlane/fastlane/tree/master/cert): Automatically create and maintain iOS code signing certificates
- [`spaceship`](https://github.com/fastlane/fastlane/tree/master/spaceship): Ruby library to access the Apple Dev Center and iTunes Connect
- [`pilot`](https://github.com/fastlane/fastlane/tree/master/pilot): The best way to manage your TestFlight testers and builds from your terminal
- [`boarding`](https://github.com/fastlane/boarding): The easiest way to invite your TestFlight beta testers
- [`gym`](https://github.com/fastlane/fastlane/tree/master/gym): Building your iOS apps has never been easier
- [`scan`](https://github.com/fastlane/fastlane/tree/master/scan): The easiest way to run tests of your iOS and Mac app
- [`match`](https://github.com/fastlane/fastlane/tree/master/match): Easily sync your certificates and profiles across your team using git

##### [Like this tool? Be the first to know about updates and new fastlane tools](https://tinyletter.com/krausefx)


## Editing the ```Repofile```
Change syntax highlighting to *Ruby*.

# Need help?
Please submit an issue on GitHub and provide information about your setup

# Code of Conduct
Help us keep `apprepo` open and inclusive. Please read and follow our [Code of Conduct](https://github.com/suculent/apprepo/blob/master/CODE_OF_CONDUCT.md).

# License
This project is licensed under the terms of the MIT license. See the LICENSE file.

> This project and all fastlane tools are in no way affiliated with Apple Inc. This project is open source under the MIT license, which means you have full access to the source code and can modify it to fit your own needs. All fastlane tools run on your own computer or server, so your credentials or other sensitive information will never leave your own computer. You are responsible for how you use fastlane tools.
