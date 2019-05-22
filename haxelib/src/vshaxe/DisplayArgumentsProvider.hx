package vshaxe;

typedef DisplayArgumentsProvider = {
	/**
		A human-readable description for this provider that is
		shown next to its name in the "Select Haxe completion provider" UI.
	**/
	var description(default, never):String;

	/**
		Called when vshaxe selects the provider for providing completion.

		@param provideArguments A callback that should be cached by the provider, and called whenever display arguments change.
								Should only be called when necessary.
	**/
	function activate(provideArguments:Array<String>->Void):Void;

	/**
		Called when this display argument provider is no longer active, for instance because the user has chosen to use
		another provider. The provider is informed about this to stop unnecessary system calls if deactivated.

		*Note:* a deactivated provider can be activated again!
	**/
	function deactivate():Void;
}
