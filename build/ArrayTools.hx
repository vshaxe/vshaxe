package;

class ArrayTools {
    public static function safeCopy<T>(a:Array<T>):Array<T> {
        return if (a == null) [] else a.copy();
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
