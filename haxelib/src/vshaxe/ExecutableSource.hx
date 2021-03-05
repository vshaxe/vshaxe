package vshaxe;

/**
	@since 2.23.0
**/
enum ExecutableSource {
	/**
		The executable was determined by the user or workspace setting.
	**/
	Settings;

	/**
		The setting was set to `"auto"` and the executable was resolved by a specific `HaxeInstallationProvider`.
	**/
	Provider(name:String);
}
