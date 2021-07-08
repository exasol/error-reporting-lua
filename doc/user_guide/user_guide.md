# error-reporting-lua &mdash; User Guide

This project contains the source code for the `exaerror` Lua module. This modules lets you define errors with a uniform set of attributes. The created error objects can be used in places where strings are expected like in string concatenation.

And you can conveniently rais a Lua `error` from them.

Additionally the resulting code is made to be parseable, so that you can extract an error catalog from the code.

# Defining Error Objects

The core concept of the module is an error object defined in `exaerror`. This is a Lua table that has a couple of predefined attributes:

* `code`: A machine readable error code
* `message`: description of the error
* `parameters`: list of parameter values used to replace placeholders in the description
* `mitigations`: list of things users can do to fix the error

## Optional Attributes and Fault Tolerance

While this might sound counter-intuitive at first, all attributes of the error object are optional. Lua has no compile-time checking, so error messages need to be as robust as possible at runtime.

Some parts are logically optional anyway, like the parameters if the message is static or the mitigations.

While it is good practice to always provide an error code, the `exaerror` will still work should you forget it by accident. Same is true for all other attributes.

If you should forget all attributes, `exaerror` will default to an "undefined error", telling the user to contact the software maker for a solution.

Consequently `exaerror` does not restrict the attributes at runtime but rather tries to make the best possible error message out of what it is given.

## Error Object Construction Variants

There are different variants for creating an error object. Which one you prefer is a matter of taste mainly because the yield the same result.

### Lua-style Object Initialization

An established way in Lua to initialize objects is to provide a table with the `new` call that will then be turned into the object.

```lua
local errorobj = exaerror:new({
    code = "E-IO-13",
    message = Need %d MiB space, but only %d MiB left on device %s.",
    parameters = {500.2, 14.8, "/dev/sda4"},
    mitigations = {"Delete some unused files.", "Move to another device."}
})
```

As you can see in the example above, you can simply pass the error attributes as table when calling `exaerror:new`.

The predefined table keys are

* `code`: machine-readable unique code (string)
* `message`: Error description either as static string or as [format with placeholders](https://www.lua.org/manual/5.1/manual.html#pdf-string.format) (string)
* `parameters`: parameter values that will be used to replace placeholders in the description (array of values)
* `mitigations`: list of hints on how to fix the error (array of strings)

### Error Object Builder

Alternatively you can use a builder provided with `exaerror` to construct an error object.

Strictly speaking it is a combination between the builder pattern and regular setters since Lua 5.1 does not have immutable tables.

```lua
local errobj = exaerror.create("E-IO-13", "Need %d MiB space, but only %d MiB left on device %s.",
        500.2, 14.8, "/dev/sda4")
    :add_mitigations("Delete some unused files.", "Move to another device.")
```

Mind the colon before `add_mitigations` because that method needs a `self` pointer.

# Raising Errors

Error objects are only useful if you can present them to the end users. `exaerror` supports different styles, which are again a matter of taste.

## Using Lua's `error` Function to Raise an Error

The most basic variant is using the object as parameter to Lua's `error` function:

```lua
error(errobj)
```

Note that you don't have to use Lua's [`tostring`](https://www.lua.org/manual/5.1/manual.html#pdf-tostring) conversion function explicitly since `exaerror` defines the `__tostring` metamethod.

## Object-oriented Error Raising

Another option is to call the `raise` method of the error object.

```lua
errorobj:raise()
```

Mind the colon!

## Creating an Raising an Error in one Step

The shortest variant to create and raise an error in one call is using `exaerror.error`.

```lua
exaerror.error("E-IO-13", "Need %d MiB space, but only %d MiB left on device %s.",
    500.2, 14.8, "/dev/sda4")
```

The main downside of this approach is that you can only specify code, message and parameters. If you need more, you have to use one of the other options.
