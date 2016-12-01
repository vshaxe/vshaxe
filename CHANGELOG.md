### 1.0.0 (December 1, 2016)

**New Features**:

- added a `Run Global Diagnostics Check` command
- added support for Code Lens (needs to be enabled with `"haxe.enableCodeLens"`)
- added support for Workspace Symbols (`Ctrl+T`)
- added a `"haxe.diagnosticsPathFilter"` setting (and limit diagnostics to the workspace by default)
- added support for some "This code has no effect" diagnostics (and a "Remove" code action)
- added "Import" and "Change to" code actions ([haxe-languageserver#13](https://github.com/vshaxe/haxe-languageserver/issues/13))
- added a "Remove all unused imports/usings" code action
- added support for compiler metadata completion (after `@:`)
- added support for type hint completion (after `:`)
- added support for anonymous struct completion (after `method({`)
- added support for `--times` in field and toplevel completion
- added JavaDoc parsing for formatting in Hover Hints
- utilize a completion cache to speed up completion significantly
- added a `"haxe.buildCompletionCache"` setting (`true` by default)
- added a `"haxe.displayPort"` setting for use with `--connect` / to build through the display server

**Bugfixes:**

- fixed keyboard focus being stolen by the Haxe output channel sometimes
- fixed display config dropdown in the status bar not showing right away ([#37](https://github.com/vshaxe/vshaxe/issues/37))

**Changes and improvements**:

- improved code highlighting
- improved handling of unsupported Haxe versions ([#16](https://github.com/vshaxe/vshaxe/issues/16))