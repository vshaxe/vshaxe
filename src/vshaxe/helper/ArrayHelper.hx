package vshaxe.helper;

class ArrayHelper {
	public static function equals<T>(a1:Array<T>, a2:Array<T>):Bool {
		if (a1 == null && a2 == null)
			return true;
		if (a1 == null && a2 != null)
			return false;
		if (a1 != null && a2 == null)
			return false;
		if (a1.length != a2.length)
			return false;
		for (i in 0...a1.length)
			if (a1[i] != a2[i])
				return false;
		return true;
	}

	public static function moveToStart<T>(array:Array<T>, f:T->Bool) {
		var element = array.find(f);
		if (element != null) {
			array.remove(element);
			array.unshift(element);
		}
	}
}
