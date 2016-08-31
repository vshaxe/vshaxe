package vshaxe;

class Macro {
	public static macro function getGitSha() {
		var sha = try new sys.io.Process('git', ["rev-parse", "HEAD"]).stdout.readAll().toString().substr(0, 8) catch(e:Dynamic) "";
		return macro $v{sha};
	}
}