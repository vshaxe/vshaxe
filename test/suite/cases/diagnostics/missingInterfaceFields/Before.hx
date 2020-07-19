class Test implements I {}

interface I {
	var foo(get, set):haxe.ds.ReadOnlyArray<Float>;

	final bar:String;

	function test(i:Int):Void;
}
