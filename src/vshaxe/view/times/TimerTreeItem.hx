package vshaxe.view.times;

class TimerTreeItem extends TreeItem {
    final timer:Timer;
    final isRoot:Bool;
    final name:String;

    public final children:Array<TimerTreeItem>;
    public final method:String;

    public function new(timer:Timer, method:String, isRoot:Bool) {
        super("");
        this.timer = timer;
        this.isRoot = isRoot;
        this.method = method;

        name = formatName();
        label = formatLabel();
        tooltip = formatTooltip();
        id = '$method $name ${timer.info}';
        if (timer.children == null) {
            children = null;
            collapsibleState = None;
        } else {
            children = timer.children.map(TimerTreeItem.new.bind(_, method, false));
            collapsibleState = Expanded;
        }
    }

    function formatName():String {
        var name = if (isRoot) method else timer.name;
        if (timer.info != "") {
            name = '${timer.info}.$name';
        }
        return name;
    }

    function formatLabel():String {
        var seconds = truncate(timer.time, 5);
        var percent = truncate(timer.percentTotal, 4);
        var label = '$name - ${seconds}s';
        if (!isRoot) {
            label += ' ($percent%)';
        }
        return label;
    }

    function formatTooltip():String {
        var now = Date.now();
        var timestamp = '[${now.getHours()}:${now.getMinutes()}:${now.getSeconds()}]';
        return '$timestamp ${timer.calls} calls - ${truncate(timer.time, 7)}s';
    }

    function truncate(f:Float, precision:Int) {
        return Std.string(f).substr(0, precision);
    }
}
