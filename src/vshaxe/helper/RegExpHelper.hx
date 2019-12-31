package vshaxe.helper;

import haxe.macro.Expr;

class RegExpHelper {
	public static macro function makeRegExp(e:Expr):Expr {
		return switch e.expr {
			case EConst(CRegexp(r, opt)): macro new js.lib.RegExp($v{r}, $v{opt});
			case _: throw 'regex literal expected';
		}
	}
}
