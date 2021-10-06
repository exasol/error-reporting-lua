# error-reporting-lua 1.0.0, released 2021-08-06

Code name: Minimum Viable Product

## Summary

Release 1.0.0 contains of the `exaerror` Lua module that allows defining uniform error objects and raising them as Lua `error`.

An error object can contain an error code, a description and one or more mitigation hints. Description and mitigations can contain parameters that get replaced at runtime.

Error objects can be used in places where Lua expects strings (e.g. in concatenations).

## Features

* #1: Basic error object and builder
* #3: Placeholders in mitigations
* #4: Parameter descriptions