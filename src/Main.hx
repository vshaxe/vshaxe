import Vscode;

class Main {
    var context:ExtensionContext;
    var serverDisposable:Disposable;

    function new(ctx) {
        context = ctx;
        context.subscriptions.push(Vscode.commands.registerCommand("haxe.restartLanguageServer", restartLanguageServer));
        context.subscriptions.push(Vscode.commands.registerCommand("haxe.scaffoldProject", scaffoldProject));
        startLanguageServer();
    }

    function startLanguageServer() {
        var serverModule = context.asAbsolutePath("./server_wrapper.js");
        var serverOptions = {
            run: {module: serverModule},
            debug: {module: serverModule, options: {execArgv: ["--nolazy", "--debug=6004"]}}
        };
        var clientOptions = {
            documentSelector: "haxe",
            synchronize: {
                configurationSection: "haxe"
            }
        };
        var client = new LanguageClient("Haxe", serverOptions, clientOptions);
        client.onReady().then(function(_) {
            Vscode.window.setStatusBarMessage("Haxe language server started", 2000);
        });
        serverDisposable = client.start();
        context.subscriptions.push(serverDisposable);
    }

    function restartLanguageServer() {
        if (serverDisposable != null) {
            context.subscriptions.remove(serverDisposable);
            serverDisposable.dispose();
        }
        startLanguageServer();
    }

    function scaffoldProject() {
        var workspaceRoot = Vscode.workspace.rootPath;

        if (workspaceRoot == null) {
            Vscode.window.showErrorMessage("Please open an empty folder to scaffold Haxe project into");
            return;
        }
        if (sys.FileSystem.readDirectory(workspaceRoot).length > 0) {
            Vscode.window.showErrorMessage("Workspace must be empty to scaffold a Haxe project");
            return;
        }

        var scaffoldSource = context.asAbsolutePath("./scaffold");
        function copy(from, to) {
            var fromPath = scaffoldSource + from;
            var toPath = workspaceRoot + to;
            if (sys.FileSystem.isDirectory(fromPath)) {
                sys.FileSystem.createDirectory(toPath);
                for (file in sys.FileSystem.readDirectory(fromPath))
                    copy(from + "/" + file, to + "/" + file);
            } else {
                sys.io.File.copy(fromPath, toPath);
            }
        }
        copy("", "");
        Vscode.window.setStatusBarMessage("Haxe project scaffolded", 2000);
    }

    @:keep
    @:expose("activate")
    static function main(context:ExtensionContext) {
        new Main(context);
    }
}
