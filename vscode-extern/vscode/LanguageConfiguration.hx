package vscode;

typedef LanguageConfiguration = {
	@:optional var comments:CommentRule;
	@:optional var brackets:Array<CharacterPair>;
	@:optional var wordPattern:js.RegExp;
	@:optional var indentationRules:IndentationRule;
	@:optional var onEnterRules:Array<OnEnterRule>;
	@:optional var __electricCharacterSupport:{
		@:optional var brackets:Dynamic;
		@:optional var docComment:{
			var scope:String;
			var open:String;
			var lineStart:String;
			@:optional var close:String;
		};
	};
	@:optional var __characterPairSupport:{
		var autoClosingPairs:Array<{open:String, close:String, ?notIn:Array<String>}>;
	};
}
