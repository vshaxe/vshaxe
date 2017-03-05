package builders;

class DisplayHxmlBuilder extends BaseBuilder {
    override public function build(cliArgs:CliArguments) {
        var hxmls = resolveTargets(cliArgs.targets).map(resolveTargetHxml.bind(_, true, true, true));
        var hxml = mergeHxmls(hxmls, true);
        var lines = printHxmlFile(hxml);
        lines.insert(0, '# ${Warning.Message}');
        lines = lines.filterDuplicates(function(s1, s2) return s1 == s2);

        cli.saveContent("complete.hxml", lines.join("\n"));
    }

    function printHxmlFile(hxml:Hxml):Array<String> {
        if (hxml == null)
            return [];

        var lines = [];
        for (cp in hxml.classPaths.get()) lines.push('-cp $cp');
        for (define in hxml.defines.get()) lines.push('-D $define');
        for (lib in hxml.haxelibs.get()) lines.push('-lib ${resolveHaxelib(lib).name}');
        if (hxml.debug) lines.push("-debug");
        if (hxml.output != null) lines.push('-${hxml.output.target} ${hxml.output.path}');
        if (hxml.noInline == true) lines.push('--no-inline');
        return lines;
    }
}