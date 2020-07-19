import js.lib.Promise;

@:expose("run") function run():Promise<Void> {
	return new Promise(function(resolve, reject) {
		trace("Hello World");
		resolve(js.Lib.undefined);
	});
}
