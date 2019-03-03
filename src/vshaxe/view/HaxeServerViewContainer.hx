package vshaxe.view;

import vshaxe.server.LanguageServer;
import vshaxe.view.cache.CacheTreeView;
import vshaxe.view.methods.MethodTreeView;

class HaxeServerViewContainer {
	var enabled:Bool;
	final methodTreeView:MethodTreeView;

	public function new(context:ExtensionContext, server:LanguageServer) {
		methodTreeView = new MethodTreeView(context, server);
		new CacheTreeView(context, server);
		inline update();
		workspace.onDidChangeConfiguration(_ -> update());
	}

	function update() {
		enabled = workspace.getConfiguration("haxe").get("enableServerView", false);
		commands.executeCommand("setContext", "enableHaxeServerView", enabled);
		methodTreeView.enabled = enabled;
	}
}
