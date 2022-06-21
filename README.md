# Error Reporting Lua

This project contains the source code for the `ExaError` Lua module. This module lets you define errors with a uniform set of attributes. The created error objects can be used in places where strings are expected like in string concatenation.

And you can conveniently raise a Lua `error` from them.

Additionally, the resulting code is made to be parseable, so that you can extract an error catalog from the code.

## In a Nutshell

Define an error object:

```lua
local ExaError = require("ExaError")

local errobj = ExaError:new("E-IO-13", "Need {{needed}} MiB space, but only {{remaining}} MiB left on device {{device}}.",
    {needed = 500.2, remaining = 14.8, device = "/dev/sda4"})
```

Use it as string:

```lua
print(errobj)
```

Raise a corresponding Lua error

```lua
errobj:raise()
```

Or shorter:

```lua
ExaError.error("E-IO-13", "Need {{needed}} MiB space, but only {{remaining}} MiB left on device {{device}}.",
    {needed = 500.2, remaining = 14.8, device = "/dev/sda4"})
```

Check out the [user guide](doc/user_guide/user_guide.md) for more details.

## Features

1. Define error objects with error code, message, placeholders, parameters and mitigations
1. Use error objects where strings are expected
1. Raise errors from error objects

## Information for Users

* [User Guide](doc/user_guide/user_guide.md)
* [Change Log](doc/changes/changelog.md)
* [MIT License](LICENSE)

You can find corresponding libraries for other languages here:

* [Error reporting Java](https://github.com/exasol/error-reporting-java)
* [Error reporting C#](https://github.com/exasol/error-reporting-csharp)

### Dependencies

The only runtime-dependency of this module is Lua 5.1 or later.

See the [dependencies list](dependencies.md) for build and test dependencies and license information.
