package vshaxe.view.times;

class TimerTreeItem extends TreeItem {
    public final children:Array<TimerTreeItem>;

    public function new(timer:Timer, children:Array<TimerTreeItem>, ?method:String) {
        super(formatTitle(timer, children, method), if (children == null) None else Expanded);
        this.children = children;
        tooltip = '${timer.calls} calls';
    }

    function formatTitle(timer:Timer, children:Array<TimerTreeItem>, ?method:String) {
        var name = if (timer.name == "") method else timer.name;
        if (timer.info != "") {
            name = '${timer.info}.$name';
        }
        var seconds = truncate(timer.time);
        var percent = truncate(timer.percentTotal);
        return '$name - ${seconds}s ($percent%)';
    }

    function truncate(f:Float) {
        return Std.string(f).substr(0, 4);
    }
}
