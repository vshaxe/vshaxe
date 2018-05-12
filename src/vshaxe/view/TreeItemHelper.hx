package vshaxe.view;

class TreeItemHelper {
    public static function collapse(item:TreeItem) {
        if (item.collapsibleState != None) {
            item.collapsibleState = Collapsed;
        }
    }

    public static function toggleState(item:TreeItem) {
        item.collapsibleState = if (item.collapsibleState == Collapsed) Expanded else Collapsed;
    }
}