# error-reporting-lua 1.1.0, released 2021-10-07

Code name: Ticket mitigation

## Summary

Release 1.1.0 of `error-reporting-lua` adds a new convenience method `add_ticket_migitation()` to the error object builder. You can use this method to add a mitigation to the error that tells the user to create an issue ticket.

This is useful in cases where an error should theoretically be impossible to happen, but happened nonetheless, which clearly indicates a software error that needs to be addressed by the software maker.

We also changed the way errors are raised. Instead of throwing the error object, we now throw the message. This improves compatibility with existing error handling mechanisms.

## Features

* #9: Added ticket mitigation

## Bugfixes

* #11: Raise error with string instead of error object