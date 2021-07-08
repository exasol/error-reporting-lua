package = "remotelog"
version = "1.0.1-1"

source = {
    url = 'git://github.com/exasol/remotelog-lua',
    tag = "1.0.1"
}

description = {
    summary = "Uniform error objects for Lua",
    detailed = [["exaerror" ets you define errors with a uniform set of attributes. The created error objects can be used in places where strings are expected like in string concatenation.

    And you can conveniently rais a Lua `error` from them.

    Additionally the resulting code is made to be parseable, so that you can extract an error catalog from the code.

    You can find the  user guide in the projects GitHub repository.
    
    Links:
    
    - User guide: https://github.com/exasol/error-reporting-lua/blob/master/doc/user_guide/user_guide.md]],
    homepage = "https://github.com/exasol/error-reporting-lua",
    license = "MIT",
    maintainer = 'Exasol <opensource@exasol.com>'
}

dependencies = {"lua >= 5.1, < 5.4"}

-- With support for LuaRocks 3 we will enable the following configuration option. Right now LuaRocks 2 is still the
-- current version on Ubuntu, so it is too early for this.
--
-- rockspec_format = "3.0"
-- build_dependencies = {"luaunit >= 3.3-1"}

build = {
    type = "builtin",
    modules = {remotelog = "src/exaerror.lua"},
    copy_directories = { "doc", "test" }
}