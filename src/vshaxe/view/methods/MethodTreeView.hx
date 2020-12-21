package vshaxe.view.methods;

import haxe.display.Protocol.Timer;
import haxeLanguageServer.LanguageServerMethods;
import js.lib.Date;
import vshaxe.server.LanguageServer;

enum abstract MethodTreeViewType(String) {
	var Timers = "timers";
	var Queue = "queue";
}

class MethodTreeView {
	final context:ExtensionContext;
	final server:LanguageServer;
	@:nullSafety(Off) final treeView:TreeView<Node>;
	final _onDidChangeTreeData = new EventEmitter<Node>();
	var methods:Array<Node> = [];
	var queue:Array<Node> = [];
	var viewType:MethodTreeViewType;

	public var enabled:Bool = false;
	public var onDidChangeTreeData:Event<Node>;

	public function new(context:ExtensionContext, server:LanguageServer) {
		this.context = context;
		this.server = server;
		onDidChangeTreeData = _onDidChangeTreeData.event;

		inline setMethodsViewType(Timers);

		window.registerTreeDataProvider("haxe.methods", this);
		treeView = window.createTreeView("haxe.methods", {treeDataProvider: this, showCollapseAll: true});

		server.onDidRunMethod(onDidRunMethod);
		server.onDidChangeRequestQueue(onDidChangeRequestQueue);

		context.registerHaxeCommand(Methods_SwitchToQueue, switchTo.bind(Queue));
		context.registerHaxeCommand(Methods_SwitchToTimers, switchTo.bind(Timers));
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

	function onDidRunMethod(data:MethodResult) {
		if (!enabled) {
			return;
		}

		var rootTimer = data.response.timers;
		if (rootTimer == null) {
			rootTimer = makeTimer("", 0, []);
		}
		if (rootTimer.children != null && data.additionalTimes != null && data.response.timestamp != null) {
			rootTimer.children.push(createAdditionalTimers(data.additionalTimes, data.response.timestamp));
		}

		final method = data.method;
		methods = methods.filter(item -> item.method != method);
		final item = new Node(context, rootTimer, data.kind, data.method, data.debugInfo);
		methods.push(item);
		methods.sort((item1, item2) -> Reflect.compare(item1.method, item2.method));

		if (viewType == Timers) {
			_onDidChangeTreeData.fire();
			if (treeView.visible) {
				treeView.reveal(item, {select: true});
			}
		}
	}

	function createAdditionalTimers(additionalTimes:AdditionalTimes, timestamp:Float):Timer {
		final displayCallTime = additionalTimes.arrival - additionalTimes.beforeCall;
		final transmissionTime = additionalTimes.arrival - (timestamp * 1000.0);
		final parsingTime = additionalTimes.beforeProcessing - additionalTimes.arrival;
		final processingTime = additionalTimes.afterProcessing - additionalTimes.beforeProcessing;
		final totalTime = transmissionTime + parsingTime + processingTime;
		return makeTimer("vshaxe", totalTime, [
			makeTimer("display call", displayCallTime),
			makeTimer("transmission", transmissionTime),
			makeTimer("parsing", parsingTime),
			makeTimer("processing", processingTime)
		]);
	}

	function makeTimer(name:String, time:Float, ?children:Array<Timer>):Timer {
		final date = new Date(time);
		return {
			name: name,
			time: date.getSeconds() + (date.getMilliseconds() / 1000.0),
			children: children
		};
	}

	function onDidChangeRequestQueue(queue:Array<String>) {
		this.queue = [];
		for (i in 0...queue.length) {
			this.queue.push(new Node(context, null, null, null, queue[i], null, Std.string(i)));
		}
		if (viewType == Queue) {
			_onDidChangeTreeData.fire();
		}
	}

	public function getTreeItem(element:Node):Node {
		return element;
	}

	public function getChildren(?element:Node):Array<Node> {
		if (viewType == Queue) {
			return queue;
		}
		return if (element == null) methods else element.children;
	}

	public var getParent = function(element:Node):Null<Node> {
		return element.parent;
	}

	public var resolveTreeItem = js.Lib.undefined;

	function copy(?element:Node) {
		env.clipboard.writeText(if (element == null) {
			methods.map(method -> method.toString()).join("\n\n");
		} else {
			element.toString();
		});
	}

	function track(element:Node) {
		if (element != null) {
			commands.executeCommand("vshaxeDebugTools.methodResultsView.track", element.method);
		}
	}
}
