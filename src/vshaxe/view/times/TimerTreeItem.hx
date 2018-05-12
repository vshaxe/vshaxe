package vshaxe.view.times;

class TimerTreeItem extends TreeItem {
    public final children:Array<TimerTreeItem>;

    public function new(timer:Timer, children:Array<TimerTreeItem>, ?method:String) {
        super(formatLabel(timer, children, method), if (children == null) None else Expanded);
        this.children = children;
        tooltip = '${timer.calls} calls';
    }

    function formatLabel(timer:Timer, children:Array<TimerTreeItem>, ?method:String) {
        var isRoot = method != null;
        var name = if (isRoot) method else timer.name;
        if (timer.info != "") {
            name = '${timer.info}.$name';
        }
        var seconds = truncate(timer.time, 5);
        var percent = truncate(timer.percentTotal, 4);
        var label = '$name - ${seconds}s';
        if (!isRoot) {
            label += ' ($percent%)';
        }
        return label;
    }

    function truncate(f:Float, precision:Int) {
        return Std.string(f).substr(0, precision);
    }
}
