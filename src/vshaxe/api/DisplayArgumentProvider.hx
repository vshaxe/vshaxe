package vshaxe.api;

typedef DisplayArgumentProvider = {

    /**
     * Called when vshaxe selects the provider for providing completion.
     *
     * @param provideArguments A callback that should be cached by the provider, and called whenever display arguments change.
     *        The callback's `String` argument is assumed to be formatted like a HXML file and will be parsed by vshaxe.
     *        `provideArguments` should only be called when necessary.
     */
    public function activate(provideArguments:String->Void):Void;

    /**
     * Called when this display argument provider is no longer active, for instance because the user has chosen to use
     * another provider. The provider is informed about this to stop unnecessary system calls if deactivated.
     *
     * *Note:* a deactivated provider can be activated again!
     */
    public function deactivate():Void;

}