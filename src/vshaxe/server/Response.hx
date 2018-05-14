package vshaxe.server;

// TODO: don't duplicate this here and in the language server?

typedef Timer = {
    final name:String;
    final path:String;
    final info:String;
    final time:Float;
    final calls:Int;
    final percentTotal:Float;
    final percentParent:Float;
    @:optional final children:Array<Timer>;
}

typedef Response = {
    final result:Dynamic;
    /** Only sent if `--times` is enabled. **/
    @:optional final timers:Timer;
}
