package;

class ArrayTools {
    public static function safeCopy<T>(a:Array<T>):Array<T> {
        return if (a == null) [] else a.copy();
    }

    public static function filterDuplicates<T>(tasks:Array<T>, filter:T->T->Bool):Array<T> {
        var uniqueTasks:Array<T> = [];
        for (task in tasks) {
            var present = false;
            for (unique in uniqueTasks) if (filter(unique, task))
                present = true;
            if (!present)
                uniqueTasks.push(task);
        }
        return uniqueTasks;
    }

    public static function getHaxelib(libs:ArrayHandle<Haxelib>, name:String):Haxelib {
        for (lib in libs)
            if (lib.name == name)
                return lib;
        return null;
    }

    public static function getTarget(targets:ArrayHandle<TargetArguments>, name:String):TargetArguments {
        for (target in targets)
            if (target.name == name)
                return target;
        return null;
    }

    /** from https://github.com/fponticelli/thx.core/blob/master/src/thx/Arrays.hx **/

    inline public static function flatMap<TIn, TOut>(array:Array<TIn>, callback:TIn->Array<TOut>):Array<TOut>
        return flatten(array.map(callback));

    public static function flatten<T>(array:Array<Array<T>>):Array<T>
        return reduce(array, function(acc:Array<T>, element) return acc.concat(element), []);

    public static function reduce<A, B>(array:Array<A>, f:B->A->B, initial:B):B {
        for (v in array)
            initial = f(initial, v);
        return initial;
    }
}
