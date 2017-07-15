package vshaxe;

import haxe.io.Path;
import vshaxe.helper.PathHelper;

class HxmlDiscovery {
    static inline var PATTERN = "**/*.hxml";

    var _onDidChangeFiles:EventEmitter<Void>;
    var _onDidChangeMatchedFiles:EventEmitter<Void>;
    var context:ExtensionContext;
    var currentPatterns:Array<String>;

    public var files(default,null):Array<String>;
    public var matchedFiles(default,null):Array<String>;

    public var onDidChangeFiles(get,never):Event<Void>;
    inline function get_onDidChangeFiles() return _onDidChangeFiles.event;

    public var onDidChangeMatchedFiles(get,never):Event<Void>;
    inline function get_onDidChangeMatchedFiles() return _onDidChangeMatchedFiles.event;

    public function new(context:ExtensionContext) {
        this.context = context;
        files = context.workspaceState.get(HaxeMemento.HxmlDiscoveryFiles, []);
        matchedFiles = findMatches();

        _onDidChangeFiles = new EventEmitter();
        _onDidChangeMatchedFiles = new EventEmitter();
        context.subscriptions.push(_onDidChangeFiles);
        context.subscriptions.push(_onDidChangeMatchedFiles);

        context.subscriptions.push(workspace.onDidChangeConfiguration(_ -> updateMatches()));

        workspace.findFiles(PATTERN).then(files -> {
            var foundFiles = if (files != null) files.map(uri -> pathRelativeToRoot(uri)) else [];
            if (!this.files.equals(foundFiles)) {
                this.files = foundFiles;
                onFilesChanged();
            }
        });

        // looks like file watchers require a glob prefixed with the workspace root
        var prefixedPattern = Path.join([workspace.rootPath, PATTERN]);
        var fileWatcher = workspace.createFileSystemWatcher(prefixedPattern, false, true, false);
        fileWatcher.onDidCreate(uri -> {
            files.push(pathRelativeToRoot(uri));
            onFilesChanged();
        });
        fileWatcher.onDidDelete(uri -> {
            files.remove(pathRelativeToRoot(uri));
            onFilesChanged();
        });
    }

    inline function onFilesChanged() {
        context.workspaceState.update(HaxeMemento.HxmlDiscoveryFiles, files);
        _onDidChangeFiles.fire();
        updateMatches();
    }

    function findMatches():Array<String> {
        var patterns = workspace.getConfiguration("haxe").get("hxmlFiles", ["*.hxml"]);
        if (patterns.equals(currentPatterns)) {
            return matchedFiles;
        }
        currentPatterns = patterns;

        var newMatches = [];
        for (pattern in patterns) {
            for (file in files) {
                if (minimatch(file, pattern) && !newMatches.has(file)) {
                    newMatches.push(file);
                }
            }
        }

        return newMatches;
    }

    function minimatch(file:String, pattern:String):Bool {
        return js.Lib.require("minimatch")(file, pattern);
    }

    function updateMatches() {
        var newMatches = findMatches();

        if (!matchedFiles.equals(newMatches)) {
            _onDidChangeMatchedFiles.fire();
            matchedFiles = newMatches;
        }
    }

    inline function pathRelativeToRoot(uri:Uri):String {
        return PathHelper.relativize(uri.fsPath, workspace.rootPath);
    }
}
