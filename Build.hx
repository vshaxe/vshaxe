/** Just a wrapper for build/Build.hx to avoid having to pass --cwd or -lib hxargs **/
class Build {
    static function main() {
        Sys.command("haxe", ["--cwd", "build", "-lib", "hxargs", "--run", "Main"].concat(Sys.args()));
    }
}