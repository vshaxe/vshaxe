package vshaxe;

class WorkspaceFolderContext {
    final folder:WorkspaceFolder;

    public function new(folder) {
        this.folder = folder;
    }

    public function dispose() {
    }
}
