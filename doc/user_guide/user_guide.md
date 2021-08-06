# error-reporting-lua &mdash; User Guide

This project contains the source code for the `exaerror` Lua module. This modules lets you define errors with a uniform set of attributes. The created error objects can be used in places where strings are expected like in string concatenation.

And you can conveniently rais a Lua `error` from them.

Additionally the resulting code is made to be parseable, so that you can extract an error catalog from the code.

# Defining Error Objects

The core concept of the module is an error object defined in `exaerror`. This is a Lua table that has a couple of predefined attributes:

* `code`: A machine readable error identifier
* `message`: description of the error
* `parameters`: table of parameters used to replace placeholders in the description
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
    message = "Need {{needed}} MiB space, but only {{remaining}} MiB left on device {{device}}.",
    parameters = {needed = {value = 500.2}, remaining = {value = 14.8}, device = {value = "/dev/sda4"}},
    mitigations = {"Delete some unused files.", "Move to another device."}
})
```

As you can see in the example above, you can simply pass the error attributes as table when calling `exaerror:new`.

The predefined table keys are

* `code`: machine-readable unique code (string)
* `message`: Error description either as static string or containing placeholders in double curly brackets.
* `parameters`: table of parameter values be used to replace placeholders in the message and mitigations
* `mitigations`: list of hints on how to fix the error (array of strings), optionally containing placeholders

The `parameters` must have a field `value`. Optionally you can explain what a parameters means using the field `description`.

### Error Object Builder

Alternatively you can use a builder provided with `exaerror` to construct an error object.

Strictly speaking it is a combination between the builder pattern and regular setters since Lua 5.1 does not have immutable tables.

```lua
local errobj = exaerror.create("E-IO-13", "Need {{needed}} MiB space, but only {{remaining}} MiB left on device {{device}}.",
        {needed = 500.2, remaining = 14.8, device ="/dev/sda4"})
    :add_mitigations("Delete some unused files.", "Move to another device.")
```

Mind the colon before `add_mitigations` because that method needs a `self` pointer.

#### Using Parameters

As you can see from the examples the named parameters are placeholders that need to be enclosed in double curly brackets. You define the values in a table where the parameter names are the keys.

You can use the same parameter replacement mechanism in mitigations that you saw earlier used in the message part.

```lua
local project_issue_url = "www.example.org/issues"
-- ...
local msg = exaerror:new({
    message = "Unexpected error.",
    mitigations = {"Please create an error report under {{url}}."},
    parameters = {url = project_issue_url}
})
```

If you want to add a description to your parameters, you need to invest just a little bit more effort:

```lua
local msg = exaerror:new({
    message = "Unexpected error.",
    mitigations = {"Please create an error report under {{url}}."},
    parameters = {url = {value = project_issue_url, description = "URL under which you can raise issue tickets"}}
})
```

That means if you provide anything that is not a table as a parameter definition, that will be the value which replaces the placeholder.
If you provide a table, the `value` must be named explicitly, but that also gives you the opportunity to add a `description`.

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

But since the function also supports the Lua-style object initialization, you can use:

```lua
exaerror.error({
    code = "E-IO-13",
    message = Need %d MiB space, but only %d MiB left on device %s.",
    parameters = {500.2, 14.8, "/dev/sda4"},
    mitigations = {"Delete some unused files.", "Move to another device."}
})
```

Note that in this case it is important that the one and only parameter to `exaerror.error` is the initialization table.
