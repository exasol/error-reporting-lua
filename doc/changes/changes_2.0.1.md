# error-reporting-lua 2.0.1, released 2022-06-24

Code name: Fixed module name case

## Summary

Release 2.0.1 of `error-reporting-lua` fixes  inconsistencies between source filename, table name and module name case that led to unresolvable dependencies.

Importing a module is now done with:

```lua
local ExaError = require("ExaError")
```

## Bugfixes

* #20: Fixed using boolean message parameters
* #22: Fixed uninitialized mitigation list when using `new` 

## Refactoring

* #22: Streamlined object constructors. Applied coding style. Upper camel case for classes.