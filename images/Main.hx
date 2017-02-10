class Main {
	static function main() {
		var myShinyVar = {name: "Hello"};

		function doBeautifulThings(who:String) {
			return who.length;
		}

		doBeautifulThings(myShinyVar.name);
	}
}