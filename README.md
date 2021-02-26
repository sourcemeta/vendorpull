vendorpull
==========

Platform Support
----------------

Vendorpull runs in any POSIX system such as GNU/Linux, macOS, FreeBSD, etc. Its
only external dependency is `git`.

Vendorpull can be run in Microsoft Windows through the [Windows Subsystem for
Linux](https://docs.microsoft.com/en-us/windows/wsl/) or
[MinGW](https://sourceforge.net/projects/mingw/).

Installation
------------

Go to the root of the repository you want to setup `vendorpull` in and run the
following command:

```sh
/bin/sh -c "$(curl -fsSL https://raw.githubusercontent.com/jviotti/vendorpull/master/bootstrap.sh)"
```

The bootstrap script will install `vendorpull` at `vendor/vendorpull` and set
`vendorpull` as a dependency in a way such that `vendorpull` can manage itself.

Managing Dependencies
---------------------

You can declare your dependencies using a simple `DEPENDENCIES` file where each
row corresponds to a repository you want to vendor in your project. For example:

```
vendorpull https://github.com/jviotti/vendorpull 6a4d9aa9d8ee295151fd4cb0ac59f30f20217a8f
depot_tools https://chromium.googlesource.com/chromium/tools/depot_tools.git 399c5918bf47ff1fe8477f27b57fa0e8c67e438d
electron https://github.com/electron/electron 68d9adb38870a6ea4f8796ba7d4d9bea2db7b7a0
```

In this case, we're vendoring `vendorpull` itself, Chromium's `depot_tools`,
and the Electron project.

- The first column defines the dependency name as it will be vendored inside
  the `vendor` directory
- The second column defines the repository `git` URL of the dependency
- The third column defines the `git` revision of the project that you want to
  vendor. It can be any `git` revision such as a commit hash, a tag, etc

In order to pull all dependencies, run the following command:

```sh
./vendor/vendorpull/vendorpull.sh
```

You can also pull a single dependency by specifying its name as the first argument. For example:

```sh
./vendor/vendorpull/vendorpull.sh depot_tools
```

Updating
--------

`vendorpull` is managed using `vendorpull` itself. Therefore you can update
`vendorpull` by running the following command:

```sh
./vendor/vendorpull/vendorpull.sh vendorpull
```

Masking
-------

In some cases, vendoring a dependency might incur a significant space overhead
in your `git` repository. In these cases, you might want to ignore certain
paths of the vendored repository that you are not interested in, which we refer
to as *masking*.

In order to mask a dependency, you can create a file called
`vendor/<name>.mask` where `<name>` corresponds to the dependency name as
defined in the `DEPENDENCIES` file. This file contains a set of path
expressions compatible with the [`find(1)`](https://linux.die.net/man/1/find)
command that will be removed when vendoring the dependency.

For example, at the time of this writing, the Electron project repository
contains an 8.1M `docs` directory. We can ignore this directory by creating a
`vendor/electron.mask` file whose contents are the following:

```
docs
```

License
-------

This project is licensed under the Apache-2.0 license.
