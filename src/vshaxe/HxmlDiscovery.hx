package vshaxe;

import haxe.io.Path;
import vshaxe.helper.PathHelper;

class HxmlDiscovery {
    static inline var PATTERN = "*.hxml";

    var _onDidChangeFiles:EventEmitter<Void>;
    var context:ExtensionContext;

    public var files(default,null):Array<String>;

    public var onDidChangeFiles(get,never):Event<Void>;
    inline function get_onDidChangeFiles() return _onDidChangeFiles.event;

    public function new(context:ExtensionContext) {
        this.context = context;
        files = context.workspaceState.get(HaxeMemento.HxmlDiscoveryFiles, []);

        _onDidChangeFiles = new EventEmitter();
        context.subscriptions.push(_onDidChangeFiles);

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
    }

    inline function pathRelativeToRoot(uri:Uri):String {
        return PathHelper.relativize(uri.fsPath, workspace.rootPath);
    }
}
