package vscode;

typedef DecorationRenderOptions = {
	>ThemableDecorationRenderOptions,
	@:optional var isWholeLine:Bool;
	@:optional var overviewRulerLane:OverviewRulerLane;
	@:optional var light:ThemableDecorationRenderOptions;
	@:optional var dark:ThemableDecorationRenderOptions;
}
