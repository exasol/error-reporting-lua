# error-reporting-lua 2.0.3, released 2023-03-07

Code name: Fixed outdated links

## Summary

Release 2.0.3 of `error-reporting-lua` improves the robustness of the error reporting. While it should not happen that users provide tables, userdata or threads as values for placeholders, accidents happen. You won't get any particularly useful info out of the value, but at least you still want to see the error message.

## Bugfixes

* #35: Made robust against tables, userdata and threads in placeholder values.