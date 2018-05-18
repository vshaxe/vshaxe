package vshaxe.server;

// TODO: don't duplicate this here and in the language server?

typedef HaxeMethodResult = {
    final method:String;
    final arrivalDate:Float;
    final processedDate:Float;
    final response:Response<Dynamic>;
}

typedef Timer = {
    final name:String;
    final time:Float;
    @:optional final path:String;
    @:optional final info:String;
    @:optional final calls:Int;
    @:optional final percentTotal:Float;
    @:optional final percentParent:Float;
    @:optional final children:Array<Timer>;
}

typedef Response<T> = {
    final result:T;
    /** UNIX timestamp at the moment the data was sent. **/
    final timestamp:Float;
    /** Only sent if `--times` is enabled. **/
    @:optional final timers:Timer;
}
