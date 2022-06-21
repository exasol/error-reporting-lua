# error-reporting-lua &mdash; User Guide

This project contains the source code for the `ExaError` Lua module. This module lets you define errors with a uniform set of attributes. The created error objects can be used in places where strings are expected like in string concatenation.

And you can conveniently raise a Lua `error` from them.

Additionally, the resulting code is made to be parseable, so that you can extract an error catalog from the code.

# Defining Error Objects

The core concept of the module is an error object defined in `Exaerror`. Each error object has a couple of predefined attributes:

* `code`: A machine readable error identifier
* `message`: description of the error
* `parameters`: table of parameters used to replace placeholders in the description
* `mitigations`: list of things users can do to fix the error

## Optional Attributes and Fault Tolerance

While this might sound counter-intuitive at first, all attributes of the error object are optional. Lua has no compile-time checking, so error messages need to be as robust as possible at runtime.

Some parts are logically optional anyway, like the parameters if the message is static or the mitigations.

While it is good practice to always provide an error code, the `ExaError` will still work should you forget it by accident. Same is true for all other attributes.

If you should forget all attributes, `ExaError` will default to an "undefined error", telling the user to contact the software maker for a solution.

Consequently `ExaError` does not restrict the attributes at runtime but rather tries to make the best possible error message out of what it is given.

## Error Object Construction Variants

There are different variants for creating an error object. Which one you prefer is a matter of taste mainly because the yield the same result.

### Constructor `new`

The constructor method `new` has the following signature:

```lua
ExaError:new(code, message, parameters, mitigations)
```

With the following parameters:

* `code`: machine-readable unique code (string)
* `message`: Error description either as static string or containing placeholders in double curly brackets
* `parameters`: table of parameter values be used to replace placeholders in the message and mitigations
* `mitigations`: list of hints on how to fix the error (array of strings), optionally containing placeholders

Here is an example that uses all constructor parameters.

```lua
local errorobj = ExaError:new(
        "E-IO-13",
        "Need {{needed}} MiB space, but only {{remaining}} MiB left on device {{device}}.",
        {needed = {value = 500.2}, remaining = {value = 14.8}, device = {value = "/dev/sda4"}},
        {"Delete some unused files.", "Move to another device."}
)
```

The `parameters` must have a field `value`. Optionally you can explain what a parameter means using the field `description`.

### Error Object Builder

Alternatively you can use builder-style construction provided with `ExaError` to create an error object.

Strictly speaking it is a combination between the builder pattern and regular setters since Lua 5.1 does not have immutable tables.

```lua
local errobj = ExaError.new("E-IO-13", "Need {{needed}} MiB space, but only {{remaining}} MiB left on device {{device}}.",
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
local errobj = ExaError:new(
        "Unexpected error.",
        {"Please create an error report under {{url}}."},
        {url = project_issue_url}
)
```

If you want to add a description to your parameters, you need to invest just a bit more effort:

```lua
local errobj = ExaError:new(
    "Unexpected error.",
    {"Please create an error report under {{url}}."},
    {url = {value = project_issue_url, description = "URL under which you can raise issue tickets"}}
)
```

That means if you provide anything that is not a table as a parameter definition, that will be the value which replaces the placeholder.
If you provide a table, the `value` must be named explicitly, but that also gives you the opportunity to add a `description`.

#### Asking Users to Report an Internal Error

If you program defensively, you will also handle error cases which in theory should never happen. "In theory" means that they are impossible as long as the implementation is error-free. It is good programming practice, to prepare for the case when the "cannot happen" assumption is wrong.

Since we are talking about internal errors, that the users have no real chance of fixing, reporting the error to the project is the best available option.

Use the following convenience method of the error object builder to cover those situations.

```lua
local errobj = ExaError.create("F-PACK-45", "Validation of created archive failed. Checksums do not match.")
    :add_ticket_mitigation()
```

This will add mitigation information to the error message prompting the user to report the problem.

```
Mitigations:

* This is an internal software error. Please report it via the project's ticket tracker.
```

# Raising Errors

Error objects are only useful if you can present them to the end users. `ExaError` supports different styles, which are again a matter of taste.

## Using Lua's `error` Function to Raise an Error

The most basic variant is using the object as parameter to Lua's `error` function:

```lua
error(tostring(errobj))
```

Note that while it is in some cases possible to skip the [`tostring`](https://www.lua.org/manual/5.1/manual.html#pdf-tostring) conversion function since `ExaError` defines the `__tostring` and `__concat` metamethods, we advise against that.

This will only work in cases where there is an implicit or explicit call to `tostring` or `concat` in the subsequent code. But that is not guaranteed and an implementation detail you should not rely on. If you for example want to catch the error with [`pcall`](https://www.lua.org/manual/5.1/manual.html#pdf-pcall) and then use `gmatch` against the supposed error message, that attempt will fail since `gmatch` expects a string as parameter, but gets a table instead in this case.

## Object-oriented Error Raising

Another more elegant variant is to call the `raise` method of the error object.

```lua
errorobj:raise()
```

Mind the colon!

The `raise` method has one optional integer parameter `level` that defines what location information is added to the error message. This acts exactly like the built-in `error` function. The `level` defines from which point in the stack trace the location information is taken.

A level of 1 means that the location is where the Lua error is raised. That is _inside_ the `ExaError` module. Because that is typically not what users want, the default value is 2, meaning that you get location information from the function calling `raise`.

If you set the level to 0, Lua adds no location information to the error message. This is a good choice for errors that you plan to display directly to end users.

## Creating and Raising an Error in one Step

The shortest variant to create and raise an error in one call is using `ExaError.error`.

```lua
ExaError.error("E-IO-13", "Need %d MiB space, but only %d MiB left on device %s.",
    500.2, 14.8, "/dev/sda4", {"Delete some unused files.", "Move to another device."}
)
```

This method has the same signature as the `new` method.