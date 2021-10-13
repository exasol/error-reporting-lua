# error-reporting-lua 1.2.1, released 2021-10-13

Code name: Pipe replaced

## Summary

Release 1.2.1 of `error-reporting-lua` replaces the pipe symbol "|" in the source code with `string.char(124)` to improve compatibility with environments where the pipe symbol in source produces an error.

## Refactoring

* #15: Replaced pipe symbol