# error-reporting-lua 2.0.0, released 2022-06-20

Code name: Streamlined interface

## Summary

Release 2.0.0 of `error-reporting-lua` fixes a bug that caused an error when you used a boolean value as message parameter.

We also streamlined the interface. The `create` factory method is now gone and the `new` method was simplified. This unfortunately results in a breaking change, which is also the reason we increased the major number.

In the course of reworking the `new` method we also fixed a bug caused by an uninitialized mitigation in case the object was created with `new` instead of `create`.

To comply with our [style guide](https://github.com/exasol/lua-coding/blob/main/doc/lua_style_guide.md) we changed the class names to upper camel case: `ExaError` and `MessageExpander`. Another breaking change.

Of course, we updated the [user guide](../user_guide/user_guide.md) accordingly.

We migrated the unit tests to the [`busted`](http://olivinelabs.com/busted/) framework. You can now run the tests with either:

```bash
busted
```

or

```bash
luarocks --local test
```

We replaced the GitHub action for installing Lua with the standard `apt-get` solution, now that the GitHub Ubuntu runner 22.04 is available with Lua 5.4.

### How to Migrate Your Code

1. Replace `exaerror` by `ExaError` as module and class name
2. If you used the message expander directly (which is usually not necessary), replace `message_expander` by `MessageExpander`
3. Replace calls to `create` with `new`, keeping the parameter signature
4. If you have pre-initialized object-style `new` calls, replace the table with the attributes `code`, `message`, `parameters` and `mitigations` by a flat list of the values. Mind the parameter order!
5. Note that `new` now accepts mitigations as optional fourth parameter.

## Bugfixes

* #20: Fixed using boolean message parameters
* #22: Fixed uninitialized mitigation list when using `new` 

## Refactoring

* #22: Streamlined object constructors. Applied coding style. Upper camel case for classes.