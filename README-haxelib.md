# vshaxe

This is a library providing type definitions for the API of the [Haxe Visual Studio Code](https://marketplace.visualstudio.com/items?itemName=nadako.vshaxe) extension. The main focus is to allow for a smooth yet flexible integration with third-party build tools. To accomplish this, the API exposes the following functionality:

- Registration of new _completion providers_ that are then selectable via a dropdown menu in the status bar:

  ![](https://raw.githubusercontent.com/vshaxe/vshaxe/master/images/completionProviders.png)

  Completion providers provide vshaxe with a list of compiler arguments to be used for code completion, so the extension can pass them on to the [Haxe Language Server](https://github.com/vshaxe/haxe-languageserver).

- If an extension [contributes tasks](http://vshaxe.github.io/vscode-extern/VscodeWorkspace.html?#registerTaskProvider), the following information that is available through the API should be respected:
    - Whether the compilation server should be used and at which port it can be reached.
    - The configured path to the Haxe executable.
    - The list of problem matchers.
    - The presentation options.

Right now, the extension API is used by the following extensions:
  - [Lime](https://marketplace.visualstudio.com/items?itemName=openfl.lime-vscode-extension)
  - [Kha](https://marketplace.visualstudio.com/items?itemName=kodetech.kha)
  - [VSHaxe-Build](https://github.com/vshaxe/vshaxe-build/tree/master/src/vshaxeBuild/extension)

## Usage

The entry point for interaction with the extension is `Vshaxe`. The `Vshaxe` instance can be retrieved like this:

```haxe
var vshaxe:Vshaxe = Vscode.extensions.getExtension("nadako.vshaxe").exports;
```
