package vshaxe;

/**
    Configuration for the Haxe executable.
**/
typedef HaxeExecutableConfiguration = {
    /**
        Path to the Haxe executable. Can be a relative or absolute path,
        or just a command / alias like `"haxe"`.
    **/
    var path(default,never):String;

    /**
        Additional environment variables used for running Haxe executable.
    **/
    var env(default,never):haxe.DynamicAccess<String>;
}