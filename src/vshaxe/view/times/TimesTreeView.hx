package vshaxe.view.times;

import vshaxe.server.LanguageServer;

class TimesTreeView {
    final context:ExtensionContext;
    final server:LanguageServer;

    var timers:Array<TimerTreeItem> = [];
    var _onDidChangeTreeData = new EventEmitter<TimerTreeItem>();

    public var onDidChangeTreeData:Event<TimerTreeItem>;

    public function new(context:ExtensionContext, server:LanguageServer) {
        this.context = context;
        this.server = server;

        server.onUpdateTimers = onUpdateTimers;
        onDidChangeTreeData = _onDidChangeTreeData.event;
        window.registerTreeDataProvider("haxe.times", this);
    }

    function onUpdateTimers(data:{method:String, times:Timer}) {
        var method = data.method;
        timers = timers.filter(item -> item.method != method);
        timers.push(new TimerTreeItem(data.times, data.method, true));
        timers.sort((item1, item2) -> Reflect.compare(item1.method, item2.method));
        _onDidChangeTreeData.fire();
    }

    public function getTreeItem(element:TimerTreeItem):TimerTreeItem {
        return element;
    }

    public function getChildren(?element:TimerTreeItem):Array<TimerTreeItem> {
        return if (element == null) timers else element.children;
    }

    public final getParent = null;
}
