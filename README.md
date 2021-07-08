# error-reporting-lua

This project contains the source code for the `exaerror` Lua module. This modules lets you define errors with a uniform set of attributes. The created error objects can be used in places where strings are expected like in string concatenation.

And you can conveniently rais a Lua `error` from them.

Additionally the resulting code is made to be parseable, so that you can extract an error catalog from the code.

## In a Nutshell

Define an error object:

```lua
local errobj = exaerror.create("E-IO-13", "Need %d MiB space, but only %d MiB left on device %s.",
    500.2, 14.8, "/dev/sda4")
```

Use it as string:

```
print(errobj)
```

Raise a corresponding Lua error

```
errobj.raise()
```

Or shorter:

```lua
exaerror.error("E-IO-13", "Need %d MiB space, but only %d MiB left on device %s.",
     500.2, 14.8, "/dev/sda4")
```

Check out the [user guide](doc/user_guide/user_guide.md) for more details.

## Features

1. Define error objects with error code, description, placeholders, parameters and mitigations
1. Use error objects where strings are expected
1. Raise errors from error objects

## Table of Contents

### Information for Users

* [User Guide](doc/user_guide/user_guide.md)
* [Change Log](doc/changes/changelog.md)

#### Dependencies

This module needs Lua 5.1 or later to run.