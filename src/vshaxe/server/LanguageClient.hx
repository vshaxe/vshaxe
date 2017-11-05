package vshaxe.server;

import haxe.extern.EitherType;
import js.Promise;

@:jsRequire("vscode-languageclient", "LanguageClient")
extern class LanguageClient {
    function new(id:String, name:String, serverOptions:ServerOptions, clientOptions:LanguageClientOptions, ?forceDebug:Bool);

    function start():Disposable;
    function stop():Thenable<Void>;

    function onNotification(method:String, handler:Dynamic->Void):Void;
    function sendNotification(method:String, ?params:Dynamic):Void;
    function sendRequest<P,R>(method:String, param:P, ?token:CancellationToken):Thenable<R>;
    function onReady():Promise<Void>;
    var outputChannel(default,null):OutputChannel;

    function info(message:String, ?data:Any):Void;
    function warn(message:String, ?data:Any):Void;
    function error(message:String, ?data:Any):Void;
}

typedef ExecutableOptions = {
    ?cwd:String,
    ?stdio:EitherType<String,Array<String>>,
    ?env:Dynamic,
    ?detached:Bool,
}

typedef Executable = {
    command:String,
    ?args:Array<String>,
    ?options:ExecutableOptions,
}

typedef ForkOptions = {
    ?cwd:String,
    ?env:Dynamic,
    ?encoding:String,
    ?execArgv:Array<String>,
}

typedef NodeModule = {
    module:String,
    ?transport:TransportKind,
    ?args:Array<String>,
    ?runtime:String,
    ?options:ForkOptions,
}

abstract ServerOptions(Dynamic)
    from Executable
    from {run:Executable, debug:Executable}
    from {run:NodeModule, debug:NodeModule}
    from NodeModule
{}

@:enum abstract TransportKind(Int) {
    var stdio = 0;
    var ipc = 1;
    var pipe = 2;
}

typedef LanguageClientOptions = {
    ?documentSelector:EitherType<DocumentSelector,Array<String>>,
    ?synchronize:SynchronizeOptions,
    ?diagnosticCollectionName:String,
    ?outputChannel:OutputChannel,
    ?revealOutputChannelOn:RevealOutputChannelOn,
    ?stdioEncoding:String,
    ?initializationOptions:EitherType<Dynamic,Void->Dynamic>,
    ?uriConverters:{
        code2Protocol:Uri->String,
        protocol2Code:String->Uri,
    },
    ?workspaceFolder:WorkspaceFolder,
}

typedef SynchronizeOptions = {
    ?configurationSection:EitherType<String,Array<String>>,
    ?fileEvents:EitherType<FileSystemWatcher,Array<FileSystemWatcher>>
}

@:enum abstract RevealOutputChannelOn(Int) {
    var Info = 1;
    var Warn = 2;
    var Error = 3;
    var Never = 4;
}
