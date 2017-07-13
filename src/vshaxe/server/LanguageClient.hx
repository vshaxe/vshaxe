package vshaxe.server;

import haxe.extern.EitherType;
import js.node.ChildProcess.ChildProcessForkOptions;
import js.Promise;

@:jsRequire("vscode-languageclient", "LanguageClient")
extern class LanguageClient {
    function new(id:String, name:String, serverOptions:ServerOptions, languageOptions:LanguageClientOptions, ?forceDebug:Bool);
    function start():Disposable;
    function stop():Void;
    function onNotification(type:RequestType, handler:Dynamic->Void):Void;
    function sendNotification(type:RequestType, ?params:Dynamic):Void;
    function sendRequest<P,R>(type:RequestType, params:P):Thenable<R>;
    function onReady():Promise<Void>;
    var outputChannel(default,null):vscode.OutputChannel;

    function info(message:String, ?data:Any):Void;
    function warn(message:String, ?data:Any):Void;
    function error(message:String, ?data:Any):Void;

    dynamic function logFailedRequest(type:RequestType, error:Any):Void;
}

typedef RequestType = {method:String}

@:enum abstract TransportKind(Int) {
    var stdio = 0;
    var ipc = 1;
}

typedef NodeModule = {
    var module:String;
    @:optional var transport:TransportKind;
    @:optional var args:Array<String>;
    @:optional var options:ChildProcessForkOptions;
}

typedef ServerOptions = {
    run: NodeModule,
    debug: NodeModule,
}

typedef LanguageClientOptions = {
    @:optional var documentSelector:EitherType<String,Array<String>>;
    @:optional var synchronize:SynchronizeOptions;
    @:optional var diagnosticCollectionName:String;
    @:optional var initializationOptions:Dynamic;
}

typedef SynchronizeOptions = {
    @:optional var configurationSection:EitherType<String,Array<String>>;
    @:optional var fileEvents:EitherType<FileSystemWatcher,Array<FileSystemWatcher>>;
    @:optional var textDocumentFilter:TextDocument->Bool;
}
