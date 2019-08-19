package vshaxe.view.methods;

import haxe.display.Protocol.Timer;
import haxeLanguageServer.LanguageServerMethods.MethodResultKind;

class Node extends TreeItem {
	final context:ExtensionContext;
	final timer:Null<Timer>;
	final name:String;
	final kind:Null<MethodResultKind>;
	final debugInfo:Null<String>;
	var isRoot(get, never):Bool;

	inline function get_isRoot()
		return parent == null;

	public final children:Array<Node>;
	public final method:String;
	public final parent:Null<Node>;

	public function new(context:ExtensionContext, ?parent:Node, ?timer:Timer, ?kind:MethodResultKind, method:String, ?debugInfo:String, parentId:String = "") {
		super("");
		this.context = context;
		this.parent = parent;
		this.timer = timer;
		this.kind = kind;
		this.method = method;
		this.debugInfo = debugInfo;

		children = [];
		name = formatName();
		label = formatLabel();
		tooltip = formatTooltip();
		id = parentId + ">" + name;

		if (timer == null || timer.children == null || kind == Lsp) {
			collapsibleState = None;
		} else {
			children = timer.children.map(Node.new.bind(context, this, _, kind, method, null, id));
			collapsibleState = Collapsed;
		}
		if (isRoot) {
			var file = if (kind == Lsp) 'lsp-method' else 'haxe-method';
			iconPath = {
				light: context.asAbsolutePath('images/light/$file.svg'),
				dark: context.asAbsolutePath('images/dark/$file.svg')
			};
		}
	}

	function formatName():String {
		var name = if (isRoot || timer == null) method else timer.name;
		if (timer != null && timer.info != null && timer.info != "") {
			name = '${timer.info}.$name';
		}
		return name;
	}

	function formatLabel():String {
		if (timer == null || kind == Lsp) {
			return name;
		}
		var seconds = truncate(timer.time, 5);
		var percent = if (timer.percentTotal != null) truncate(timer.percentTotal, 4) else null;
		var label = '$name - ${seconds}s';
		if (!isRoot && percent != null) {
			label += ' ($percent%) [${timer.calls} call${timer.calls == 1 ? "" : "s"}]';
		}
		if (debugInfo != null) {
			label += ' [$debugInfo]';
		}
		return label;
	}

	function formatTooltip():Null<String> {
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
		var result = indent + if (label == null) "" else label;
		if (children != null) {
			result += "\n" + children.map(child -> child.toString(indent + "  ")).join("\n");
		}
		return result;
	}
}
