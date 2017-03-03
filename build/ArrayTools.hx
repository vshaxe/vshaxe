package;

class ArrayTools {
    public static function safeCopy<T>(a:Array<T>):Array<T> {
        return if (a == null) [] else a.copy();
    }
}
