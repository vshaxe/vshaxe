### ?.?.? (to be released)

**New Features**:

- allow generation of anonymous functions in signature completion
- added a `"haxe.codeGeneration"` setting
- added an "Extract variable" code action

**Bugfixes**:

- fixed regex highlighting in the upcoming VSCode 1.9.0
- fixed highlighting of constructor references (`Class.new`)
- fixed highlighting of package names with underscores
- fixed indentation when writing a comment after `}` ([#83](https://github.com/vshaxe/vshaxe/issues/83))

### 1.2.0 (January 23, 2017)

**Bugfixes**:

- fixed highlighting of variables and single quoted strings in the upcoming VSCode 1.9.0
- fixed highlighting of identifiers starting with `var` / `function` ([#76](https://github.com/vshaxe/vshaxe/issues/76))
- fixed unfinished `package`/`import`/`using` statements breaking subsequent highlighting
- fixed modifiers not being highlighted everywhere (e.g. `extends` in class reification)
- fixed highlighting of metadata and const values in typedef type parameters
- fixed highlighting of method declarations with type parameters
- fixed invalid `settings.json` being generated with only one `.hxml` file ([#47](https://github.com/vshaxe/vshaxe/issues/47))
- fixed highlighting of conditionals with nested braces
- fixed quick fix saying "Remove import" for usings ([#32](https://github.com/vshaxe/vshaxe/issues/32))
- fixed comments and conditionals not being highlighted everywhere ([#50](https://github.com/vshaxe/vshaxe/issues/50))
- fixed leading dots in `Float` literals not being highlighted (e.g. in `.52`)
- fixed type names with leading underscores not being highlighted as such

**Changes and improvements**:

- improved highlighting for macro reification
- improved highlighting for metadata
- improved highlighting for enums
- accessor methods in property declarations are now highlighted (`get_property`, `set_property`)
- `UPPER_CASE` identifiers are now highlighted as variables instead of class names
- conditionals are now highlighted in a much more distinguishable gray-ish color
- `--macro` and `-main` arguments are now highlighted as Haxe code in `.hxml` files
- the `is` operator is now highlighted as a keyword ([#29](https://github.com/vshaxe/vshaxe/issues/29))
- untyped functions like `__js__` are now highlighted as keywords ([#25](https://github.com/vshaxe/vshaxe/issues/25))
- `...` in `IntIterator` literals is now highlighted as an operator
- `:` in type hints is now highlighted as an operator
- `?` in ternaries is now highlighted as an operator
- names of toplevel types are now colored differently in some themes (e.g. Monokai)
- parameter names are now highlighted differently in some themes (e.g. Monokai)

### 1.1.1 (January 17, 2017)

**Bugfixes**:

- fixed a highlighting-related crash when typing `static` before a field

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