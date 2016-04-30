import Vscode;

using StringTools;

class Main {
    var context:ExtensionContext;
    var serverDisposable:Disposable;

    function new(ctx) {
        context = ctx;
        context.subscriptions.push(Vscode.commands.registerCommand("haxe.restartLanguageServer", restartLanguageServer));
        context.subscriptions.push(Vscode.commands.registerCommand("haxe.initProject", initProject));
        context.subscriptions.push(Vscode.commands.registerCommand("haxe.applyFixes", applyFixes));
        startLanguageServer();
    }

    function applyFixes(uri:String, version:Int, edits:Array<vscode.BasicTypes.TextEdit>) {
        var editor = Vscode.window.activeTextEditor;
        if (editor == null || editor.document.uri.toString() != uri)
            return;

        // TODO:
        // if (editor.document.version != version) {
        //     Vscode.window.showInformationMessage("Fix is outdated and cannot be applied to the document");
        //     return;
        // }

        editor.edit(function(mutator) {
            for (edit in edits) {
                var range = new Range(edit.range.start.line, edit.range.start.character, edit.range.end.line, edit.range.end.character);
                mutator.replace(range, edit.newText);
            }
        });
    }

    function startLanguageServer() {
        var serverModule = context.asAbsolutePath("./server_wrapper.js");
        var env = js.Node.process.env; 
        if (env['BYPASS_PATH'] != null) env['PATH'] = env['BYPASS_PATH'];
        var serverOptions = {
            run: {module: serverModule, options: {env: env}},
            debug: {module: serverModule, options: {env: env, execArgv: ["--nolazy", "--debug=6004"]}}
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

    function initProject() {
        var workspaceRoot = Vscode.workspace.rootPath;

        if (workspaceRoot == null) {
            Vscode.window.showErrorMessage("Please open a folder to set up a Haxe project into");
            return;
        }

        if (sys.FileSystem.readDirectory(workspaceRoot).length == 0) {
            scaffoldEmpty(workspaceRoot);
            return;
        }

        var vscodeDir = workspaceRoot + "/.vscode";
        if (sys.FileSystem.exists(vscodeDir)) {
            showConfigureHint();
            return;
        }

        var hxmls = findHxmls(workspaceRoot);
        if (hxmls.length > 0) {
            createWorkspaceConfiguration(vscodeDir, hxmls);
            return;
        }

        Vscode.window.showErrorMessage("Workspace must be empty to set up a Haxe project");
    }

    function scaffoldEmpty(root:String) {
        var scaffoldSource = context.asAbsolutePath("./scaffold");
        copyRec(scaffoldSource, root);
        Vscode.window.setStatusBarMessage("Haxe project scaffolded", 2000);
    }

    function createWorkspaceConfiguration(vscodeDir:String, hxmls:Array<QuickPickItem>) {
        var pick = Vscode.window.showQuickPick(hxmls, {placeHolder: "Choose HXML file to use"});
        pick.then(function(s:QuickPickItem):Void {
            if (s == null)
                return;

            var path = s.description, file = s.label;
            var hxmlPath = if (path.length == 0) file else path + "/" + file;

            copyRec(context.asAbsolutePath("./scaffold/.vscode"), vscodeDir);

            inline function replaceBuildHxml(file) {
                var path = vscodeDir + "/" + file;
                var content = sys.io.File.getContent(path);
                sys.io.File.saveContent(path, content.replace('"build.hxml"', '"$hxmlPath"'));
            }
            replaceBuildHxml("tasks.json");
            replaceBuildHxml("settings.json");

            Vscode.workspace.openTextDocument(vscodeDir + "/settings.json").then(function(doc) {
                Vscode.window.showTextDocument(doc);
                Vscode.window.showInformationMessage("Please check if " + hxmlPath + " is suitable for completion and modify haxe.displayArguments if needed.");
            });
        });
    }

    function findHxmls(root:String):Array<QuickPickItem> {
        var hxmls = [];
        function loop(path:String):Void {
            var fullPath = root + "/" + path;
            if (sys.FileSystem.isDirectory(fullPath)) {
                for (file in sys.FileSystem.readDirectory(fullPath)) {
                    if (file.endsWith(".hxml"))
                        hxmls.push({label: file, description: path});
                    else
                        loop(if (path.length == 0) file else path + "/" + file);
                }
            }
        }
        loop("");
        return hxmls;
    }

    function showConfigureHint() {
        var channel = Vscode.window.createOutputChannel("Haxe scaffold");
        var content = sys.io.File.getContent(context.asAbsolutePath("./configureHint.txt"));
        var tasks = sys.io.File.getContent(context.asAbsolutePath("./scaffold/.vscode/tasks.json"));
        content = content.replace("{{tasks}}", tasks);
        channel.clear();
        channel.append(content);
        channel.show();
    }

    function copyRec(from:String, to:String):Void {
        function loop(src, dst) {
            var fromPath = from + src;
            var toPath = to + dst;
            if (sys.FileSystem.isDirectory(fromPath)) {
                sys.FileSystem.createDirectory(toPath);
                for (file in sys.FileSystem.readDirectory(fromPath))
                    loop(src + "/" + file, dst + "/" + file);
            } else {
                sys.io.File.copy(fromPath, toPath);
            }
        }
        loop("", "");
    }

    @:keep
    @:expose("activate")
    static function main(context:ExtensionContext) {
        new Main(context);
    }
}
