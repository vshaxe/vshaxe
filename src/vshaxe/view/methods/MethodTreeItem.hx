package vshaxe.view.methods;

import vshaxe.server.HaxeMethodResult;

class MethodTreeItem extends TreeItem {
	final context:ExtensionContext;
	final timer:Null<Timer>;
	final name:String;
	final debugInfo:String;
	var isRoot(get, never):Bool;

	inline function get_isRoot()
		return parent == null;

	public final children:Null<Array<MethodTreeItem>>;
	public final method:String;
	public final parent:Null<MethodTreeItem>;

	public function new(context:ExtensionContext, parent:MethodTreeItem, timer:Timer, method:String, ?debugInfo:String, parentId:String = "") {
		super("");
		this.context = context;
		this.parent = parent;
		this.timer = timer;
		this.method = method;
		this.debugInfo = debugInfo;

		name = formatName();
		label = formatLabel();
		tooltip = formatTooltip();
		id = parentId + ">" + name;

		if (timer == null || timer.children == null) {
			children = null;
			collapsibleState = None;
		} else {
			children = timer.children.map(MethodTreeItem.new.bind(context, this, _, method, null, id));
			collapsibleState = Expanded;
		}
		if (isRoot) {
			iconPath = {
				light: context.asAbsolutePath("resources/light/method.svg"),
				dark: context.asAbsolutePath("resources/dark/method.svg")
			};
		}
	}

	function formatName():String {
		var name = if (isRoot) method else timer.name;
		if (timer != null && timer.info != "" && timer.info != null) {
			name = '${timer.info}.$name';
		}
		return name;
	}

	function formatLabel():String {
		if (timer == null) {
			return name;
		}
		var seconds = truncate(timer.time, 5);
		var percent = if (timer.percentTotal != null) truncate(timer.percentTotal, 4) else null;
		var label = '$name - ${seconds}s';
		if (!isRoot && percent != null) {
			label += ' ($percent%)';
		}
		if (debugInfo != null) {
			label += ' [$debugInfo]';
		}
		return label;
	}

	function formatTooltip():String {
		if (timer == null) {
			return null;
		}
		var now = Date.now();
		var timestamp = '[${now.getHours()}:${now.getMinutes()}:${now.getSeconds()}]';
		var calls = if (timer.calls != null) '${timer.calls} calls ' else "";
		return '$timestamp $calls- ${truncate(timer.time, 7)}s';
	}

	function truncate(f:Float, precision:Int) {
		return Std.string(f).substr(0, precision);
	}

	public function toString(indent:String = ""):String {
		var result = indent + label;
		if (children != null) {
			result += "\n" + children.map(child -> child.toString(indent + "  ")).join("\n");
		}
		return result;
	}
}
