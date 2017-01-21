class Main {
	static function main() {
		var myShinyVar = {name: "Hello"};

		function doBeatifulThings(who:String) {
			return who.length;
		}

		doBeatifulThings(myShinyVar.name);
	}
}