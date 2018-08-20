package vshaxe.helper;

@:jsRequire("copy-paste")
extern class CopyPaste {
	public static function copy(text:String, ?callback:Void->Void):Void;
}
