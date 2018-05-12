package vshaxe.view.methods;

import vshaxe.server.LanguageServer;

class MethodTreeView {
    final context:ExtensionContext;
    final server:LanguageServer;

    var timers:Array<MethodTreeItem> = [];
    var _onDidChangeTreeData = new EventEmitter<MethodTreeItem>();

    public var onDidChangeTreeData:Event<MethodTreeItem>;

    public function new(context:ExtensionContext, server:LanguageServer) {
        this.context = context;
        this.server = server;

        server.onUpdateTimers = onUpdateTimers;
        onDidChangeTreeData = _onDidChangeTreeData.event;
        window.registerTreeDataProvider("haxe.methods", this);
    }

    function onUpdateTimers(data:{method:String, times:Timer}) {
        var method = data.method;
        timers = timers.filter(item -> item.method != method);
        timers.push(new MethodTreeItem(data.times, data.method, true));
        timers.sort((item1, item2) -> Reflect.compare(item1.method, item2.method));
        _onDidChangeTreeData.fire();
    }

    public function getTreeItem(element:MethodTreeItem):MethodTreeItem {
        return element;
    }

    public function getChildren(?element:MethodTreeItem):Array<MethodTreeItem> {
        return if (element == null) timers else element.children;
    }

    public final getParent = null;
}
