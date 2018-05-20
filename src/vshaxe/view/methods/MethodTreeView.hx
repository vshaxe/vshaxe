package vshaxe.view.methods;

import vshaxe.server.LanguageServer;
import vshaxe.server.HaxeMethodResult;
import vshaxe.helper.CopyPaste;
import js.Date;

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
        context.registerHaxeCommand(Methods_Copy, copy);
        context.registerHaxeCommand(Methods_Track, track);
    }

    function onDidRunHaxeMethod(data:HaxeMethodResult) {
        if (!enabled) {
            return;
        }

        var rootTimer = data.response.timers;
        if (rootTimer == null) {
            rootTimer = makeTimer("", 0, []);
        }
        rootTimer.children.push(createAdditionalTimers(data));

        var method = data.method;
        methods = methods.filter(item -> item.method != method);
        var item = new MethodTreeItem(context, null, rootTimer, data.method, data.debugInfo);
        methods.push(item);
        methods.sort((item1, item2) -> Reflect.compare(item1.method, item2.method));
        _onDidChangeTreeData.fire();
        // this is awkward... https://github.com/Microsoft/vscode/issues/47153
        // haxe.Timer.delay(() -> treeView.reveal(item, {select: false}), 250);
    }

    function createAdditionalTimers(data:HaxeMethodResult):Timer {
        var transmissionTime = data.arrivalTime - (data.response.timestamp * 1000.0);
        var parsingTime = data.beforeProcessingTime - data.arrivalTime;
        var processingTime = data.afterProcessingTime - data.beforeProcessingTime;
        var totalTime = transmissionTime + parsingTime + processingTime;
        return makeTimer("vshaxe", totalTime, [
            makeTimer("transmission", transmissionTime),
            makeTimer("parsing", parsingTime),
            makeTimer("processing", processingTime)
        ]);
    }

    function makeTimer(name:String, time:Float, ?children:Array<Timer>):Timer {
        var date = new Date(time);
        return {
            name: name,
            time: date.getSeconds() + (date.getMilliseconds() / 1000.0),
            children: children
        };
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

    function copy(?element:MethodTreeItem) {
        CopyPaste.copy(if (element == null) {
            methods.map(method -> method.toString()).join("\n\n");
        } else {
            element.toString();
        });
    }

    function track(element:MethodTreeItem) {
        if (element != null) {
            commands.executeCommand("vshaxeDebugTools.methodResultsView.track", element.method);
        }
    }
}
