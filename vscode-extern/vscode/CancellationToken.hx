package vscode;

typedef CancellationToken = {
	var isCancellationRequested:Bool;
	var onCancellationRequested:Event<Dynamic>;
}
