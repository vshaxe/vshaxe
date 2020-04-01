package vshaxe;

/**
	@since 2.19.0
**/
typedef HaxeConfiguration = {
	/**
		All class paths of the configuration. This includes class paths from `-cp`,
		resolved `-lib` arguments and the standard library.
	**/
	final classPaths:Array<ClassPath>;

	/**
		All defines of the configuration. This includes defines from resolved `-lib` arguments,
		but excludes defines added dynamically in initialization macros.
	**/
	final defines:Map<String, String>;

	/**
		The target that has been selected, or `NONE`.
	**/
	final target:Target;

	/**
		The dot path to the main class as specified by `-main`, if present.
	**/
	final ?main:String;
}

/**
	@since 2.19.0
**/
typedef ClassPath = {
	final path:String;
}

/**
	@since 2.19.0
**/
enum Target {
	None;
	Js(file:String);
	Lua(file:String);
	Swf(file:String);
	As3(directory:String);
	Neko(file:String);
	Php(directory:String);
	Cpp(directory:String);
	Cppia(file:String);
	Cs(directory:String);
	Java(directory:String);
	Python(file:String);
	Hl(file:String);
	Interp;
}
