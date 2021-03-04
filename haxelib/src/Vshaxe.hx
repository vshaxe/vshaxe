import haxe.ds.ReadOnlyArray;
import js.lib.Promise;
import vscode.Disposable;
import vshaxe.DisplayArgumentsProvider;
import vshaxe.HaxeConfiguration;
import vshaxe.HaxeExecutable;
import vshaxe.HaxeInstallationProvider;
import vshaxe.HaxelibExecutable;
import vshaxe.TaskPresentationOptions;

/**
	Public API provided by the vshaxe extension. Retrieve with vscode's extensions API:

	```haxe
	var vshaxe:Vshaxe = Vscode.extensions.getExtension("nadako.vshaxe").exports
	```
**/
typedef Vshaxe = {
	/**
		Contains the configuration for the Haxe executable, including path and environment variables.
		Corresponds to the `"haxe.executable"` setting. `haxeExecutable.config` is pre-processed,
		meaning that the setting's OS-specific overrides don't need to be handled.

		Should be respected by generated tasks that call Haxe directly or indirectly.
	**/
	var haxeExecutable(default, never):HaxeExecutable;

	/**
		Contains the configuration for the Haxelib executable.
		Corresponds to the `"haxelib.executable"` setting. `haxelibExecutable.config` is pre-processed,
		meaning that the setting's OS-specific overrides don't need to be handled.

		Should be respected by generated tasks that call Haxelib directly or indirectly.

		@since 2.23.0
	**/
	var haxelibExecutable(default, never):HaxelibExecutable;

	/**
		The port at which the completion server is reachable via `--connect`, or `null`.
		Corresponds to the `"haxe.displayPort"` setting.

		Should be respected by generated tasks that call Haxe directly or indirectly if `enableCompilationServer` is `true`.
	**/
	var ?displayPort(default, never):Int;

	/**
		Whether the `displayPort` should be used to connect to the compilation server for building.
		Corresponds to the `"haxe.enableCompilationServer"` setting.
	**/
	var enableCompilationServer(default, never):Bool;

	/**
		The names of all problem matchers added by the Haxe extension, in order of priority.

		Should be respected by generated tasks that call Haxe directly or indirectly.
	**/
	var problemMatchers(default, never):ReadOnlyArray<String>;

	/**
		Should be assigned to `vscode.Task.presentationOptions` when generating tasks.
		Corresponds to the `"haxe.taskPresentation"` setting.
	**/
	var taskPresentation(default, never):TaskPresentationOptions;

	/**
		Register a display argument provider.

		Display arguments are passed to the Haxe Language Server for completion and used for the dependency explorer.

		An extension should only register a provider if it handles the current workspace's project type
		(usually when a matching project file is present, e.g. a `project.xml` for Lime projects).
		In the case of two competing providers, the user is prompted to select between them.

		@param name A unique ID to identify the extension. No two providers with the same name can be registered.
		@param provider A display argument provider.
		@return A disposable which unregisters the provider.
	**/
	function registerDisplayArgumentsProvider(name:String, provider:DisplayArgumentsProvider):Disposable;

	/**
		Register a Haxe installation provider.

		An extension should only register a provider if it handles the current workspace's Haxe setup
		(for instance when a `.haxerc` is present in case of lix).

		@param name A unique ID to identify the extension. No two providers with the same name can be registered.
		@param provider A Haxe installation provider.
		@return A disposable which unregisters the provider.
		@since 2.13.0
	**/
	function registerHaxeInstallationProvider(name:String, provider:HaxeInstallationProvider):Disposable;

	/**
		Parse contents of a hxml file into an array of Haxe command-line arguments.

		Skips comments and unquotes arguments.

		An extension can use this if it has to work with framework-generated hxml files that need to be used
		for providing display arguments.
	**/
	function parseHxmlToArguments(hxml:String):Array<String>;

	/**
		Allows to access the properties associated with the active "Haxe Configuration". The active configuration is
		displayed in the status bar and can be changed with the `Haxe: Select Configuration` command.

		The compiler arguments for the active configurations can come from auto-discovered HXML files,
		the `"haxe.configurations"` setting or display argument providers.

		@since 2.19.0
	**/
	function getActiveConfiguration():Promise<HaxeConfiguration>;
}
