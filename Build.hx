/** Just a wrapper for build/Build.hx to avoid boilerplate **/
class Build {
    static function main() {
        Sys.command("haxe", ["--cwd", "build", "-lib", "hxargs", "-lib", "json2object", "--run", "Main"].concat(Sys.args()));
    }
}