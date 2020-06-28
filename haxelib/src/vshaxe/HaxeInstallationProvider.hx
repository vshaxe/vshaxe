package vshaxe;

/**
	@since 2.13.0
**/
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

	/**
		Optionally resolves classpaths to libraries for the Haxe Dependencies view,
		or `null` if the classpath does not belong to a library.
	**/
	var ?resolveLibrary:(classpath:String) -> Null<Library>;

	/** 
		Optionally lists available libraries for HXML `--library` completion.

		@since 2.21.0
	**/
	var ?listLibraries:() -> Array<{name:String}>;
}
