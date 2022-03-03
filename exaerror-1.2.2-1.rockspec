rockspec_format = "3.0"
package = "exaerror"
version = "1.2.2-1"

source = {
    url = 'git://github.com/exasol/error-reporting-lua',
    tag = "1.2.2"
}

description = {
    summary = "Uniform error objects for Lua",
    detailed = [["exaerror" lets you define errors with a uniform set of attributes. The created error objects can be used in places where strings are expected like in string concatenation.

    And you can conveniently raise a Lua `error` from them.

    Additionally the resulting code is made to be parsable, so that you can extract an error catalog from the code.

    You can find the  user guide in the projects GitHub repository.
    
    Links:
    
    - User guide: https://github.com/exasol/error-reporting-lua/blob/master/doc/user_guide/user_guide.md]],
    homepage = "https://github.com/exasol/error-reporting-lua",
    license = "MIT",
    maintainer = 'Exasol <opensource@exasol.com>'
}

dependencies = {"lua >= 5.1, < 5.5"}

build_dependencies = {"luaunit >= 3.3-1"}

build = {
    type = "builtin",
    modules = {
        exaerror = "src/exaerror.lua",
        message_expander = "src/message_expander.lua"
    },
    copy_directories = { "doc", "test" }
}