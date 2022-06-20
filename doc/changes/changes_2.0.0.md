# error-reporting-lua 2.0.0, released 2022-06-20

Code name: Streamlined interface

## Summary

Release 2.0.0 of `error-reporting-lua` fixes a bug that caused an error when you used a boolean value as message parameter.

We also streamlined the interface. The `create` factory method is now gone and the `new` method was simplified. This unfortunately results in a breaking change, which is also the reason we increased the major number.

In the course of reworking the `new` method we also fixed a bug cause by an uninitialized mitigation in case the object was created with `new` instead of `create`.

To comply with our [style guide](https://github.com/exasol/lua-coding/blob/main/doc/lua_style_guide.md) we changed the class names to upper camel case: `ExaError` and `MessageExpander`. Another breaking change.

Of course, we updated the [user guide](../user_guide/user_guide.md) accordingly.

## Bugfixes

* #20: Fixed using boolean message parameters
* #22: Fixed uninitialized mitigation list when using `new` 

## Refactoring

* #22: Streamlined object constructors. Applied coding style. Upper camel case for classes.