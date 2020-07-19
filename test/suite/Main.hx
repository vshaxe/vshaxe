import Vscode.*;
import js.lib.Promise;
import jsasync.IJSAsync;
import jsasync.JSAsyncTools.jsawait;
import sys.FileSystem;
import sys.io.File;
import vscode.TextDocument;

using jsasync.JSAsyncTools;

class Main implements IJSAsync {
	static final failures = [];

	static function workspacePath(name) {
		return workspace.workspaceFolders[0].uri.fsPath + "/" + name;
	}

	@:jsasync @:expose("run") static function run() {
		jsawait(runDiagnosticsTests());
		if (failures.length > 0) {
			throw failures;
		}
	}

	@:jsasync static function runDiagnosticsTests() {
		final casePath = workspacePath("../suite/cases/diagnostics");
		for (testCase in FileSystem.readDirectory(casePath)) {
			function caseFile(name) {
				return File.getContent(casePath + "/" + testCase + "/" + name);
			}
			final testFile = workspacePath("Test.hx");
			File.saveContent(testFile, caseFile("Before.hx"));

			final document:TextDocument = jsawait(workspace.openTextDocument(testFile));
			jsawait(window.showTextDocument(document));

			jsawait(commands.executeCommand("editor.action.marker.next"));
			jsawait(commands.executeCommand("editor.action.autoFix"));
			jsawait(wait(3));

			if (document.getText() != caseFile("After.hx")) {
				failures.push('Test case $testCase failed');
			}
		}
	}

	static function wait(seconds:Float):Promise<Void> {
		return new Promise(function(resolve, _) {
			haxe.Timer.delay(function() resolve(js.Lib.undefined), Std.int(seconds * 1000));
		});
	}
}
