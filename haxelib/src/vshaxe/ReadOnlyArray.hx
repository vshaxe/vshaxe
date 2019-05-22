package vshaxe;

/**
	An `Array` which cannot be modified.
**/
abstract ReadOnlyArray<T>(Array<T>) from Array<T> {
	@:op([]) function arrayAccess(i:Int)
		return this[i];

	/**
		Returns a `copy()` of the underlying array.
	**/
	public function get():Array<T> {
		return this.copy();
	}
}
