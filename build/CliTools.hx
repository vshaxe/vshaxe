package;

@:publicFields
class CliTools {
    private var verbose:Bool;
    private var dryRun:Bool;

    function new(verbose, dryRun) {
        this.verbose = verbose;
        this.dryRun = dryRun;

        if (dryRun) this.verbose = true;
    }

    function runCommands(commands:Array<Array<String>>) {
        for (command in commands.get())
            runCommand(command);
    }

    function runCommand(cmd:Array<String>) {
        var command = cmd.get();
        if (command.length == 0) return;
        var executable = command[0];
        command.shift();
        run(executable, command);
    }

    function inDir(dir:String, f:Void->Void) {
        var oldCwd = Sys.getCwd();
        setCwd(dir);
        f();
        setCwd(oldCwd);
    }

    function setCwd(dir:String) {
        if (dir == null || dir.trim() == "") return;
        println("cd " + dir);
        Sys.setCwd(dir);
    }

    function run(command:String, args:Array<String>) {
        println(command + " " + args.join(" "));
        if (!dryRun) {
            var result = Sys.command(command, args);
            if (result != 0)
                Sys.exit(result);
        }
    }

    function println(message:String) {
        if (verbose) Sys.println(message);
    }

    function exit(message, code = 0) {
        Sys.println("VSHaxe Build Script");
        Sys.println(message);
        Sys.exit(code);
    }

    function fail(message) {
        exit(message, 1);
    }

    function saveContent(path, content) {
        if (verbose) println('Saving to \'$path\':\n\n$content');
        if (!dryRun) sys.io.File.saveContent(path, content);
    }
}