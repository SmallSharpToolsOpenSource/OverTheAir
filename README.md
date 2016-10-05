# Over the Air

Sample project showing how to prepare for an OTA deployment which can be hosted with an AWS S3 bucket.

Over the Air deployments work with a file manifest which is opened with a URL Scheme which triggers the OTA installation process on iOS devices. In the `template` folder there are templates named `manifest.plist` and `install.html` which include placeholder values which are replaced using `prepare_ota.swift` which uses environment variables and the Info.plist.

Currently the script can be run using the shell script `prepare_ota.sh` but it should be run from an Xcode build so that it can use environment variables which are set with the project target's build scheme.

---

Brennan Stehling - 2016
