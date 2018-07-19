package vshaxe.helper;

import js.Promise;
import vshaxe.server.LanguageServer;
import haxe.display.Position.Range as ProtocolRange;

/**
    TODO: remove this workaround once the LSP / vscode-languageclient has support for the new document symbols API
**/
class HaxeDocumentSymbolProvider {
    final server:LanguageServer;

    public function new(server:LanguageServer) {
        this.server = server;
        server.onDidStartServer = function() {
            languages.registerDocumentSymbolProvider('haxe', this);
        };
    }

    public function provideDocumentSymbols(document:TextDocument, token:CancellationToken):ProviderResult<Array<DocumentSymbol>> {
        return new Promise(function(resolve, reject) {
            var params = {textDocument: {uri: document.uri.toString()}};
            server.client.sendRequest("haxe/documentSymbol", params).then(function(symbols:Array<ProtocolDocumentSymbol>) {
                resolve(symbols.map(convertSymbol));
            });
        });
    }

    function convertSymbol(symbol:ProtocolDocumentSymbol):DocumentSymbol {
        var result = new DocumentSymbol(symbol.name, symbol.detail, cast symbol.kind - 1, convertRange(symbol.range), convertRange(symbol.selectionRange));
        result.children = symbol.children.map(convertSymbol);
        return result;
    }

    function convertRange(range:ProtocolRange):Range {
        return new Range(range.start.line, range.start.character, range.end.line, range.end.character);
    }
}

private typedef ProtocolDocumentSymbol = {
    var name:String;
    var detail:String;
    var kind:Int;
    var ?deprecated:Bool;
    var range:ProtocolRange;
    var selectionRange:ProtocolRange;
    var ?children:Array<ProtocolDocumentSymbol>;
}
