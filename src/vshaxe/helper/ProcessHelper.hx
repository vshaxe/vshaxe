package vshaxe.helper;

import js.node.Buffer;
import js.node.ChildProcess;

function getProcessOutput(command:String):Array<String> {
	return try {
		final oldCwd = Sys.getCwd();
		if (workspace.workspaceFolders != null) {
			Sys.setCwd(workspace.workspaceFolders[0].uri.fsPath);
		}
		final result:Buffer = ChildProcess.execSync(command);
		Sys.setCwd(oldCwd);
		final lines = result.toString().split("\n");
		[for (line in lines) line.trim()];
	} catch (e) {
		[];
	}
}
