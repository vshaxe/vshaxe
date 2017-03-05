package builders;

import haxe.ds.Option;
import haxe.io.Path;

/** sounds like an RTS... **/
class BaseBuilder implements IBuilder {
    var cli:CliTools;
    var projects:Array<PlacedProject>;

    public function new(cli:CliTools, projects:Array<PlacedProject>) {
        this.cli = cli;
        this.projects = projects;
        for (project in projects) adjustWorkingDirectories(project, project.directory);
    }

    function adjustWorkingDirectories(project:PlacedProject, baseDir:String) {
        inline function adjustDir(baseDir:String, hxml:Hxml) {
            if (hxml == null) return;
            hxml.workingDirectory = baseDir; // TODO: fix this if you need cwd support... :P
                /*if (hxml.workingDirectory == null) baseDir;
                else hxml.workingDirectory = Path.join([baseDir, hxml.workingDirectory]);*/
        }

        for (target in project.targets) {
            var projectBaseDir = Path.join([baseDir, project.directory]);
            adjustDir(projectBaseDir, target.args);
            if (target.debug != null) adjustDir(projectBaseDir, target.debug.args);
            if (target.display != null) adjustDir(projectBaseDir, target.display.args);
            project.subProjects.map(adjustWorkingDirectories.bind(_, projectBaseDir));
        }
    }

    public function build(cliArgs:CliArguments) {}

    /** TODO: return Option<Haxelib> **/
    function resolveHaxelib(name:String):Haxelib {
        function loop(projects:Array<PlacedProject>):Haxelib {
            for (project in projects) {
                var lib = project.haxelibs.findNamed(name);
                if (lib != null) return lib;
                var libInSub = loop(project.subProjects);
                if (libInSub != null) return libInSub;
            }
            return null;
        }
        return loop(projects);
    }

    /** TODO: return Option<Target> **/
    function resolveTarget(name:String):Target {
        function loop(projects:Array<PlacedProject>):Target {
            for (project in projects) {
                var target = project.targets.findNamed(name);
                if (target != null) return target;
                var targetInSub = loop(project.subProjects);
                if (targetInSub != null) return targetInSub;
            }
            return null;
        }
        return loop(projects);
    }

    function resolveTargets(names:Array<String>):Array<Target> {
        return names.map(resolveTarget);
    }

    function resolveTargetHxml(target:Target, debug:Bool, flatten:Bool, display:Bool, recurse:Bool = true):Hxml {
        var hxmls:Array<Hxml> = [target.args];
        if (debug && target.debug != null) hxmls.push(target.debug.args);
        if (display && target.display != null) hxmls.push(target.display.args);

        if (recurse) {
            switch (resolveParent(target)) {
                case Some(parent):
                    hxmls.push(resolveTargetHxml(parent, debug, flatten, display, false));
                case None:
            }
        }

        if (flatten) {
            var dependencyHxmls = resolveTargets(target.targetDependencies.get()).map(resolveTargetHxml.bind(_, debug, flatten, display));
            hxmls = hxmls.concat(dependencyHxmls);
        }

        return mergeHxmls(hxmls, flatten);
    }

    function resolveParent(target:Target):Option<Target> {
        if (target.inherit != null) {
            return Some(resolveTarget(target.inherit));
        }
        return switch (getTargetOwner(target)) {
            case Some(project): Some(resolveTarget(project.inherit));
            case None: throw 'unable to find owner of target ${target.name}';
        }
    }

    function flattenProjects(project:PlacedProject):Array<PlacedProject> {
        var projects = [project];
        projects = projects.concat(project.subProjects.flatMap(flattenProjects));
        return projects;
    }

    function getTargetOwner(target:Target):Option<Project> {
        for (project in projects) {
            var flattened = flattenProjects(project);
            for (flattenedProject in flattened) {
                if (flattenedProject.targets.findNamed(target.name) != null)
                    return Some(project);
            }
        }
        return None;
    }

    function mergeHxmls(hxmls:Array<Hxml>, flatten:Bool):Hxml {
        var classPaths = [];
        var defines = [];
        var haxelibs = [];
        var debug = false;
        var output = null;
        var deadCodeElimination = null;
        var noInline = false;
        var main = null;
        var packageName = null;

        function merge(hxml:Hxml) {
            if (hxml == null) return;
            var rawClassPaths = hxml.classPaths.get();
            if (flatten) rawClassPaths = rawClassPaths.map(function(cp) return Path.join([hxml.workingDirectory, cp]));
            classPaths = classPaths.concat(rawClassPaths);
            defines = defines.concat(hxml.defines.get());
            haxelibs = haxelibs.concat(hxml.haxelibs.get());
            debug = debug || hxml.debug;
            if (hxml.output != null) output = hxml.output; // just use the most recent one I guess?
            if (hxml.deadCodeElimination != null) deadCodeElimination = hxml.deadCodeElimination;
            if (hxml.noInline == true) noInline = true;
            if (hxml.main != null) main = hxml.main;
            if (hxml.packageName != null) packageName = hxml.packageName;
        }

        for (hxml in hxmls) merge(hxml);

        return {
            workingDirectory: '',
            classPaths: classPaths,
            defines: defines,
            haxelibs: haxelibs,
            debug: debug,
            output: output,
            deadCodeElimination: deadCodeElimination,
            noInline: noInline,
            main: main,
            packageName: packageName
        };
    }
}