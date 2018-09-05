package vshaxe.view.methods;

import vshaxe.server.LanguageServer;
import vshaxe.server.HaxeMethodResult;
import vshaxe.helper.CopyPaste;
import js.Date;

enum abstract MethodTreeViewType(String) {
	var Timers = "timers";
	var Queue = "queue";
}

class MethodTreeView {
	final context:ExtensionContext;
	final server:LanguageServer;
	var enabled:Bool;
	var methods:Array<MethodTreeItem> = [];
	var queue:Array<MethodTreeItem> = [];
	var viewType:MethodTreeViewType;
	var treeView:TreeView<MethodTreeItem>;
	var _onDidChangeTreeData = new EventEmitter<MethodTreeItem>();

	public var onDidChangeTreeData:Event<MethodTreeItem>;

	public function new(context:ExtensionContext, server:LanguageServer) {
		this.context = context;
		this.server = server;

		server.onDidRunHaxeMethod(onDidRunHaxeMethod);
		server.onDidChangeRequestQueue(onDidChangeRequestQueue);
		workspace.onDidChangeConfiguration(_ -> update());
		onDidChangeTreeData = _onDidChangeTreeData.event;
		setMethodsViewType(Timers);
		update();

		window.registerTreeDataProvider("haxe.methods", this);
		treeView = window.createTreeView("haxe.methods", {treeDataProvider: this});
		context.registerHaxeCommand(Methods_SwitchToQueue, switchTo.bind(Queue));
		context.registerHaxeCommand(Methods_SwitchToTimers, switchTo.bind(Timers));
		context.registerHaxeCommand(Methods_CollapseAll, collapseAll);
		context.registerHaxeCommand(Methods_Copy, copy);
		context.registerHaxeCommand(Methods_Track, track);
	}

	function setMethodsViewType(viewType:MethodTreeViewType) {
		this.viewType = viewType;
		commands.executeCommand("setContext", "haxeMethodsViewType", Std.string(viewType));
	}

	function switchTo(viewType:MethodTreeViewType) {
		setMethodsViewType(viewType);
		_onDidChangeTreeData.fire();
	}

	function onDidRunHaxeMethod(data:HaxeMethodResult) {
		if (!enabled) {
			return;
		}

		var rootTimer = data.response.timers;
		if (rootTimer == null) {
			rootTimer = makeTimer("", 0, []);
		}
		if (data.additionalTimes != null) {
			rootTimer.children.push(createAdditionalTimers(data));
		}

		var method = data.method;
		methods = methods.filter(item -> item.method != method);
		var item = new MethodTreeItem(context, null, rootTimer, data.method, data.debugInfo);
		methods.push(item);
		methods.sort((item1, item2) -> Reflect.compare(item1.method, item2.method));

		if (viewType == Timers) {
			_onDidChangeTreeData.fire();
			if (treeView.visible) {
				treeView.reveal(item, {select: true});
			}
		}
	}

	function createAdditionalTimers(data:HaxeMethodResult):Timer {
		var additionalTimes = data.additionalTimes;
		var displayCallTime = additionalTimes.arrival - additionalTimes.beforeCall;
		var transmissionTime = additionalTimes.arrival - (data.response.timestamp * 1000.0);
		var parsingTime = additionalTimes.beforeProcessing - additionalTimes.arrival;
		var processingTime = additionalTimes.afterProcessing - additionalTimes.beforeProcessing;
		var totalTime = transmissionTime + parsingTime + processingTime;
		return makeTimer("vshaxe", totalTime, [
			makeTimer("display call", displayCallTime),
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

	function onDidChangeRequestQueue(queue:Array<String>) {
		this.queue = queue.map(label -> new MethodTreeItem(context, null, null, label));
		if (viewType == Queue) {
			_onDidChangeTreeData.fire();
		}
	}

	function update() {
		enabled = workspace.getConfiguration("haxe").get("enableMethodsView");
		commands.executeCommand("setContext", "enableHaxeMethodsView", enabled);
	}

	public function getTreeItem(element:MethodTreeItem):MethodTreeItem {
		return element;
	}

	public function getChildren(?element:MethodTreeItem):Array<MethodTreeItem> {
		if (viewType == Queue) {
			return queue;
		}
		return if (element == null) methods else element.children;
	}

	public var getParent = function(element:MethodTreeItem):MethodTreeItem {
		return element.parent;
	}

	function collapseAll() {
		for (timer in methods) {
			timer.collapse();
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
