package vshaxe;

/**
	@since 2.13.0
**/
enum HaxeExecutableSource {
	/**
		The Haxe executable was determined by the `"haxe.executable"` setting.
	**/
	Settings;

	/**
		The `"haxe.executable"` setting was set to `"auto"` and the executable was resolved by a specific `HaxeInstallationProvider`.
	**/
	Provider(name:String);
}
