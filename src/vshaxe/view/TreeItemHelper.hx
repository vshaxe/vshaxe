package vshaxe.view;

class TreeItemHelper {
    public static function collapse(item:TreeItem) {
        if (item.collapsibleState != None) {
            item.collapsibleState = Collapsed;
        }
    }
}