class Test {
	var foo(get, set):Int;

	function get_foo():Int {
		throw new haxe.exceptions.NotImplementedException();
	}

	function set_foo(value:Int):Int {
		throw new haxe.exceptions.NotImplementedException();
	}
}
