/** Just a wrapper for build/Build.hx to avoid having to pass --cwd or -lib hxargs **/
class Build {
    static function main() {
        Sys.command("haxe", ["--cwd", "build", "-lib", "hxargs", "-lib", "hxnodejs", "-js", "run.js", "-main", "Main"]);
        Sys.setCwd("build");
        Sys.command("node", ["run.js"].concat(Sys.args()));
    }
}