/**
 * This is not really a valid Haxe file, just a demo
 */

package;
package net.onthewings;

import net.onthewings.Test;
import net.onthewings.*;

import haxe.Int64 as I64;
import haxe.Int64 in I64;
import haxe.macro.Expr;

using Lambda;
using net.onthewings.Test;

#if flash8
// Haxe code specific for flash player 8
#elseif flash
// Haxe code specific for flash platform (any version)
#elseif js
// Haxe code specific for javascript plaform
#elseif neko
// Haxe code specific for neko plaform
#else
// do something else
    #error  // will display an error "Not implemented on this platform"
    #error "Custom error message" // will display an error "Custom error message"
#end

abstract Abstract(String) from String to String {
	public static var fromStringMap(default, null):Map<String, FlxKey>
		= FlxMacroUtil.buildMap("flixel.input.keyboard.FlxKey");
}

interface ITest {
	function test():Void;
}

typedef Pt = {
	var x:Float;
	var y:Float;
	@:optional var z:Float; /* optional z */
	function add(pt:Pt):Void;
}
typedef Pt2 = {
	x:Float,
	y:Float,
	?z:Float, //optional z
	add : Point -> Void,
}

typedef DS = Dynamic<String> // no semicolon

class Foo {
	override dynamic macro extern inline static function foo() {

		super.foo();

		0; // Int
		-134; // Int
		0xFF00; // Int

		123.0; // Float
		.14179; // Float
		13e50; // Float
		-1e-99; // Float

		"hello"; // String
		"hello \"world\" !"; // String
		'hello "world" !'; // String

		'$$variable $variable\''; /* */
		'random ${"number" + '${macro 5}' + (Math.random() * 5) /* */ }';

		"Multi
		line
		string";

		'Multi
		line
		string';

		true; // Bool
		false; // Bool

		null; // Unknown<0>

		~/[a-z]+/i; // EReg : regular expression

		$type(2);

		var a:Int = cast 2; // unsafe cast
		var b:Int = cast (2, Int); // safe cast

		var point = { "x" : 1, "y" : -5 };

		{
		    var x;
		    var y = 3;
		    var z : String;
		    var w : String = "";
		    var a, b : Bool, c : Int = 0;
		}

		var v = {
			5;
		};

		var f = function(foo) {}

		for(i in 0...20) {}
		for ( i   in 0...20) {}
		while (true) {}

		do {
			break;
			continue;
		} while (true)

		//haxe3 pattern matching
		switch(e.expr) {
			case EConst(CString(s)) if (StringTools.startsWith(s, "foo")):
				"1";
			case EConst(CString(s)) if (StringTools.startsWith(s, "bar")):
				"2";
			case EConst(CInt(i)) if (switch(Std.parseInt(i) * 2) { case 4: true; case _: false; }):
				"3";
			case EConst(_):
				"4";
			case _:
				"5";
		}

		switch [true, 1, "foo"] {
			case [true, 1, "foo"]: "0";
			case [true, 1, _]: "1";
			case _: "_";
		}

		//macro reification
		var e = macro var $myVar = 0;
		var e = macro ${v}.toLowerCase();
		var e = macro o.$myField;
		var e = macro { $myField : 0 };
		var e = macro $i{varName}++;
		var e = macro $v{myStr};
		var args = [macro "sub", macro 3];
		var e = macro "Hello".toLowerCase($a{args});
		(macro $i{tmp}.addAtom($v{name}, $atom)).finalize(op.pos);

		var c = macro class MyClass {
		    public function new() { }
		    public function $funcName() {
		        trace($v{funcName} + " was called");
		    }
		}

		var c = macro interface IClass {};

		//macro class could have no name...
		var def = macro class {
			private inline function new(loader) this = loader;
			private var loader(get,never) : $loaderType;
			inline private function get_loader() : $loaderType return this;
		};

		//ECheckType
		var f = (123:Float);

		//Exception handling
		try {
			throw "error";
		} catch (e:Dynamic) {}
	}

	//top-level class members
	public function test();
	private var attr(get, set):Int = 1;
	private var attr2(default, null) = ['Test'];
	private var attr3(dynamic, never);

	/**
	 * IndexOf function
	 *
	 * @param arr an array
	 * @param v the value to search
	 * @return the index
	 * @since 4.0.0-alpha.2
	 * @see haxe.org
	 * @deprecated
	 */
	public static inline function indexOf<T>(?arr:Array<T>, v:T) : Int
	{
		#if (haxe_ver >= 3.1)
		#line 0 return arr.indexOf(v);
		#else
			#if (flash || js)
			return untyped arr.indexOf(v);
			#else
			return std.Lambda.indexOf(arr, v);
			#end
		#end
	}

	// single-line conditionals
	function foo() {
		#if (haxe_ver >= 3.1) return true #elseif false return false #else throw "error" #end ;
	}
}

class Test <T:Void->Void> {
	private function new():Void {
		inline function innerFun(a:Int, b:Int):Int {
			return readOnlyField = a + b;
		}

		_innerFun(1, 2.3);
	}

	static public var instance(get,null):Test;
	static function get_instance():Test {
		return instance != null ? instance : instance = new Test();
	}
}

@:native("Test") private class Test2 {}

extern class Ext {}

@:macro class M {
	@:macro static function test(e:Array<Expr>):ExprOf<String> {
		return macro "ok";
	}
}

enum Color {
    Red;
    Green;
    Blue;
    Grey( v : Int );
    Rgb( r : Int, g : Int, b : Int );
    Alpha( a : Int, col : Color );
}

class Colors {
    static function toInt( c : Color ) : Int {
        return switch( c ) {
            case Red: 0xFF0000;
            case Green: 0x00FF00;
            case Blue: 0x0000FF;
            case Grey(v): (v << 16) | (v << 8) | v;
            case Rgb(r,g,b): (r << 16) | (g << 8) | b;
            case Alpha(a,c): (a << 24) | (toInt(c) & 0xFFFFFF);
        }
    }
}

class EvtQueue<T : (Event, EventDispatcher)> {
    var evt : T;
}

// compiler-built-in-metadata
// how to update for new meta:

// use this to get the list for this source file:
// haxe --help-metas | cut -c -24 | cut -c 1- | sed '/^\s*$/d' | tr -d ' '

// to get the list for the regex:
// haxe --help-metas | cut -c -24 | cut -c 4- | sed '/^\s*$/d' | tr -d ' '|  tr '\n' '|'

@:abi
@:abstract
@:access
@:allow
@:analyzer
@:annotation
@:arrayAccess
@:astSource
@:autoBuild
@:bind
@:bitmap
@:bridgeProperties
@:build
@:buildXml
@:callable
@:classCode
@:commutative
@:compilerGenerated
@:const
@:coreApi
@:coreType
@:cppFileCode
@:cppInclude
@:cppNamespaceCode
@:dce
@:debug
@:decl
@:delegate
@:depend
@:deprecated
@:eager
@:enum
@:event
@:expose
@:extern
@:fakeEnum
@:file
@:fileXml
@:final
@:fixed
@:font
@:forward
@:forwardStatics
@:from
@:functionCode
@:functionTailCode
@:generic
@:genericBuild
@:getter
@:hack
@:headerClassCode
@:headerCode
@:headerInclude
@:headerNamespaceCode
@:hxGen
@:ifFeature
@:include
@:internal
@:isVar
@:javaCanonical
@:jsRequire
@:keep
@:keepInit
@:keepSub
@:luaRequire
@:macro
@:mergeBlock
@:meta
@:multiType
@:native
@:nativeChildren
@:nativeGen
@:nativeProperty
@:nativeStaticExtension
@:noCompletion
@:noDebug
@:noDoc
@:noImportGlobal
@:noPrivateAccess
@:noStack
@:noUsing
@:nonVirtual
@:notNull
@:ns
@:objc
@:objcProtocol
@:op
@:optional
@:overload
@:phpConstants
@:phpGlobal
@:privateAccess
@:property
@:protected
@:publicFields
@:pure
@:pythonImport
@:readOnly
@:remove
@:require
@:resolve
@:rtti
@:runtime
@:runtimeValue
@:scalar
@:selfCall
@:setter
@:sound
@:sourceFile
@:stackOnly
@:strict
@:struct
@:structAccess
@:structInit
@:suppressWarnings
@:templatedCall
@:throws
@:to
@:transient
@:unifyMinDynamic
@:unreflective
@:unsafe
@:value
@:void
@:volatile