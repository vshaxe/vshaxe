package vshaxe.view;

class TreeItemHelper {
	public static function collapse(item:TreeItem) {
		if (item.collapsibleState != None) {
			item.collapsibleState = Collapsed;
			item.refreshHack();
		}
	}

	// ugly workaround for https://github.com/Microsoft/vscode/issues/30918
	private static function refreshHack(item:TreeItem) {
		function addOrRemoveSpace(s:String):String {
			return if (s.endsWith(" ")) s.rtrim() else s + " ";
		}
		if (item.id != null) {
			item.id = addOrRemoveSpace(item.id);
		} else {
			item.label = addOrRemoveSpace(item.label);
		}
	}
}
