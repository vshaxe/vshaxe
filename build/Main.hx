package;

import builders.*;
import json2object.JsonParser;
import sys.io.File;
import sys.FileSystem;
import haxe.io.Path;

/** The build script for VSHaxe **/
class Main {
    static inline var DEFAULTS_FILE = "defaults.json";
    static inline var PROJECT_FILE = "project.json";

    static function main() new Main();

    var cli:CliTools;

    function new() {
        var cliArgs:CliArguments = {
            targets: [],
            debug: false,
            mode: Build
        };

        var dryRun = false;
        var verbose = false;
        var genTasks = false;
        var display = false;
        var help = false;
        var modeStr = "build";

        var args = Sys.args();
        var argHandler = hxargs.Args.generate([
            @doc("One or multiple targets to build.")
            ["-t", "--target"] => function(name:String) cliArgs.targets.push(name),

            @doc("Build mode - accepted values are 'build', 'install', and 'both'.")
            ["-m", "--mode"] => function(mode:String) modeStr = mode,

            @doc("Build the target(s) in debug mode. Implies -debug, -D js_unflatten and -lib jstack.")
            ["--debug"] => function() cliArgs.debug = true,

            @doc("Perform a dry run (no command invocations). Implies -verbose.")
            ["--dry-run"] => function() dryRun = true,

            @doc("Output the commands that are executed.")
            ["-v", "--verbose"] => function() verbose = true,

            @doc("Generate a tasks.json to .vscode (and don't build anything).")
            ["--gen-tasks"] => function() genTasks = true,

            @doc("Generate a complete.hxml for auto completion (and don't build anything).")
            ["--display"] => function() display = true,

            @doc("Display this help text and exit.")
            ["--help"] => function() help = true,
        ]);

        try {
            argHandler.parse(args);
        } catch (e:Any) {
            Sys.println('$e\n\nAvailable commands:\n${argHandler.getDoc()}');
            Sys.exit(1);
        }

        cli = new CliTools(verbose, dryRun);
        if (args.length == 0 || help)
            cli.exit(argHandler.getDoc());

        var defaults = readJson(DEFAULTS_FILE);
        Sys.setCwd(".."); // move out of /build
        var projects = [defaults].concat(findProjectFiles(".").map(readJson));

        validateTargets(cliArgs.targets);
        validateEnum("mode", modeStr, Mode.getConstructors());
        cliArgs.mode = Mode.createByName(getEnumName(modeStr));

        if (genTasks && display)
            cli.fail("Can only specify one: --gen-tasks or --display");

        if (genTasks) new VSCodeTasksBuilder(cli, projects).build(cliArgs);
        else if (display) new DisplayHxmlBuilder(cli, projects).build(cliArgs);
        else new HaxeBuilder(cli, projects).build(cliArgs);
    }

    function readJson(file:String):Project {
        if (!FileSystem.exists(file)) cli.fail('Could not find $file.');
        var parser = new JsonParser<Project>();
        var json = parser.fromJson(File.getContent(file), file);
        if (parser.warnings.length > 0)
            cli.fail([for (warning in parser.warnings) Std.string(warning)].join("\n"));
        return json;
    }

    function validateTargets(targets:Array<String>) {
        var targetList = 'List of valid targets:\n  ${targets}';
        if (targets.length == 0)
            cli.fail("No target(s) specified! " + targetList);

        for (target in targets)
            validateEnum("target", target, targets);
    }

    function validateEnum<T>(name:String, value:T, validValues:Array<T>) {
        var validStrValues = [for (value in validValues) Std.string(value).toLowerCase()];
        if (validStrValues.indexOf(Std.string(value)) == -1)
            cli.fail('Unknown $name \'$value\'. Valid values are: $validStrValues');
    }

    function getEnumName(cliName:String):String {
        return cliName.substr(0, 1).toUpperCase() + cliName.substr(1);
    }

    function findProjectFiles(dir:String):Array<String> {
        if ((dir != "." && dir != ".." && dir.startsWith(".")) || dir == "dump") return [];
        var projectFiles = [];
        for (file in FileSystem.readDirectory(dir)) {
            var fullPath = Path.join([dir, file]);
            if (FileSystem.isDirectory(fullPath))
                projectFiles = projectFiles.concat(findProjectFiles(fullPath));
            else if (file == PROJECT_FILE)
                projectFiles.push(fullPath);
        }
        return projectFiles;
    }
}

typedef CliArguments = {
    var targets:Array<String>;
    var debug:Bool;
    var mode:Mode;
}

enum Mode {
    Build;
    Install;
    Both;
}