@:jsRequire("vscode-textmate", "Registry")
extern class Registry {
    function new();
    function loadGrammarFromPathSync(path:String):IGrammar;
}

typedef IGrammar = {
    function tokenizeLine(lineText:String, ?prevState:StackElement):ITokenizeLineResult;
}

typedef ITokenizeLineResult = {
    var tokens(default,null):Array<IToken>;
    var ruleStack(default,null):StackElement;
}

typedef IToken = {
    var startIndex:Int;
    var endIndex(default,null):Int;
    var scopes(default,null):Array<String>;
}

typedef StackElement = {}
