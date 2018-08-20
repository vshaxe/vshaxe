package vshaxe.server;

// TODO: don't duplicate this here and in the language server?
typedef HaxeMethodResult = {
	final method:String;
	final debugInfo:String;
	final response:Response<Dynamic>;
	final ?additionalTimes:{
		final beforeCall:Float;
		final arrival:Float;
		final beforeProcessing:Float;
		final afterProcessing:Float;
	}
}

typedef Timer = {
	final name:String;
	final time:Float;
	final ?path:String;
	final ?info:String;
	final ?calls:Int;
	final ?percentTotal:Float;
	final ?percentParent:Float;
	final ?children:Array<Timer>;
}

typedef Response<T> = {
	final result:T;

	/** UNIX timestamp at the moment the data was sent. **/
	final timestamp:Float;

	/** Only sent if `--times` is enabled. **/
	@:optional final timers:Timer;
}
