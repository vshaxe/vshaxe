package vshaxe.helper;

import haxe.Constraints.Function;

class ContextHelper {
	public static function registerHaxeCommand(context:ExtensionContext, command:HaxeCommand, callback:Function) {
		context.subscriptions.push(commands.registerCommand(command, callback));
	}

	public static function registerCommand(context:ExtensionContext, command:String, callback:Function) {
		context.subscriptions.push(commands.registerCommand(command, callback));
	}
}
