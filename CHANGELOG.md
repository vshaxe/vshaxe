### 1.1.0 (January 12, 2017)

**New Features**:

- added proper highlighting for string interpolation ([#26](https://github.com/vshaxe/vshaxe/issues/26))
- added proper highlighting for regex literals
- added proper highlighting for identifiers (method and variable names)
- added highlighting for JavaDoc-tags in block comments (`@param`, `@return` etc)

**Bugfixes**:

- fixed diagnostics not working if project path contains a `'` ([#64](https://github.com/vshaxe/vshaxe/issues/64))
- fixed the import insert position with file header comments ([haxe-languageserver#27](https://github.com/vshaxe/haxe-languageserver/issues/27))
- `$type` is now highlighted as a keyword
- `in` in `for`-loops is now highlighted as a keyword
- fixed `*` in imports being highlighted as a class name
- fixed highlighting for negated conditionals (e.g. `#if !js`)
- fixed highlighting of variable initialization expressions ([#42](https://github.com/vshaxe/vshaxe/issues/42))

### 1.0.1 (December 6, 2016)

**Bugfixes**:

- fixed parsing types of methods with 10+ arguments ([haxe-languageserver#26](https://github.com/vshaxe/haxe-languageserver/issues/26))

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