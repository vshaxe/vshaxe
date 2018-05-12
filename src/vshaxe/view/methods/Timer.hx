package vshaxe.view.methods;

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
