### 2.4.1 (to be released)

**Changes and Improvements**:

- updated to haxe-formatter version 1.1.0
- allowed auto-closing of brackets in single quote strings ([#123](https://github.com/vshaxe/vshaxe/issues/123))
- added syntax highlighting support for `final class` / `interface` ([haxe#7381](https://github.com/HaxeFoundation/haxe/pull/7381))

### 2.4.0 (August 23, 2018)

**New Features**:

- added support for code formatting (using [haxe-formatter](https://github.com/HaxeCheckstyle/haxe-formatter))

**Bugfixes**:

- fixed highlighting of macro patterns

**Changes and Improvements**:

- improved document symbol ranges to include doc comments

### 2.3.0 (July 31, 2018)

**New Features**:

- added support for removing unused imports with [`"editor.codeActionsOnSave"`](https://code.visualstudio.com/updates/v1_23#_run-code-actions-on-save)
- added support for triggering quick fixes from the problems view [in VSCode 1.26](https://github.com/Microsoft/vscode/issues/52627#issuecomment-405254755)
- added a folding marker for the imports / usings section in a module
- added folding markers for `#if` / `#else` / `#elseif` conditionals ([#36](https://github.com/vshaxe/vshaxe/issues/36))
- added folding markers for multi-line string and array literals

**Bugfixes**:

- fixed static import completion with Haxe 4.0.0-preview.4 ([#265](https://github.com/vshaxe/vshaxe/issues/265))
- fixed document symbol ranges in files with Unicode characters

**Changes and Improvements**:

- improved folding of block comments (the final `**/` is now hidden too)
- improved completion and document symbols to ignore locals named `_`
- improved completion in nested patterns (requires [haxe#7287](https://github.com/HaxeFoundation/haxe/issues/7287))
- auto-trigger signature help in patterns (requires [haxe#7326](https://github.com/HaxeFoundation/haxe/issues/7326))

### 2.2.1 (July 21, 2018)

**Bugfixes**:

- fixed `Restart Language Sever` duplicating document symbols
- fixed document symbols not using the operator icon in abstracts

### 2.2.0 (July 20, 2018)

**New Features**:

- added hierarchy support to document symbols for the outline view ([#223](https://github.com/vshaxe/vshaxe/issues/223))

**Bugfixes**:

- fixed several issues related to display argument provider initialization ([#235](https://github.com/vshaxe/vshaxe/issues/235))

**Changes and Improvements**:

- improved document symbols to work with conditional compilation
- improved document symbols to support Haxe 4 syntax (`enum abstract`, `final`...)
- removed arguments and type parameters from document symbols
- show a warning in case there's an error during "Building Cache..."

### 2.1.0 (July 12, 2018)

**New Features**:

- added support for fading out unused code
- added `"explorer.autoReveal"` support to the dependency explorer ([#152](https://github.com/vshaxe/vshaxe/issues/152))
- added `"print"` options to the `"haxe.displayServer"` setting ([#240](https://github.com/vshaxe/vshaxe/issues/240))
- added a `"haxe.exclude"` setting to allow hiding dot paths from completion ([#234](https://github.com/vshaxe/vshaxe/issues/234))
- added a request queue visualization to the Haxe Methods view ([#241](https://github.com/vshaxe/vshaxe/issues/241))
- added a `Debug Selected Configuration` command ([#236](https://github.com/vshaxe/vshaxe/issues/236))
- added support for "Go to Type Definition" (requires [haxe#7266](https://github.com/HaxeFoundation/haxe/pull/7266))

**Bugfixes**:

- fixed auto-imports in override generation being duplicated ([#257](https://github.com/vshaxe/vshaxe/issues/257))
- fixed compilation through the server for HXML files with `--next` ([#262](https://github.com/vshaxe/vshaxe/issues/262))
- fixed a crash in the dependency explorer when `haxelib` isn't available ([#249](https://github.com/vshaxe/vshaxe/issues/249))
- fixed opening/closing folders in the dependency explorer not working properly
- fixed libraries in the dependency explorer being listed twice in rare cases ([#263](https://github.com/vshaxe/vshaxe/issues/263))
- fixed types in completion sometimes being sorted counter-intuitively

**Changes and Improvements**:

- changed the required VSCode version to 1.25.0
- improved completion to allow selecting metadata by typing `(`
- improved completion to show the dot path for imported types as well
- improved expected type completion to work with `haxe.extern.EitherType` ([#256](https://github.com/vshaxe/vshaxe/issues/256))
- improved the init project command to work without a workspace folder ([#225](https://github.com/vshaxe/vshaxe/issues/225))
- improved the Haxe Methods view to auto-select the most recently run method
- improved hover formatting to have a separator between definition and docs
- support the new `showReuseMessage` option in `"haxe.taskPresentation"`
- monomorphs in function args and returns are no longer printed ([#244](https://github.com/vshaxe/vshaxe/issues/244))
- changed the `haxe: active configuration` task to only require one config ([#230](https://github.com/vshaxe/vshaxe/issues/230))

### 2.0.1 (June 12, 2018)

**Bugfixes**:

- fixed disabling of auto-imports in `"haxe.codeGeneration"` settings

### 2.0.0 (June 12, 2018)

_The following features, fixes and improvements **require Haxe 4.0.0-preview.4:**_

**New Features**:

- added support for auto-imports in completion ([#2](https://github.com/vshaxe/vshaxe/issues/2#issuecomment-386898358))
- added structure field completion ([#110](https://github.com/vshaxe/vshaxe/issues/110))
- added keywords to completion ([#148](https://github.com/vshaxe/vshaxe/issues/148))
- added `for`, `if`, `int` and `switch` postfix completion
- added "expected type completion" (to generate object literals and anon functions)
- added the origin of locals and fields to completion details and hover
- added support for override generation on `override |` ([#92](https://github.com/vshaxe/vshaxe/issues/92))
- added support for goto definition on `override` ([haxe#5718](https://github.com/HaxeFoundation/haxe/issues/5718))
- added a "Haxe Methods" tree view to visualize `--times` output
- added a `"haxe.enableMethodsView"` setting (`false` by default)
- added `"imports"` settings to `"haxe.codeGeneration"`
- added `"functions.field"` settings to `"haxe.codeGeneration"`
- added syntax highlighting support for intersection types ([HXP-0004](https://github.com/HaxeFoundation/haxe-evolution/blob/master/proposals/0004-intersection-types.md))
- added syntax highlighting support for qualified metadata ([haxe#3959](https://github.com/HaxeFoundation/haxe/issues/3959))
- added syntax highlighting support for `var ?x:Int` syntax ([haxe#6707](https://github.com/HaxeFoundation/haxe/issues/6707))
- added support for Haxe 4 style CLI arguments ([haxe#6862](https://github.com/HaxeFoundation/haxe/pull/6862))

**Bugfixes**:

- fixed all cases of completion being triggered after `:` on a `case` ([#112](https://github.com/vshaxe/vshaxe/issues/112))
- fixed inconsistent presentation of function types in hover ([#144](https://github.com/vshaxe/vshaxe/issues/144))
- fixed signature help not closing when moving outside of the brackets ([#216](https://github.com/vshaxe/vshaxe/issues/216))
- fixed import code actions not working in some places ([haxe](https://github.com/HaxeFoundation/haxe)[[#5950](https://github.com/HaxeFoundation/haxe/issues/5950), [#5951](https://github.com/HaxeFoundation/haxe/issues/5951)])
- fixed function generation not working with aliased function types ([#103](https://github.com/vshaxe/vshaxe/issues/103))

**Changes and Improvements**:

- improved workspace symbols performance / avoid hangs on open ([haxe#7056](https://github.com/HaxeFoundation/haxe/issues/7056))
- improved find references to include results from modules that are not compiled ([#96](https://github.com/vshaxe/vshaxe/issues/96))
- improved completion to show results with the expected type first ([haxe#6750](https://github.com/HaxeFoundation/haxe/issues/6750))
- improved completion to filter results after `implements`, `extends`, `>` and `new` ([haxe#7029](https://github.com/HaxeFoundation/haxe/issues/7029))
- improved completion by sorting variables by distance ([haxe#7069](https://github.com/HaxeFoundation/haxe/issues/7069))
- improved completion to make use of more different / accurate icons
- improved completion to auto-insert tokens where it makes sense
- improved completion to auto-insert enum constructor arguments in patterns
- improved completion to allow selecting functions by typing `(`
- improved completion performance by using VSCode's file watcher for cache invalidation
- improved syntax highlighting for imports (wildcard imports, static imports...)
- hover hints and completion now include default values ([haxe](https://github.com/HaxeFoundation/haxe)[[#5538](https://github.com/HaxeFoundation/haxe/issues/5538#issuecomment-395483219), [#7147](https://github.com/HaxeFoundation/haxe/issues/7147)])
- hover hints and completion now show the full declaration for fields and locals
- removed dot paths from imported types in hover hints and completion
- removed support for generating functions with a code action (now uses regular completion)

____
_These changes work with any Haxe version vshaxe is compatible with:_

**New Features**:

- added a `"haxe.enableSignatureHelpDocumentation"` setting ([#197](https://github.com/vshaxe/vshaxe/issues/197))
- added Haxe and HXML highlighting in fenced markdown code blocks

**Bugfixes**:

- fixed several small highlighting issues ([haxe-TmLanguage](https://github.com/vshaxe/haxe-TmLanguage)[[#40](https://github.com/vshaxe/haxe-TmLanguage/issues/40), [#41](https://github.com/vshaxe/haxe-TmLanguage/issues/41)])
- fixed files sometimes being opened twice with different cases on Windows
- fixed the treatment of missing properties in `"haxe.codeGeneration"`

**Changes and Improvements**:

- improved completion to trigger automatically after certain keywords (e.g. `import`)
- changed hover hints to use Haxe 4's new function type syntax ([HXP-0003](https://github.com/HaxeFoundation/haxe-evolution/blob/master/proposals/0003-new-function-type.md))

### 1.12.0 (May 3, 2018)

**New Features**:

- added a `haxe: active configuration` task if there's at least two configurations
- added the ability to specify labels for items in `"haxe.displayConfigurations"`
- added a `haxeCompletionProivder` context key (can be used in [keyboard shortcuts](https://code.visualstudio.com/docs/getstarted/keybindings#_when-clause-contexts))

**Bugfixes**:

- fixed some dependencies missing from the dependency explorer
- fixed compilation server socket not listening on `localhost` ([lime-vscode-extension#35](https://github.com/openfl/lime-vscode-extension/issues/35))
- fixed some issues with argument name generation
- fixed missing diagnostics for Haxe errors without positions ([#220](https://github.com/vshaxe/vshaxe/issues/220))
- fixed "initializing completion" not being removed on language server crashes
- fixed const type param regex literals not being highlighted ([haxe-TmLanguage#37](https://github.com/vshaxe/haxe-TmLanguage/issues/37))
- fixed language server not exiting properly in some cases ([haxe-languageserver#34](https://github.com/vshaxe/haxe-languageserver/pull/34))

**Changes and Improvements**:

- added syntax highlighting support for `enum abstract` ([haxe#6982](https://github.com/HaxeFoundation/haxe/issues/6982))
- removed packages from function declarations in hover hints for better readability
- renamed `std` to `haxe` in the dependency explorer

### 1.11.0 (April 9, 2018)

**New Features**:

- added a `$haxe-absolute` problem matcher for errors with absolute paths ([#23](https://github.com/vshaxe/vshaxe/issues/23))
- added a `$haxe-error` problem matcher to add Haxe errors without positions to Problems ([#214](https://github.com/vshaxe/vshaxe/issues/214))
- added a `$haxe-trace` problem matcher to add traces to Problems ([#139](https://github.com/vshaxe/vshaxe/issues/139))
- added a `"haxe.taskPresentation"` setting ([#185](https://github.com/vshaxe/vshaxe/issues/185))
- added `problemMatchers` and `taskPresentation` to the extension API

**Bugfixes**:

- fixed rename errors not being shown in VSCode ([#213](https://github.com/vshaxe/vshaxe/issues/213))
- fixed some issues that could lead to hangs when compiling through the server
- fixed broken highlighting with functions in enum constructor calls ([haxe-TmLanguage#36](https://github.com/vshaxe/haxe-TmLanguage/issues/36))
- fixed most cases of completion being triggered after `case` / `default` ([#112](https://github.com/vshaxe/vshaxe/issues/112))

**Changes and Improvements**:

- improved highlighting of escape sequences in strings ([haxe-TmLanguage#35](https://github.com/vshaxe/haxe-TmLanguage/issues/35))
- clarified the source of problems with `[tasks]` and `[diagnostics]` labels ([#132](https://github.com/vshaxe/vshaxe/issues/132))
- changed task generation to use the additional problem matchers

### 1.10.1 (April 4, 2018)

**Bugfixes**:

- don't include unused `vscode-textmate` in the vshaxe extension package

### 1.10.0 (April 4, 2018)

**New Features**:

- added support for file icon themes in the dependency explorer ([#146](https://github.com/vshaxe/vshaxe/issues/146))
- added a context menu to items in the dependency explorer
- added support for `"haxe.displayPort": "auto"` - enabled by default ([#191](https://github.com/vshaxe/vshaxe/issues/191))
- added a `"haxe.enableCompilationServer"` setting - enabled by default ([#184](https://github.com/vshaxe/vshaxe/issues/184))
- added support for markdown-formatted documentation in signature help
- added `displayPort` and `enableCompilationServer` to the extension API
- added highlighting for Haxe 4's new function type syntax ([HXP-0003](https://github.com/HaxeFoundation/haxe-evolution/blob/master/proposals/0003-new-function-type.md))
- added code folding support for different region marker styles ([#202](https://github.com/vshaxe/vshaxe/pull/202#issuecomment-376507302))

**Bugfixes**:

- fixed the dependency explorer's `std` version missing with Haxe 4
- fixed the dependency explorer's `std` version not updating on `"haxe.executable"` changes
- fixed the dependency explorer's "Collapse All" button ([#212](https://github.com/vshaxe/vshaxe/issues/212))
- fixed dependency explorer duplicating folders of some `haxelib dev` libs ([#156](https://github.com/vshaxe/vshaxe/issues/156))
- fixed highlighting of nested function types in parameters ([haxe-TmLanguage#29](https://github.com/vshaxe/haxe-TmLanguage/issues/29))
- fixed arrow functions being highlighted in strings ([haxe-TmLanguage#33](https://github.com/vshaxe/haxe-TmLanguage/issues/33))
- fixed highlighting of capture variables with `var` ([haxe-TmLanguage#34](https://github.com/vshaxe/haxe-TmLanguage/issues/34))
- fixed overloaded methods showing multiple times in completion
- fixed `"haxe.enableCodeLens"` changes not triggering an update ([#95](https://github.com/vshaxe/vshaxe/issues/95))
- fixed exit code of clients connecting to `"haxe.displayPort"` always being 0 ([haxe#6431](https://github.com/HaxeFoundation/haxe/issues/6431))

**Changes and Improvements**:

- changed the required VSCode version to 1.20.0
- the problems view is now opened after global diagnostics runs ([#38](https://github.com/vshaxe/vshaxe/issues/38))
- document symbols now use separate icons for enum members / operators / structs
- document symbols now show type parameters
- the dependency explorer now shows "dev" for `haxelib dev` libraries instead of the full path

### 1.9.3 (November 5, 2017)

**Bugfixes**:

- fixed excessive keyword highlighting in HXML files ([#177](https://github.com/vshaxe/vshaxe/issues/177))

**Changes and Improvements**:

- only show "Haxe Dependencies" in the explorer if vshaxe was activated in the workspace ([#174](https://github.com/vshaxe/vshaxe/issues/174))
- adapt to latest Haxe 4 (development branch) changes

### 1.9.2 (October 24, 2017)

**Bugfixes**:

- fixed [compiler error code actions](https://github.com/vshaxe/vshaxe/wiki/Code-Actions#compiler-error-actions) for indent lengths != 2 ([#168](https://github.com/vshaxe/vshaxe/issues/168))
- fixed completion in workspaces where the selected completion provider doesn't exist anymore
- fixed `package` statement insertion randomly not working ([#172](https://github.com/vshaxe/vshaxe/issues/172))

**Changes and Improvements**:

- added `final` keyword to syntax highlighting

### 1.9.1 (August 16, 2017)

**Bugfixes**:

- fixed the dependency explorer for local haxelib repos ([#162](https://github.com/vshaxe/vshaxe/issues/162))
- fixed some issues with Haxe executable handling ([#163](https://github.com/vshaxe/vshaxe/issues/163), [#166](https://github.com/vshaxe/vshaxe/issues/166))

**Changes and Improvements**:

- added missing compiler metadata identifiers to syntax highlighting

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
- fixed a minor anon function highlighting issue ([haxe-TmLanguage#31](https://github.com/vshaxe/haxe-TmLanguage/issues/31))
- fixed renaming `expr` in `case macro $expr:` ([#142](https://github.com/vshaxe/vshaxe/issues/142))
- fixed a regression with duplicated Haxe output channels ([#87](https://github.com/vshaxe/vshaxe/issues/87))
- fixed line break handling in completion docs ([#150](https://github.com/vshaxe/vshaxe/issues/150))

**Changes and Improvements**:

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

- fixed a minor string interpolation highlighting issue ([haxe-TmLanguage#27](https://github.com/vshaxe/haxe-TmLanguage/issues/27))
- fixed catch variables not being listed in document symbols
- fixed diagnostics of deleted / renamed files not being removed ([#132](https://github.com/vshaxe/vshaxe/issues/132))

**Changes and Improvements**:

- changed the required VSCode version to 1.13.0
- allowed filtering by path in the display configuration picker
- init project command: replaced `-js` with `--interp` ([#124](https://github.com/vshaxe/vshaxe/issues/124))
- adjusted column index handling to support changes in Haxe 4 ([#134](https://github.com/vshaxe/vshaxe/issues/134))

### 1.7.0 (May 24, 2017)

**Bugfixes**:

- fixed Unicode character handling for completion with Haxe 4
- fixed filtering in metadata completion ([#121](https://github.com/vshaxe/vshaxe/issues/121))

**Changes and Improvements**:

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

- fixed several small highlighting issues ([haxe-TmLanguage](https://github.com/vshaxe/haxe-TmLanguage)[[#4](https://github.com/vshaxe/haxe-TmLanguage/issues/4), [#6](https://github.com/vshaxe/haxe-TmLanguage/issues/6), [#11](https://github.com/vshaxe/haxe-TmLanguage/issues/11), [#16](https://github.com/vshaxe/haxe-TmLanguage/issues/16), [#22](https://github.com/vshaxe/haxe-TmLanguage/issues/22)])

### 1.5.1 (April 21, 2017)

**Bugfixes**:

- fixed toplevel completion hanging in some cases ([haxe-languageserver#23](https://github.com/vshaxe/haxe-languageserver/pull/23#issuecomment-295468634))

### 1.5.0 (April 7, 2017)

**New Features**:

- added a Haxe problem matcher (referenced with `"problemMatcher": "$haxe"`, VSCode 1.11.0+)

**Changes and Improvements**:

- use the Haxe problem matcher in "Init Project"

**Bugfixes**:

- fixed support for Haxe 4+ (development branch)

### 1.4.0 (International Women's Day, 2017)

**New Features**:

- added a `Toggle Code Lens` command ([#94](https://github.com/vshaxe/vshaxe/issues/94))

**Bugfixes**:

- fixed several small highlighting issues ([haxe-TmLanguage](https://github.com/vshaxe/haxe-TmLanguage)[[#2](https://github.com/vshaxe/haxe-TmLanguage/issues/2), [#5](https://github.com/vshaxe/haxe-TmLanguage/issues/5), [#8](https://github.com/vshaxe/haxe-TmLanguage/issues/8), [#14](https://github.com/vshaxe/haxe-TmLanguage/issues/14), [#15](https://github.com/vshaxe/haxe-TmLanguage/issues/15), [#17](https://github.com/vshaxe/haxe-TmLanguage/issues/17)])
- fixed signature help sometimes not having argument names ([haxe#6064](https://github.com/HaxeFoundation/haxe/issues/6064))
- fixed argument name generation with anon structure types

**Changes and Improvements**:

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

**Changes and Improvements**:

- no longer request diagnostics if `diagnosticsPathFilter` doesn't match

### 1.3.1 (February 9, 2017)

**Bugfixes**:

- fixed invalid argument name generation with type parameters ([haxe-languageserver#28](https://github.com/vshaxe/haxe-languageserver/issues/28))
- fixed inconsistent icon usage in field and toplevel completion
- fixed diagnostics sometimes being reported for the wrong file

**Changes and Improvements**:

- smarter error handling ([#20](https://github.com/vshaxe/vshaxe/issues/20), [haxe-languageserver#20](https://github.com/vshaxe/haxe-languageserver/issues/20))
- ignore hidden files in the "init project" command ([#10](https://github.com/vshaxe/vshaxe/issues/10))
- some minor highlighting improvements ([haxe-TmLanguage#10](https://github.com/vshaxe/haxe-TmLanguage/issues/10))
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
- fixed highlighting of comments after conditionals ([haxe-TmLanguage#1](https://github.com/vshaxe/haxe-TmLanguage/issues/1))
- fixed indentation when writing a comment after `}` ([#83](https://github.com/vshaxe/vshaxe/issues/83))
- fixed display requests being attempted with no display config
- fixed toplevel completion with whitespace after `:` ([haxe-languageserver#22](https://github.com/vshaxe/haxe-languageserver/issues/22))
- fixed some compiler errors not being highlighted by diagnostics ([#62](https://github.com/vshaxe/vshaxe/issues/62))

**Changes and Improvements**:

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

**Changes and Improvements**:

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

**Changes and Improvements**:

- improved code highlighting
- improved handling of unsupported Haxe versions ([#16](https://github.com/vshaxe/vshaxe/issues/16))
