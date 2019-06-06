package vshaxe;

typedef HaxeInstallationProvider = {
	/**
		Called when vshaxe selects the provider for providing the Haxe installation.

		@param provideInstallation A callback that should be cached by the provider, and called whenever the Haxe installation changes.
									Should only be called when necessary.
	**/
	function activate(provideInstallation:HaxeInstallation->Void):Void;

	/**
		Called when this Haxe installation provider is no longer active, for instance because the user has chosen to use
		another provider.

		*Note:* a deactivated provider can be activated again!
	**/
	function deactivate():Void;
}
