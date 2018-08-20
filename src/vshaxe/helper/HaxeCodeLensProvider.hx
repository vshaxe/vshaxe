package vshaxe.helper;

/**
	This is just a dummy code lens provider that is only used to trigger a refresh via
	`onDidChangeCodeLenses` whenever the `enableCodeLens` setting changes.
	This is a workaround for the LSP not supporting this feature yet:
	https://github.com/Microsoft/language-server-protocol/issues/192
**/
class HaxeCodeLensProvider {
	var _onDidChangeCodeLenses = new EventEmitter<Void>();
	var enableCodeLens:Bool;

	public var onDidChangeCodeLenses:Event<Void>;

	public function new() {
		onDidChangeCodeLenses = _onDidChangeCodeLenses.event;
		enableCodeLens = getEnableCodeLens();
		languages.registerCodeLensProvider('haxe', this);
		workspace.onDidChangeConfiguration(onDidChangeConfiguration);
	}

	function getEnableCodeLens():Bool {
		return workspace.getConfiguration("haxe").get("enableCodeLens");
	}

	function onDidChangeConfiguration(_) {
		var enableCodeLens = getEnableCodeLens();
		if (enableCodeLens != this.enableCodeLens) {
			_onDidChangeCodeLenses.fire();
			this.enableCodeLens = enableCodeLens;
		}
	}

	public function provideCodeLenses(document:TextDocument, token:CancellationToken):ProviderResult<Array<CodeLens>> {
		return [];
	}

	public function resolveCodeLens(codeLens:CodeLens, token:CancellationToken):ProviderResult<CodeLens> {
		return codeLens;
	}
}
