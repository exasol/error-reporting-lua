# error-reporting-lua 1.2.0, released 2021-10-11

Code name: Stack trace control

## Summary

Release 1.2.0 of `error-reporting-lua` adds control over which parts of the stack trace are used as location information for the raised errors.

The `raise` method now has an optional parameter that decides on which level of the stack trace is reported as the error location. Or if a location should be reported at all.

## Features

* #13: Stack trace control