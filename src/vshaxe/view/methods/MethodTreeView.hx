package vshaxe.view.methods;

import vshaxe.server.LanguageServer;
import vshaxe.server.Response;

class MethodTreeView {
    final context:ExtensionContext;
    final server:LanguageServer;

    var enabled:Bool;
    var methods:Array<MethodTreeItem> = [];
    var treeView:TreeView<MethodTreeItem>;
    var _onDidChangeTreeData = new EventEmitter<MethodTreeItem>();

    public var onDidChangeTreeData:Event<MethodTreeItem>;

    public function new(context:ExtensionContext, server:LanguageServer) {
        this.context = context;
        this.server = server;

        server.onDidRunHaxeMethod(onDidRunHaxeMethod);
        workspace.onDidChangeConfiguration(_ -> update());
        onDidChangeTreeData = _onDidChangeTreeData.event;
        update();

        window.registerTreeDataProvider("haxe.methods", this);
        treeView = window.createTreeView("haxe.methods", {treeDataProvider: this});
        context.registerHaxeCommand(Methods_CollapseAll, collapseAll);
    }

    function onDidRunHaxeMethod(data:{method:String, response:Response}) {
        if (!enabled || data.response.timers == null) return;

        var method = data.method;
        methods = methods.filter(item -> item.method != method);
        var item = new MethodTreeItem(context, null, data.response.timers, data.method);
        methods.push(item);
        methods.sort((item1, item2) -> Reflect.compare(item1.method, item2.method));
        _onDidChangeTreeData.fire();
        // this is awkward... https://github.com/Microsoft/vscode/issues/47153
        // haxe.Timer.delay(() -> treeView.reveal(item, {select: false}), 250);
    }

    function update() {
        enabled = workspace.getConfiguration("haxe").get("enableMethodsView");
        commands.executeCommand("setContext", "enableHaxeMethodsView", enabled);
    }

    public function getTreeItem(element:MethodTreeItem):MethodTreeItem {
        return element;
    }

    public function getChildren(?element:MethodTreeItem):Array<MethodTreeItem> {
        return if (element == null) methods else element.children;
    }

    public final getParent = function(element:MethodTreeItem):MethodTreeItem {
        return element.parent;
    }

    function collapseAll() {
        for (timer in methods) {
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
