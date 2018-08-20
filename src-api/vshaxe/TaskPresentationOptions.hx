package vshaxe;

import vscode.TaskRevealKind;
import vscode.TaskPanelKind;

/**
	Controls how the task is presented in the UI.
	Read-only version of `vscode.TaskPresentationOptions`.
**/
typedef TaskPresentationOptions = {
	/**
		Controls whether the task output is reveal in the user interface.
		Defaults to `RevealKind.Always`.
	**/
	@:optional var reveal(default, never):TaskRevealKind;

	/**
		Controls whether the command associated with the task is echoed
		in the user interface.
	**/
	@:optional var echo(default, never):Bool;

	/**
		Controls whether the panel showing the task output is taking focus.
	**/
	@:optional var focus(default, never):Bool;

	/**
		Controls if the task panel is used for this task only (dedicated),
		shared between tasks (shared) or if a new panel is created on
		every task execution (new). Defaults to `TaskInstanceKind.Shared`
	**/
	@:optional var panel(default, never):TaskPanelKind;

	/**
		Controls whether to show the "Terminal will be reused by tasks, press any key to close it" message.
	**/
	@:optional var showReuseMessage(default, never):Bool;
}
