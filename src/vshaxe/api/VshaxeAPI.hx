package vshaxe.api;

import Vscode.*;
import vscode.*;

@:allow(vshaxe)
@:keep

class VshaxeAPI {
    private var currentDisposable:Disposable;
    private var currentProvider:DisplayArgumentProvider;
    private var displayArguments:String;
    private var serverReady:Bool;

    private function new() {

    }

    /**
     * Register a display argument provider.
     *
     * Display arguments are passed to the Haxe Language Server for completion and used for the dependency explorer.
     *
     * An extension should only register a provider if it handles the current workspace's project type
     * (usually when a matching project file is present, e.g. a `project.xml` in Lime's case).
     * In the case of two competing providers, the user is prompted to select between them.
     *
     * @param name A unique ID to identify the extension. Shown to the user for conflict resolution.
     * @param provider A display argument provider.
     * @return A disposable which unregisters the provider.
     */
    public function registerDisplayArgumentProvider(name:String, provider:DisplayArgumentProvider):Disposable {
        // TODO: Handle multiple providers
        if (currentProvider == provider) return currentDisposable;
        if (currentProvider != null && currentProvider != provider) {
            currentProvider.deactivate();
        }
        currentProvider = provider;
        provider.activate(updateDisplayArguments);
        currentDisposable = new Disposable(function() {
            if (provider == currentProvider) {
                provider.deactivate();
            }
        });
        return currentDisposable;
    }

    private function updateDisplayArguments(arguments:String):Void {
        displayArguments = arguments;
        if (serverReady && displayArguments != null) {
            Main.instance.server.updateDisplayArguments(displayArguments);
        }
    }

    private function onReady():Void {
        serverReady = true;
        updateDisplayArguments(displayArguments);
    }
}