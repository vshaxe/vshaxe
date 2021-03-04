package vshaxe;

/**
	@since 2.23.0
**/
enum HaxelibExecutableSource {
	/**
		The Haxelib executable was determined by the `"haxelib.executable"` setting.
	**/
	Settings;

	/**
		The `"haxelib.executable"` setting was set to `"auto"` and the executable was resolved by a specific `HaxeInstallationProvider`.
	**/
	Provider(name:String);
}
