package vshaxe.view.methods;

import vshaxe.server.LanguageServer;

class MethodTreeView {
    final context:ExtensionContext;
    final server:LanguageServer;

    var enabled:Bool;
    var timers:Array<MethodTreeItem> = [];
    var treeView:TreeView<MethodTreeItem>;
    var _onDidChangeTreeData = new EventEmitter<MethodTreeItem>();

    public var onDidChangeTreeData:Event<MethodTreeItem>;

    public function new(context:ExtensionContext, server:LanguageServer) {
        this.context = context;
        this.server = server;

        server.onUpdateTimers = onUpdateTimers;
        workspace.onDidChangeConfiguration(_ -> update());
        onDidChangeTreeData = _onDidChangeTreeData.event;
        update();

        window.registerTreeDataProvider("haxe.methods", this);
        treeView = window.createTreeView("haxe.methods", {treeDataProvider: this});
        context.registerHaxeCommand(Methods_CollapseAll, collapseAll);
    }

    function onUpdateTimers(data:{method:String, times:Timer}) {
        if (!enabled) return;

        var method = data.method;
        timers = timers.filter(item -> item.method != method);
        var item = new MethodTreeItem(context, null, data.times, data.method);
        timers.push(item);
        timers.sort((item1, item2) -> Reflect.compare(item1.method, item2.method));

        treeView.reveal(item);
        _onDidChangeTreeData.fire();
    }

    function update() {
        enabled = workspace.getConfiguration("haxe").get("enableMethodsView");
        commands.executeCommand("setContext", "enableHaxeMethodsView", enabled);
    }

    public function getTreeItem(element:MethodTreeItem):MethodTreeItem {
        return element;
    }

    public function getChildren(?element:MethodTreeItem):Array<MethodTreeItem> {
        return if (element == null) timers else element.children;
    }

    public final getParent = function(element:MethodTreeItem):MethodTreeItem {
        return element.parent;
    }

    function collapseAll() {
        for (timer in timers) {
            timer.collapse();
            // ugly workaround for https://github.com/Microsoft/vscode/issues/30918
            if (timer.id.endsWith(" ")) {
                timer.id = timer.id.rtrim();
            } else {
                timer.id += " ";
            }
        }
        _onDidChangeTreeData.fire();
    }
}
