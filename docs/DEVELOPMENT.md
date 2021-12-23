# Development Setup Instructions

## Initial Setup

The following steps are the initial instructions to clone the codebase locally and setup a virtualenv.

1. Clone repo:

```
git clone https://github.com/wifinigel/wiperf2.git && cd wiperf
```

2. Create virtualenv:

```
python3 -m venv venv
```

3. Activate venv:

```
source venv/bin/activate
```

5. Update pip, setuptool, and wheel (this is only done once)

```
pip install -U pip setuptools wheel
```

6. Install requirements

```
pip install -r requirements.txt
```

## Executing the wiperf module

Ok, now should be read to run the code. This version of the wiperf is packaged into a module. So, we need to instruction Python to run it as a module with the `-m` option.

2. We need to run wiperf as sudo, which means we'll need to pass along the location of the Python environment to sudo like this:

```
sudo venv/bin/python3 -m wiperf
```

If you'd like to run wiperf in debug mode for testing, run with the "--debug" option:

```
sudo venv/bin/python3 -m wiperf --debug
```

Further reading on executing modules with Python at <https://docs.python.org/3/library/runpy.html>.

## Build Debian Package for Testing 

On your _build host_, install the build tools (these are only needed on your build host):

```bash
sudo apt-get install build-essential debhelper devscripts equivs python3-pip python3-all-dev python3-setuptools dh-virtualenv
```

Install Python depends:

```bash
python3 -m pip install mock
```

Update pip, setuptools, and install wheels:

```bash
python3 -m pip install -U pip setuptools wheel
```

This is required, otherwise the tooling will fail when tries to evaluate which tests to run.

## This will install build dependencies

```bash
sudo mk-build-deps -ri
```

## Building our project

From the root directory of this repository run:

```bash
dpkg-buildpackage -us -uc -b
```

Note that -us -uc disables signing the package with GPG. So, if you want to build, test with lintian, sign with GPG:

```bash
debuild
```

If you are found favorable by the packaging gods, you should see some output files at `../wlanpi-app` like this:

```bash
dpkg-deb: building package 'wlanpi-app-dbgsym' in '../wlanpi-app-dbgsym_0.0.1~rc1_arm64.deb'.
dpkg-deb: building package 'wlanpi-app' in '../wlanpi-app_0.0.1~rc1_arm64.deb'.
 dpkg-genbuildinfo --build=binary
 dpkg-genchanges --build=binary >../wlanpi-app_0.0.1~rc1_arm64.changes
dpkg-genchanges: info: binary-only upload (no source code included)
 dpkg-source --after-build .
dpkg-buildpackage: info: binary-only upload (no source included)
(venv) wlanpi@rbpi4b-8gb:[~/dev/wlanpi-app]: ls .. | grep wlanpi-app_
wlanpi-app_0.0.1~rc1_arm64.buildinfo
wlanpi-app_0.0.1~rc1_arm64.changes
wlanpi-app_0.0.1~rc1_arm64.deb
```

## Cheatsheet

New environment?

```
cd <root of repo>
python3 -m venv venv
source venv/bin/activate
pip install -U pip setuptools wheel
pip install -r requirements.txt
sudo systemctl stop wlanpi-wiperf
sudo systemctl status wlanpi-wiperf
sudo venv/bin/python3 -m wiperf
```

Is your development environment already setup?

```
cd <root of repo>
source venv/bin/activate
sudo systemctl stop wlanpi-wiperf
sudo systemctl status wlanpi-wiperf
sudo venv/bin/python3 -m wiperf
```