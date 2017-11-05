package vshaxe;

class WorkspaceManager {
    final contexts:Map<String,WorkspaceFolderContext>;

    public function new() {
        contexts = new Map();

        for (folder in workspace.workspaceFolders) {
            contexts[folder.uri.toString()] = new WorkspaceFolderContext(folder);
        }

        workspace.onDidChangeWorkspaceFolders(function(event) {
            for (folder in event.added) {
                contexts[folder.uri.toString()] = new WorkspaceFolderContext(folder);
            }

            for (folder in event.removed) {
                var key = folder.uri.toString();
                var context = contexts[key];
                if (context != null) {
                    context.dispose();
                    contexts.remove(key);
                }
            }
        });
    }

    public inline function getContext(folder:WorkspaceFolder):WorkspaceFolderContext {
        return contexts[folder.uri.toString()];
    }
}
