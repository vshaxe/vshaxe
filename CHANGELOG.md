### 1.9.1 (to be released)

**Bugfixes**:

- fixed the dependency explorer for local haxelib repos ([#162](https://github.com/vshaxe/vshaxe/issues/162))

### 1.9.0 (July 21, 2017)

**New Features**:

- added a `"haxe.executable"` setting
- added a task provider for top-level HXML files
- added support for using top-level HXML files as display configurations
- added an extension API enabling Haxe build tools to provide completion ([#18](https://github.com/vshaxe/vshaxe/issues/18))
- added a `Select Completion Provider` command

**Bugfixes**:

- fixed the dependency explorer for `haxelib dev` libs in the haxelib repo ([#141](https://github.com/vshaxe/vshaxe/issues/141))
- fixed the dependency explorer with a relative `"haxe.executable"` path ([#58](https://github.com/vshaxe/vshaxe/issues/58))
- fixed the dependency explorer with invalid classpaths
- fixed a minor anon function highlighting issue ([haxe-tmLanguage#31](https://github.com/vshaxe/haxe-tmLanguage/issues/31))
- fixed renaming `expr` in `case macro $expr:` ([#142](https://github.com/vshaxe/vshaxe/issues/142))
- fixed a regression with duplicated Haxe output channels ([#87](https://github.com/vshaxe/vshaxe/issues/87))
- fixed line break handling in completion docs ([#150](https://github.com/vshaxe/vshaxe/issues/150))

**Changes and improvements**:

- changed the required VSCode version to 1.14.0
- changed dependency explorer selection to open files permanently on double-click
- added support for `@event` JavaDoc tags in highlighting and completion
- reduced Haxe server restarts to changes of relevant settings ([#153](https://github.com/vshaxe/vshaxe/issues/153))
- greatly simplified the `Initialize VS Code Project` command
- deprecated `"haxe.displayServer"`'s `"haxePath"` / `"env"` in favor of `"haxe.executable"`

### 1.8.0 (June 28, 2017)

**New Features**:

- added a "Haxe Dependencies" view to the explorer
- added support for renaming local variables and parameters ([haxe-languageserver#32](https://github.com/vshaxe/haxe-languageserver/issues/32))

**Bugfixes**:

- fixed a minor string interpolation highlighting issue ([haxe-tmLanguage#27](https://github.com/vshaxe/haxe-tmLanguage/issues/27))
- fixed catch variables not being listed in document symbols
- fixed diagnostics of deleted / renamed files not being removed ([#132](https://github.com/vshaxe/vshaxe/issues/132))

**Changes and improvements**:

- changed the required VSCode version to 1.13.0
- allowed filtering by path in the display configuration picker
- init project command: replaced `-js` with `--interp` ([#124](https://github.com/vshaxe/vshaxe/issues/124))
- adjusted column index handling to support changes in Haxe 4 ([#134](https://github.com/vshaxe/vshaxe/issues/134))

### 1.7.0 (May 24, 2017)

**Bugfixes**:

- fixed Unicode character handling for completion with Haxe 4
- fixed filtering in metadata completion ([#121](https://github.com/vshaxe/vshaxe/issues/121))

**Changes and improvements**:

- changed the required VSCode version to 1.12.0
- added a progress indicator for Completion Cache Initialization (#108)
- added a progress indicator for Global Diagnostics Checks
- made document symbols much more robust ([haxe-languageserver#31](https://github.com/vshaxe/haxe-languageserver/issues/31))

### 1.6.0 (May 13, 2017)

**New Features**:

- added highlighting support for Haxe 4 arrow functions ([HXP-0002](https://github.com/HaxeFoundation/haxe-evolution/blob/master/proposals/0002-arrow-functions.md))
- added a `useArrowSyntax` option for anonymous function generation
- added a "Generate capture variables" code action

**Bugfixes**:

- fixed several small highlighting issues (haxe-tmLanguage[[#4](https://github.com/vshaxe/haxe-tmLanguage/issues/4), [#6](https://github.com/vshaxe/haxe-tmLanguage/issues/6), [#11](https://github.com/vshaxe/haxe-tmLanguage/issues/11), [#16](https://github.com/vshaxe/haxe-tmLanguage/issues/16), [#22](https://github.com/vshaxe/haxe-tmLanguage/issues/22)])

### 1.5.1 (April 21, 2017)

**Bugfixes**:

- fixed toplevel completion hanging in some cases ([haxe-languageserver#23](https://github.com/vshaxe/haxe-languageserver/pull/23#issuecomment-295468634))

### 1.5.0 (April 7, 2017)

**New Features**:

- added a Haxe problem matcher (referenced with `"problemMatcher": "$haxe"`, VSCode 1.11.0+)

**Changes and improvements**:

- use the Haxe problem matcher in "Init Project"

**Bugfixes**:

- fixed support for Haxe 4+ (development branch)

### 1.4.0 (International Women's Day, 2017)

**New Features**:

- added a `Toggle Code Lens` command ([#94](https://github.com/vshaxe/vshaxe/issues/94))

**Bugfixes**:

- fixed several small highlighting issues (haxe-tmLanguage[[#2](https://github.com/vshaxe/haxe-tmLanguage/issues/2), [#5](https://github.com/vshaxe/haxe-tmLanguage/issues/5), [#8](https://github.com/vshaxe/haxe-tmLanguage/issues/8), [#14](https://github.com/vshaxe/haxe-tmLanguage/issues/14), [#15](https://github.com/vshaxe/haxe-tmLanguage/issues/15), [#17](https://github.com/vshaxe/haxe-tmLanguage/issues/17)])
- fixed signature help sometimes not having argument names ([haxe#6064](https://github.com/HaxeFoundation/haxe/issues/6064))
- fixed argument name generation with anon structure types

**Changes and improvements**:

- diagnostics now update when the active editor is changed
- init project command: `.hxml` files in local haxelib repos are now ignored ([#93](https://github.com/vshaxe/vshaxe/issues/93))
- init project command: moved the comments in the generated `settings.json` to `README.md`
- init project command: added `-D analyzer-optimize` to the generated `build.hxml`
- init project command: a quick pick selection is no longer required with only one `.hxml` file
- init project command: use `version` 2.0.0 in `tasks.json` (VSCode 1.10.0)
- still attempt display requests without any `displayConfigurations` ([#105](https://github.com/vshaxe/vshaxe/issues/105))

### 1.3.3 (February 16, 2017)

**Bugfixes**:

- fixed diagnostics always being filtered if `diagnosticsPathFilter` is set

### 1.3.2 (February 14, 2017)

**Bugfixes**:

- properly handle cancelled requests in the language server (so dead requests don't pile up inside VS Code)

**Changes and improvements**:

- no longer request diagnostics if `diagnosticsPathFilter` doesn't match

### 1.3.1 (February 9, 2017)

**Bugfixes**:

- fixed invalid argument name generation with type parameters ([haxe-languageserver#28](https://github.com/vshaxe/haxe-languageserver/issues/28))
- fixed inconsistent icon usage in field and toplevel completion
- fixed diagnostics sometimes being reported for the wrong file

**Changes and improvements**:

- smarter error handling ([#20](https://github.com/vshaxe/vshaxe/issues/20), [haxe-languageserver#20](https://github.com/vshaxe/haxe-languageserver/issues/20))
- ignore hidden files in the "init project" command ([#10](https://github.com/vshaxe/vshaxe/issues/10))
- some minor highlighting improvements ([haxe-tmLanguage#10](https://github.com/vshaxe/haxe-tmLanguage/issues/10))
- added a quick fix for "invalid package" diagnostics
- leading `*` characters are now removed from signature help docs

### 1.3.0 (February 2, 2017)

**New Features**:

- allow generation of anonymous functions in signature completion
- added a `"haxe.codeGeneration"` setting

**Bugfixes**:

- fixed regex highlighting in VSCode 1.9.0
- fixed highlighting of constructor references (`Class.new`)
- fixed highlighting of package names with underscores
- fixed highlighting of comments after conditionals ([haxe-tmLanguage#1](https://github.com/vshaxe/haxe-tmLanguage/issues/1))
- fixed indentation when writing a comment after `}` ([#83](https://github.com/vshaxe/vshaxe/issues/83))
- fixed display requests being attempted with no display config
- fixed toplevel completion with whitespace after `:` ([haxe-languageserver#22](https://github.com/vshaxe/haxe-languageserver/issues/22))
- fixed some compiler errors not being highlighted by diagnostics ([#62](https://github.com/vshaxe/vshaxe/issues/62))

**Changes and improvements**:

- improved handling of Haxe crashes, e.g. with invalid arguments ([haxe-languageserver#20](https://github.com/vshaxe/haxe-languageserver/issues/20))
- support auto closing and surrounding brackets in hxml files (for `--macro` arguments)

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
