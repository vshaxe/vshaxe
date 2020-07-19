class Test implements I {
	public var bar:String;

	public var foo(get, set):ReadOnlyArray<Float>;

	public function test(i:Int) {}
}

interface I {
	var foo(get, set):haxe.ds.ReadOnlyArray<Float>;

	var bar:String;

	function test(i:Int):Void;
}
