package vshaxe.configuration;

import sys.FileSystem;
import vshaxe.helper.PathHelper;

class ExecutableHelper {
	public static function resolve(folder:Uri, path:String, name:String):String {
		if (path != "auto") {
			return path;
		}
		/* var nodeModulesPath = switch Sys.systemName() {
				case "Windows": 'node_modules\\.bin\\$name.cmd';
				default: 'node_modules/.bin/$name';
			}
			return if (FileSystem.exists(PathHelper.absolutize(nodeModulesPath, folder.fsPath))) {
				nodeModulesPath; // local Haxe installation from Lix or npm-haxe
			} else {
				name; // executable from PATH
		}*/
		return name;
	}
}
