package vshaxe.helper;

import js.node.Buffer;
import js.node.ChildProcess;

function getProcessOutput(command:String):Array<String> {
	try {
		var oldCwd = Sys.getCwd();
		if (workspace.workspaceFolders != null) {
			Sys.setCwd(workspace.workspaceFolders[0].uri.fsPath);
		}
		var result:Buffer = ChildProcess.execSync(command);
		Sys.setCwd(oldCwd);
		var lines = result.toString().split("\n");
		return [for (line in lines) line.trim()];
	} catch (e) {
		return [];
	}
}
