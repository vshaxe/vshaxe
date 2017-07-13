package vshaxe;

import haxe.io.Path;

class HxmlDiscovery {
    public var hxmlFiles(default,null):Array<String> = [];

    public function new(context:ExtensionContext) {
        var pattern = "*.hxml";
        workspace.findFiles(pattern).then(files -> hxmlFiles = files.map(uri -> uri.fsPath));

        // looks like file watchers require a glob prefixed with the workspace root
        var prefixedPattern = Path.join([workspace.rootPath, pattern]);
        var fileWatcher = workspace.createFileSystemWatcher(prefixedPattern, false, true, false);
        fileWatcher.onDidCreate(uri -> hxmlFiles.push(uri.fsPath));
        fileWatcher.onDidDelete(uri -> hxmlFiles.remove(uri.fsPath));
    }
}
