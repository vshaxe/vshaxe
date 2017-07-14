package vshaxe;

import haxe.io.Path;
import vshaxe.helper.PathHelper;

class HxmlDiscovery {
    var _onDidChangeHxmlFiles:EventEmitter<Array<String>>;
    var context:ExtensionContext;

    public var hxmlFiles(default,null):Array<String>;
    public var onDidChangeHxmlFiles(get,never):Event<Array<String>>;
    inline function get_onDidChangeHxmlFiles() return _onDidChangeHxmlFiles.event;

    public function new(context:ExtensionContext) {
        this.context = context;
        hxmlFiles = context.workspaceState.get(HaxeMemento.HxmlDiscoveryFiles, []);

        _onDidChangeHxmlFiles = new EventEmitter();
        context.subscriptions.push(_onDidChangeHxmlFiles);

        var pattern = "*.hxml";
        workspace.findFiles(pattern).then(files -> {
            var foundFiles = if (files != null) files.map(uri -> pathRelativeToRoot(uri)) else [];
            if (!hxmlFiles.equals(foundFiles)) {
                hxmlFiles = foundFiles;
                onHxmlFilesChanged();
            }
        });

        // looks like file watchers require a glob prefixed with the workspace root
        var prefixedPattern = Path.join([workspace.rootPath, pattern]);
        var fileWatcher = workspace.createFileSystemWatcher(prefixedPattern, false, true, false);
        fileWatcher.onDidCreate(uri -> {
            hxmlFiles.push(pathRelativeToRoot(uri));
            onHxmlFilesChanged();
        });
        fileWatcher.onDidDelete(uri -> {
            hxmlFiles.remove(pathRelativeToRoot(uri));
            onHxmlFilesChanged();
        });
    }

    inline function onHxmlFilesChanged() {
        context.workspaceState.update(HaxeMemento.HxmlDiscoveryFiles, hxmlFiles);
        _onDidChangeHxmlFiles.fire(hxmlFiles);
    }

    inline function pathRelativeToRoot(uri:Uri):String {
        return PathHelper.relativize(uri.fsPath, workspace.rootPath);
    }
}
