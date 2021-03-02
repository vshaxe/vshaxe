### 2.22.1 (February 28, 2021)

**Changes and Improvements:**

- improved missing field generation to sort them by declaration order
- updated to haxe-formatter version [1.12.0](https://github.com/HaxeCheckstyle/haxe-formatter/releases/tag/v1.12.0)

**Bugfixes:**

- fixed missing abstract class fields being generated with `override`
- fixed "implement missing fields" not working if a variable is one of them
- fixed `static` missing from variables generated with missing field quickfix
- fixed missing field quickfix not working at module level
- fixed function arguments with default values being printed with `?` ([#468](https://github.com/vshaxe/vshaxe/issues/468))

### 2.22.0 (February 9, 2021)

**New Features:**

- added support for abstract classes ([HXP-0012](https://github.com/HaxeFoundation/haxe-evolution/blob/master/proposals/0012-abstract-classes.md#abstract-classes))
- added code actions to implement missing interface, abstract class and property fields ([#205](https://github.com/vshaxe/vshaxe/issues/205))
- added a code action to make a class with non-implemented fields `abstract`
- added a code action to create non-existent fields ([#232](https://github.com/vshaxe/vshaxe/issues/232))
- added syntax highlighting for `overload` and `abstract` modifiers
- added syntax highlighting for `hlcode.txt` / HashLink bytecode dump files ([haxe-TmLanguage#51](https://github.com/vshaxe/haxe-TmLanguage/issues/51))

**Changes and Improvements:**

- added `..` to HXML file system completion
- updated to haxe-formatter version [1.11.2](https://github.com/HaxeCheckstyle/haxe-formatter/releases/tag/v1.11.2)
- improved goto definition performance when invoked through ctrl+click ([#366](https://github.com/vshaxe/vshaxe/issues/366))

**Bugfixes:**

- fixed HXML completion for libraries with dots in their name ([#452](https://github.com/vshaxe/vshaxe/issues/452))
- fixed organize imports cutting of trailing comments ([haxe-formatter#628](https://github.com/HaxeCheckstyle/haxe-formatter/issues/628))
- fixed import sorting eating lines when formatting is turned off ([haxe-formatter#632](https://github.com/HaxeCheckstyle/haxe-formatter/issues/632))

### 2.21.4 (July 11, 2020)

**Bugfixes:**

- fixed hover hints for compiler metadata

### 2.21.3 (July 4, 2020)

**Bugfixes:**

- fixed diagnostics-based code actions not working anymore

### 2.21.2 (July 3, 2020)

**Bugfixes:**

- fixed "Rename Symbol" not working correctly ([#448](https://github.com/vshaxe/vshaxe/issues/448))

### 2.21.1 (July 2, 2020)

**Changes and Improvements:**

- added syntax highlighting support for the `is` operator outside of parens ([haxe#9672](https://github.com/HaxeFoundation/haxe/pull/9672))

**Bugfixes:**

- fixed struct completion with optional functions ([#449](https://github.com/vshaxe/vshaxe/issues/449))
- fixed mid-word HXML completion with dashes ([#450](https://github.com/vshaxe/vshaxe/issues/450))

### 2.21.0 (June 28, 2020)

**New Features:**

- added support for completion and hover in HXML files ([#28](https://github.com/vshaxe/vshaxe/issues/28))
- added expected type completion for array, map and regex literals
- added a `listLibraries()` method to the `HaxeInstallationProvider` extension API

**Changes and Improvements:**

- improved import code actions to only be marked as "preferred" if there's only one option

### 2.20.3 (June 10, 2020)

**Changes and Improvements:**

- improved error handling for conflicts with `"haxe.enableExtendedIndentation"` ([#410](https://github.com/vshaxe/vshaxe/issues/410))

### 2.20.2 (June 7, 2020)

**Changes and Improvements:**

- added support for `--java-lib-extern` to HXML syntax highlighting
- updated to haxe-formatter version [1.11.0](https://github.com/HaxeCheckstyle/haxe-formatter/releases/tag/v1.11.0)

### 2.20.1 (May 30, 2020)

**Bugfixes:**

- fixed some issues with completion provider disposal and deactivation

### 2.20.0 (May 26, 2020)

**New Features:**

- added support for `--jvm` to HXML syntax highlighting and the extension API (Haxe 4.1.1)
- added initial support for module-level fields in snippets, hover and completion ([HXP-0007](https://github.com/HaxeFoundation/haxe-evolution/blob/master/proposals/0007-module-level-funcs.md#module-level-functions-and-variables))
- added `var`, `final` and `function` snippets within fields

**Bugfixes:**

- fixed postfix `switch` completion not working on enum abstracts since Haxe 4.1.0 ([#436](https://github.com/vshaxe/vshaxe/issues/436))

### 2.19.5 (May 11, 2020)

**Changes and Improvements:**

- include all overrides when invoking "Find References" on a method ([requires Haxe 4.1](https://github.com/HaxeFoundation/haxe/pull/9315))

### 2.19.4 (April 18, 2020)

**Bugfixes:**

- fixed toplevel completion not working with a `private final class` ([#430](https://github.com/vshaxe/vshaxe/issues/430))
- fixed deprecated types not showing up in toplevel completion

### 2.19.3 (April 14, 2020)

**Bugfixes:**

- fixed text document cache getting out of sync in rare cases ([#376](https://github.com/vshaxe/vshaxe/issues/376))

### 2.19.2 (April 13, 2020)

**Changes and Improvements:**

- updated to haxe-formatter version [1.10.1](https://github.com/HaxeCheckstyle/haxe-formatter/releases/tag/v1.10.1)

### 2.19.1 (April 8, 2020)

**Bugfixes:**

- fixed order of class paths not being preserved correctly in `getActiveConfiguration()`
- fixed a race condition that could happen during language server startup

### 2.19.0 (April 3, 2020)

**New Features:**

- added `getActiveConfiguration()` to the extension API ([#221](https://github.com/vshaxe/vshaxe/issues/221))

**Changes and Improvements:**

- changed the required VSCode version to 1.42.0
- changed the default of `"editor.suggestSelection"` to `"first"` in Haxe files ([requires VSCode 1.44](https://github.com/microsoft/vscode/issues/91180))
- added a `HAXE_COMPLETION_SERVER` environment variable for tools like haxeshim
- added support for more icons in workspace symbols (requires Haxe 4.1.0)

**Bugfixes:**

- fixed `import` and `using` being highlighted within words ([haxe-TmLanguage](https://github.com/vshaxe/haxe-TmLanguage)[[#49](https://github.com/vshaxe/haxe-TmLanguage/issues/49), [#50](https://github.com/vshaxe/haxe-TmLanguage/issues/50)])
- fixed function arguments sometimes being shown as optional when they're only nullable
- fixed only the type being shown in enum abstract value hover
- fixed language server startup not being triggered in rare cases

### 2.18.1 (March 3, 2020)

**Bugfixes:**

- fixed auto-imports with metadata and line comments ([#414](https://github.com/vshaxe/vshaxe/issues/414))
- fixed language mode of a file changing to Haxe not triggering language server startup

### 2.18.0 (January 19, 2020)

**New Features:**

- added support for "Go to Implementations" (requires [haxe#9079](https://github.com/HaxeFoundation/haxe/pull/9079))
- added a `"haxe.maxCompletionItems"` setting

**Changes and Improvements:**

- code lens now only show the subclass / -interface count when there are any
- improved the stability of code lens by reusing old results
- "This case is unused" diagnostics now gray out the code
- included the current Haxe executable in the "outdated Haxe version" notification ([#390](https://github.com/vshaxe/vshaxe/issues/390))
- extended the "outdated Haxe version" notification to Haxe 3
- improved override completion to respect `@:noCompletion` metadata ([#398](https://github.com/vshaxe/vshaxe/issues/398))
- improved activation to avoid server and UI startup in non-Haxe projects
- improved Haxe communication to use a socket rather than stdio if possible ([#217](https://github.com/vshaxe/vshaxe/issues/217), [#393](https://github.com/vshaxe/vshaxe/issues/393))
- removed support for Haxe 4 preview builds earlier than 4.0.0-preview.4

**Bugfixes:**

- fixed `=>` in extractors not working with font ligatures in some themes
- fixed code lens not working in some files ([haxe#9092](https://github.com/HaxeFoundation/haxe/issues/9092))
- fixed completion breaking on `@:optional` functions ([#409](https://github.com/vshaxe/vshaxe/issues/409))
- fixed cpp/java/cs compilation with lix through build tasks and the caching build
- fixed optional structure fields not being printed with a `?` ([#383](https://github.com/vshaxe/vshaxe/issues/383))

### 2.17.0 (January 1, 2020)

**New Features:**

- added import/using sorting to "Organize Imports"
- added a "Sort imports/usings" source action
- added a code action to extract constants from string literals
- added auto indentation in `switch` and single line `if` / `else` / etc ([#133](https://github.com/vshaxe/vshaxe/issues/133), [#399](https://github.com/vshaxe/vshaxe/issues/399))
- added auto indentation for `/** **/` doc comments
- added a `"haxe.enableExtendedIndentation"` setting

**Changes and Improvements:**

- improved compatibility with Haxe 4.1.0 nightly builds
- updated to haxe-formatter version [1.9.2](https://github.com/HaxeCheckstyle/haxe-formatter/releases/tag/v1.9.2)

**Bugfixes:**

- fixed eval-debugger sessions not properly stopping on stop

### 2.16.5 (October 28, 2019)

**Changes and Improvements:**

- updated the "outdated Haxe 4 preview" message for Haxe 4.0.0

**Bugfixes:**

- fixed an incompatibility with the Haxe 4.0.0 release

### 2.16.4 (September 18, 2019)

**Bugfixes:**

- fixed issues with range formatting of multiline comments and strings ([#382](https://github.com/vshaxe/vshaxe/issues/382))

### 2.16.3 (September 13, 2019)

**Changes and Improvements:**

- updated the "outdated Haxe 4 preview" message for Haxe 4.0.0-rc.5

**Bugfixes:**

- fixed some issues with HXML files that contain `--next` ([#378](https://github.com/vshaxe/vshaxe/issues/378))

### 2.16.2 (September 12, 2019)

**Bugfixes:**

- fixed an issue with whitespace handling in range formatting

### 2.16.1 (September 12, 2019)

**Changes and Improvements:**

- updated to haxe-formatter version [1.9.1](https://github.com/HaxeCheckstyle/haxe-formatter/releases/tag/v1.9.1)

**Bugfixes:**

- fixed "Reveal In Explorer" in Haxe Dependencies on macOS ([#379](https://github.com/vshaxe/vshaxe/issues/379))
- fixed tokens being duplicated in some cases with range formatting ([#381](https://github.com/vshaxe/vshaxe/issues/381))

### 2.16.0 (September 10, 2019)

**New Features:**

- added support for "Format Selection" and `"editor.formatOnPaste"`

**Changes and Improvements:**

- updated to haxe-formatter version [1.9.0](https://github.com/HaxeCheckstyle/haxe-formatter/releases/tag/v1.9.0)

**Bugfixes:**

- fixed a hang when parsing macro reification in some situations ([#360](https://github.com/vshaxe/vshaxe/issues/360))

### 2.15.0 (September 4, 2019)

**New Features:**

- added fading out of inactive conditional compilation blocks ([#271](https://github.com/vshaxe/vshaxe/issues/271)) *
- added hover hints in compiler conditionals *
- added a `"haxe.useLegacyCompletion"` setting *

<sup>_* requires Haxe 4.0.0-rc.4_</sup>

**Changes and Improvements:**

- diagnostics are now removed when the file they belong to is closed
- updated the Haxe cache view for changes in Haxe 4.0.0-rc.4
- updated the "outdated Haxe 4 preview" message for Haxe 4.0.0-rc.4

**Bugfixes:**

- fixed names in type snippets with `Module.platform.hx`

### 2.14.1 (August 18, 2019)

**Bugfixes:**

- fixed keyword / snippet completion outside of functions

### 2.14.0 (August 17, 2019)

**Changes and Improvements:**

- added [strike-through rendering](https://code.visualstudio.com/updates/v1_37#_diagnosticstagdeprecated) for deprecation diagnostics ([haxe#8632](https://github.com/HaxeFoundation/haxe/issues/8632))
- improved completion performance by limiting the number of results ([haxe#8642](https://github.com/HaxeFoundation/haxe/issues/8642))
- improved error message for starting eval-debugger without a configuration ([#370](https://github.com/vshaxe/vshaxe/issues/370))

### 2.13.7 (August 12, 2019)

**Changes and Improvements:**

- changed the required VSCode version to 1.37.0
- updated icons for VSCode 1.37.0

### 2.13.6 (August 12, 2019)

**Changes and Improvements:**

- improved completion to detect deletion and creation of types ([haxe#8451](https://github.com/HaxeFoundation/haxe/issues/8451))

### 2.13.5 (August 2, 2019)

**Bugfixes:**

- fixed filtering in toplevel completion
- fixed type snippets appearing in import completion

### 2.13.4 (July 14, 2019)

**Changes and Improvements:**

- added manual links to metadata completion and hover ([haxe#8350](https://github.com/HaxeFoundation/haxe/issues/8350))
- added "Find in Folder..." to the context menu of folders in Haxe Dependencies

**Bugfixes:**

- fixed `macro` missing from modifier keyword completion

### 2.13.3 (June 19, 2019)

**Bugfixes:**

- fixed replace ranges of metadata completion
- fixed HXML highlighting with Haxe arguments as substrings ([haxe-TmLanguage#44](https://github.com/vshaxe/haxe-TmLanguage/issues/44))

### 2.13.2 (June 17, 2019)

**Bugfixes:**

- fixed incorrect parameter highlighting in signature help in some cases ([#352](https://github.com/vshaxe/vshaxe/issues/352))
- fixed mid-word invocation of completion with Haxe 4.0.0-rc.3 ([haxe#8438](https://github.com/HaxeFoundation/haxe/issues/8438))
- fixed mid-word invocation of postfix completion (`expr.swit|`)

### 2.13.1 (June 14, 2019)

**Changes and Improvements:**

- updated to haxe-formatter version [1.8.0](https://github.com/HaxeCheckstyle/haxe-formatter/releases/tag/v1.8.0)
- updated the "outdated Haxe 4 preview" message for Haxe 4.0.0-rc.3

**Bugfixes:**

- fixed "Internal" stack frames being clickable in eval debugging

### 2.13.0 (June 13, 2019)

**New Features:**

- added a `HaxeInstallationProvider` extension API
- added a `source` to `HaxeExecutableConfiguration` in the extension API
- added automatic extension recommendations for lix, Lime and Kha projects

**Bugfixes:**

- fixed some "unhandled method" errors in the Haxe output channel on startup

### 2.12.2 (June 3, 2019)

**Bugfixes:**

- fixed highlighting of type names in `IntIterator` literals ([haxe-TmLanguage#43](https://github.com/vshaxe/haxe-TmLanguage/issues/43))
- fixed highlighting of `#if` conditions with capitalized defines

### 2.12.1 (June 1, 2019)

**Bugfixes:**

- fixed classpath parsing not working anymore

### 2.12.0 (May 31, 2019)

**New Features:**

- added a `"haxelib.executable"` setting ([#227](https://github.com/vshaxe/vshaxe/issues/227))

**Changes and Improvements:**

- updated to haxe-formatter version [1.7.1](https://github.com/HaxeCheckstyle/haxe-formatter/releases/tag/v1.7.1)
- added "Show Error" / "Retry" buttons to the "Haxe has crashed 3 times" message
- added syntax highlighting support for `#if foo.bar` style conditionals ([haxe#8353](https://github.com/HaxeFoundation/haxe/issues/8353))
- improved startup time by bundling and minifying vshaxe's JS binaries
- improved completion to auto-trigger again after inserting `<>` ([haxe#8007](https://github.com/HaxeFoundation/haxe/issues/8007)) and `inline`

**Bugfixes:**

- fixed import generation with metadata and no existing imports ([#347](https://github.com/vshaxe/vshaxe/issues/347))
- fixed some issues with `--cwd` handling

### 2.11.0 (May 17, 2019)

**Changes and Improvements:**

- updated to haxe-formatter version [1.7.0](https://github.com/HaxeCheckstyle/haxe-formatter/releases/tag/v1.7.0)
- changed the highlighting of `import` and `using` for more consistency with other languages
- renamed the `"haxe.displayConfigurations"` setting to `"haxe.configurations"`
- renamed the `"haxe.selectDisplayConfiguration"` command to `"haxe.selectConfiguration"`

**Bugfixes:**

- fixed a regression with `--cwd` by using absolute paths in display requests again ([#345](https://github.com/vshaxe/vshaxe/issues/345))

### 2.10.1 (May 14, 2019)

**Bugfixes:**

- fixed a regression with empty line handling when generating imports

### 2.10.0 (May 14, 2019)

**New Features:**

- added a `Reveal Active File in Side Bar` command ([#341](https://github.com/vshaxe/vshaxe/issues/341))
- added a `"haxe.codeGeneration.switch.parentheses"` setting ([#336](https://github.com/vshaxe/vshaxe/issues/336))

**Changes and Improvements:**

- improved completion to hide `@:deprecated` types ([haxe#8178](https://github.com/HaxeFoundation/haxe/issues/8178))
- changed `switch` to be generated without parentheses by default ([#336](https://github.com/vshaxe/vshaxe/issues/336))

**Bugfixes:**

- fixed syntax highlighting in hover and completion with VSCode 1.34
- fixed some path / cwd issues by using relative paths for display requests ([#248](https://github.com/vshaxe/vshaxe/issues/248), [#310](https://github.com/vshaxe/vshaxe/issues/310))
- fixed import insertion in files with license headers ([#325](https://github.com/vshaxe/vshaxe/issues/325))
- fixed methods view not being able to show identical methods in the queue ([#344](https://github.com/vshaxe/vshaxe/issues/344))
- fixed performance issues caused by request cancellation not working ([#344](https://github.com/vshaxe/vshaxe/issues/344))

### 2.9.2 (April 24, 2019)

**Bugfixes:**

- fixed backwards compatibility with VSCode versions < 1.33
- fixed eval-debugger being incompatible with [Lix](https://github.com/lix-pm/lix.client) ([eval-debugger#6](https://github.com/vshaxe/eval-debugger/pull/6))

### 2.9.1 (April 21, 2019)

**New Features:**

- added a `"haxe.enableCompletionCacheWarning"` setting

**Bugfixes:**

- fixed postfix completion incorrectly triggering after `case` sometimes ([#337](https://github.com/vshaxe/vshaxe/issues/337))

### 2.9.0 (April 20, 2019)

**New Features:**

- added [snippet completion](https://github.com/vshaxe/vshaxe/wiki/Snippets) for generating type, field and `package` boilerplate
- added a large number of postfix completion items:
	- forwards and backwards `while` loops
	- `trace` / `print` / `string`
	- `null` / `not null`
	- `is` / `type check` / `unsafe cast` / `safe cast`
	- `not` / `else` on `Bool`
	- `return`
- added a `"haxe.postfixCompletion.level"` setting
- added field modifier keywords to completion

**Changes and Improvements:**

- improved completion to trigger automatically after `$` in string interpolation
- improved completion in doc comments (now falls back to word based suggestions)
- improved completion to disallow `(` as a commit character for metadata
- improved performance with `"haxe.exclude"` (Haxe dev)
- improved `"haxe.exclude"` to apply to classpath parsing / workspace symbols too (Haxe dev)
- improved postfix completion to allow `switch` on non-enum types as well
- moved all postfix completion items to the end of the completion list
- hide unused imports diagnostics if compiler errors exist to avoid false positives
- hide unresolved identifier diagnostics if parser errors exist to make them easier to spot

**Bugfixes:**

- fixed `:` not being auto-inserted after `null` / `true` / `false` patterns
- fixed mid-word invocation of postfix completion (`expr.swit|`)

### 2.8.1 (April 4, 2019)

**Changes and Improvements:**

- added `var` and `final` to postfix completion
- improved postfix completion so that items don't always show on top

### 2.8.0 (March 23, 2019)

**New Features:**

- added support for the ["Auto Fix" command and preferred code actions](https://code.visualstudio.com/updates/v1_32#_auto-fix-and-preferred-code-actions)
- added an "Add override keyword" quick fix (Haxe 4+)
- added postfix `for` completion for any type with iterators (requires Haxe 4.0.0-rc.2)
- added postfix `for` completion for any `length` / `count` / `size` fields

**Changes and Improvements:**

- updated to haxe-formatter version [1.6.0](https://github.com/HaxeCheckstyle/haxe-formatter/releases/tag/v1.6.0)
- updated eval-debugger for Haxe 4.0.0-rc.2 (no longer works with rc.1)
- updated the "outdated Haxe 4 preview" message for Haxe 4.0.0-rc.2
- improved folding to support folding `case` and `default` blocks
- improved `for` loops generated by postfix completion by including a body
- improved import quick fixes to offer both import styles when applicable
- removed support for signature-help based code generation (Haxe 3.4)

**Bugfixes:**

- fixed postfix `switch` completion on `Null<Enum>` (requires Haxe 4.0.0-rc.2)

### 2.7.0 (March 6, 2019)

**New Features:**

- added document symbol / folding / formatting support in untitled files
- added a view to inspect Haxe's cache (requires latest Haxe dev)
- added an upgrade notification for old Haxe 4 preview builds

**Changes and Improvements:**

- updated to haxe-formatter version [1.5.1](https://github.com/HaxeCheckstyle/haxe-formatter/blob/master/CHANGELOG.md#version-151-2019-03-06)
- fixed compatibility with upcoming VSCode 1.32.0 ([#317](https://github.com/vshaxe/vshaxe/issues/317))
- improved HXML detection to ignore `extraParams.hxml` ([#320](https://github.com/vshaxe/vshaxe/issues/320))
- improved the "cache build failed" warning to include a retry button
- included parser errors in diagnostics (requires latest Haxe dev) ([#102](https://github.com/vshaxe/vshaxe/issues/102))
- moved the Haxe Methods view to a separate Haxe Server view container
- replaced the `"haxe.enableMethodsView"` setting with `"haxe.enableServerView"`

**Bugfixes:**

- fixed tasks not working on Windows with a `haxe` folder next to `haxe.exe`
- fixed icons of extern enum abstract values in completion
- fixed rename being permitted (and subsequently failing) on fields ([#318](https://github.com/vshaxe/vshaxe/issues/318))
- fixed missing dot paths in import completion when type is already imported

### 2.6.0 (February 12, 2019)

**New Features:**

- added debugging support for Haxe 4 macros and `--interp` scripts
- added postfix `for` completion to `haxe.ds.Map` and `haxe.ds.List`
- added support for markdown syntax highlighting in doc comments

**Changes and Improvements:**

- changed the required VSCode version to 1.31.0
- init project command: added a `launch.json` for macro / `--interp` debugging

### 2.5.1 (February 7, 2019)

**Bugfixes:**

- fixed tasks no longer working in VSCode 1.30.x ([vscode#67990](https://github.com/Microsoft/vscode/issues/67990))

### 2.5.0 (February 7, 2019)

**Changes and Improvements:**

- changed the required VSCode version to 1.30.0
- support the new `clear` option in `"haxe.taskPresentation"`
- updated to haxe-formatter version [1.4.0](https://github.com/HaxeCheckstyle/haxe-formatter/releases/tag/v1.4.0)

**Bugfixes:**

- worked around tasks not working in VSCode 1.31.0 ([vscode#67990](https://github.com/Microsoft/vscode/issues/67990))

### 2.4.5 (December 5, 2018)

**Changes and Improvements:**

- updated to haxe-formatter version [1.3.0](https://github.com/HaxeCheckstyle/haxe-formatter/releases/tag/v1.3.0)
- disallowed using `(` as a commit character in pattern completion ([#292](https://github.com/vshaxe/vshaxe/issues/292))

### 2.4.4 (October 17, 2018)

**Changes and Improvements:**

- updated to haxe-formatter version [1.1.2](https://github.com/HaxeCheckstyle/haxe-formatter/releases/tag/v1.1.2)

### 2.4.3 (October 16, 2018)

**Changes and Improvements:**

- really updated to haxe-formatter version [1.1.1](https://github.com/HaxeCheckstyle/haxe-formatter/releases/tag/v1.1.1) ^_^

### 2.4.2 (October 15, 2018)

**Bugfixes:**

- fixed tasks not working when vshaxe hasn't been activated yet ([#296](https://github.com/vshaxe/vshaxe/issues/296))

**Changes and Improvements:**

- updated to haxe-formatter version [1.1.1](https://github.com/HaxeCheckstyle/haxe-formatter/releases/tag/v1.1.1)
- added syntax highlighting support for key-value iterators ([HXP-0005](https://github.com/HaxeFoundation/haxe-evolution/blob/master/proposals/0005-key-value-iter.md#key--value-iteration-syntax))
- added expected argument info when hovering over call args (requires Haxe 4 preview 5)
- added more details to metadata docs in completion / hover (requires Haxe 4 preview 5)
- don't save auto-selected display configurations ([#295](https://github.com/vshaxe/vshaxe/issues/295))
- allowed using the "Organize Imports" command to remove unused imports

### 2.4.1 (September 12, 2018)

**Changes and Improvements:**

- updated to haxe-formatter version [1.1.0](https://github.com/HaxeCheckstyle/haxe-formatter/releases/tag/v1.1.0)
- allowed auto-closing of brackets in single quote strings ([#123](https://github.com/vshaxe/vshaxe/issues/123))
- added syntax highlighting support for `final class` / `interface` ([haxe#7381](https://github.com/HaxeFoundation/haxe/pull/7381))

### 2.4.0 (August 23, 2018)

**New Features:**

- added support for code formatting (using [haxe-formatter](https://github.com/HaxeCheckstyle/haxe-formatter))

**Bugfixes:**

- fixed highlighting of macro patterns

**Changes and Improvements:**

- improved document symbol ranges to include doc comments

### 2.3.0 (July 31, 2018)

**New Features:**

- added support for removing unused imports with [`"editor.codeActionsOnSave"`](https://code.visualstudio.com/updates/v1_23#_run-code-actions-on-save)
- added support for triggering quick fixes from the problems view [in VSCode 1.26](https://github.com/Microsoft/vscode/issues/52627#issuecomment-405254755)
- added a folding marker for the imports / usings section in a module
- added folding markers for `#if` / `#else` / `#elseif` conditionals ([#36](https://github.com/vshaxe/vshaxe/issues/36))
- added folding markers for multi-line string and array literals

**Bugfixes:**

- fixed static import completion with Haxe 4.0.0-preview.4 ([#265](https://github.com/vshaxe/vshaxe/issues/265))
- fixed document symbol ranges in files with Unicode characters

**Changes and Improvements:**

- improved folding of block comments (the final `**/` is now hidden too)
- improved completion and document symbols to ignore locals named `_`
- improved completion in nested patterns (requires [haxe#7287](https://github.com/HaxeFoundation/haxe/issues/7287))
- auto-trigger signature help in patterns (requires [haxe#7326](https://github.com/HaxeFoundation/haxe/issues/7326))

### 2.2.1 (July 21, 2018)

**Bugfixes:**

- fixed `Restart Language Sever` duplicating document symbols
- fixed document symbols not using the operator icon in abstracts

### 2.2.0 (July 20, 2018)

**New Features:**

- added hierarchy support to document symbols for the outline view ([#223](https://github.com/vshaxe/vshaxe/issues/223))

**Bugfixes:**

- fixed several issues related to display argument provider initialization ([#235](https://github.com/vshaxe/vshaxe/issues/235))

**Changes and Improvements:**

- improved document symbols to work with conditional compilation
- improved document symbols to support Haxe 4 syntax (`enum abstract`, `final`...)
- removed arguments and type parameters from document symbols
- show a warning in case there's an error during "Building Cache..."

### 2.1.0 (July 12, 2018)

**New Features:**

- added support for fading out unused code
- added `"explorer.autoReveal"` support to the dependency explorer ([#152](https://github.com/vshaxe/vshaxe/issues/152))
- added `"print"` options to the `"haxe.displayServer"` setting ([#240](https://github.com/vshaxe/vshaxe/issues/240))
- added a `"haxe.exclude"` setting to allow hiding dot paths from completion ([#234](https://github.com/vshaxe/vshaxe/issues/234))
- added a request queue visualization to the Haxe Methods view ([#241](https://github.com/vshaxe/vshaxe/issues/241))
- added a `Debug Selected Configuration` command ([#236](https://github.com/vshaxe/vshaxe/issues/236))
- added support for "Go to Type Definition" (requires [haxe#7266](https://github.com/HaxeFoundation/haxe/pull/7266))

**Bugfixes:**

- fixed auto-imports in override generation being duplicated ([#257](https://github.com/vshaxe/vshaxe/issues/257))
- fixed compilation through the server for HXML files with `--next` ([#262](https://github.com/vshaxe/vshaxe/issues/262))
- fixed a crash in the dependency explorer when `haxelib` isn't available ([#249](https://github.com/vshaxe/vshaxe/issues/249))
- fixed opening/closing folders in the dependency explorer not working properly
- fixed libraries in the dependency explorer being listed twice in rare cases ([#263](https://github.com/vshaxe/vshaxe/issues/263))
- fixed types in completion sometimes being sorted counter-intuitively

**Changes and Improvements:**

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

**Bugfixes:**

- fixed disabling of auto-imports in `"haxe.codeGeneration"` settings

### 2.0.0 (June 12, 2018)

_The following features, fixes and improvements **require Haxe 4.0.0-preview.4:**_

**New Features:**

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
- added syntax highlighting support for intersection types ([HXP-0004](https://github.com/HaxeFoundation/haxe-evolution/blob/master/proposals/0004-intersection-types.md#intersection-types))
- added syntax highlighting support for qualified metadata ([haxe#3959](https://github.com/HaxeFoundation/haxe/issues/3959))
- added syntax highlighting support for `var ?x:Int` syntax ([haxe#6707](https://github.com/HaxeFoundation/haxe/issues/6707))
- added support for Haxe 4 style CLI arguments ([haxe#6862](https://github.com/HaxeFoundation/haxe/pull/6862))

**Bugfixes:**

- fixed all cases of completion being triggered after `:` on a `case` ([#112](https://github.com/vshaxe/vshaxe/issues/112))
- fixed inconsistent presentation of function types in hover ([#144](https://github.com/vshaxe/vshaxe/issues/144))
- fixed signature help not closing when moving outside of the brackets ([#216](https://github.com/vshaxe/vshaxe/issues/216))
- fixed import code actions not working in some places ([haxe](https://github.com/HaxeFoundation/haxe)[[#5950](https://github.com/HaxeFoundation/haxe/issues/5950), [#5951](https://github.com/HaxeFoundation/haxe/issues/5951)])
- fixed function generation not working with aliased function types ([#103](https://github.com/vshaxe/vshaxe/issues/103))

**Changes and Improvements:**

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

**New Features:**

- added a `"haxe.enableSignatureHelpDocumentation"` setting ([#197](https://github.com/vshaxe/vshaxe/issues/197))
- added Haxe and HXML highlighting in fenced markdown code blocks

**Bugfixes:**

- fixed several small highlighting issues ([haxe-TmLanguage](https://github.com/vshaxe/haxe-TmLanguage)[[#40](https://github.com/vshaxe/haxe-TmLanguage/issues/40), [#41](https://github.com/vshaxe/haxe-TmLanguage/issues/41)])
- fixed files sometimes being opened twice with different cases on Windows
- fixed the treatment of missing properties in `"haxe.codeGeneration"`

**Changes and Improvements:**

- improved completion to trigger automatically after certain keywords (e.g. `import`)
- changed hover hints to use Haxe 4's new function type syntax ([HXP-0003](https://github.com/HaxeFoundation/haxe-evolution/blob/master/proposals/0003-new-function-type.md#new-function-type-syntax))

### 1.12.0 (May 3, 2018)

**New Features:**

- added a `haxe: active configuration` task if there's at least two configurations
- added the ability to specify labels for items in `"haxe.displayConfigurations"`
- added a `haxeCompletionProivder` context key (can be used in [keyboard shortcuts](https://code.visualstudio.com/docs/getstarted/keybindings#_when-clause-contexts))

**Bugfixes:**

- fixed some dependencies missing from the dependency explorer
- fixed compilation server socket not listening on `localhost` ([lime-vscode-extension#35](https://github.com/openfl/lime-vscode-extension/issues/35))
- fixed some issues with argument name generation
- fixed missing diagnostics for Haxe errors without positions ([#220](https://github.com/vshaxe/vshaxe/issues/220))
- fixed "initializing completion" not being removed on language server crashes
- fixed const type param regex literals not being highlighted ([haxe-TmLanguage#37](https://github.com/vshaxe/haxe-TmLanguage/issues/37))
- fixed language server not exiting properly in some cases ([haxe-languageserver#34](https://github.com/vshaxe/haxe-languageserver/pull/34))

**Changes and Improvements:**

- added syntax highlighting support for `enum abstract` ([haxe#6982](https://github.com/HaxeFoundation/haxe/issues/6982))
- removed packages from function declarations in hover hints for better readability
- renamed `std` to `haxe` in the dependency explorer

### 1.11.0 (April 9, 2018)

**New Features:**

- added a `$haxe-absolute` problem matcher for errors with absolute paths ([#23](https://github.com/vshaxe/vshaxe/issues/23))
- added a `$haxe-error` problem matcher to add Haxe errors without positions to Problems ([#214](https://github.com/vshaxe/vshaxe/issues/214))
- added a `$haxe-trace` problem matcher to add traces to Problems ([#139](https://github.com/vshaxe/vshaxe/issues/139))
- added a `"haxe.taskPresentation"` setting ([#185](https://github.com/vshaxe/vshaxe/issues/185))
- added `problemMatchers` and `taskPresentation` to the extension API

**Bugfixes:**

- fixed rename errors not being shown in VSCode ([#213](https://github.com/vshaxe/vshaxe/issues/213))
- fixed some issues that could lead to hangs when compiling through the server
- fixed broken highlighting with functions in enum constructor calls ([haxe-TmLanguage#36](https://github.com/vshaxe/haxe-TmLanguage/issues/36))
- fixed most cases of completion being triggered after `case` / `default` ([#112](https://github.com/vshaxe/vshaxe/issues/112))

**Changes and Improvements:**

- improved highlighting of escape sequences in strings ([haxe-TmLanguage#35](https://github.com/vshaxe/haxe-TmLanguage/issues/35))
- clarified the source of problems with `[tasks]` and `[diagnostics]` labels ([#132](https://github.com/vshaxe/vshaxe/issues/132))
- changed task generation to use the additional problem matchers

### 1.10.1 (April 4, 2018)

**Bugfixes:**

- don't include unused `vscode-textmate` in the vshaxe extension package

### 1.10.0 (April 4, 2018)

**New Features:**

- added support for file icon themes in the dependency explorer ([#146](https://github.com/vshaxe/vshaxe/issues/146))
- added a context menu to items in the dependency explorer
- added support for `"haxe.displayPort": "auto"` - enabled by default ([#191](https://github.com/vshaxe/vshaxe/issues/191))
- added a `"haxe.enableCompilationServer"` setting - enabled by default ([#184](https://github.com/vshaxe/vshaxe/issues/184))
- added support for markdown-formatted documentation in signature help
- added `displayPort` and `enableCompilationServer` to the extension API
- added highlighting for Haxe 4's new function type syntax ([HXP-0003](https://github.com/HaxeFoundation/haxe-evolution/blob/master/proposals/0003-new-function-type.md#new-function-type-syntax))
- added code folding support for different region marker styles ([#202](https://github.com/vshaxe/vshaxe/pull/202#issuecomment-376507302))

**Bugfixes:**

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

**Changes and Improvements:**

- changed the required VSCode version to 1.20.0
- the problems view is now opened after global diagnostics runs ([#38](https://github.com/vshaxe/vshaxe/issues/38))
- document symbols now use separate icons for enum members / operators / structs
- document symbols now show type parameters
- the dependency explorer now shows "dev" for `haxelib dev` libraries instead of the full path

### 1.9.3 (November 5, 2017)

**Bugfixes:**

- fixed excessive keyword highlighting in HXML files ([#177](https://github.com/vshaxe/vshaxe/issues/177))

**Changes and Improvements:**

- only show "Haxe Dependencies" in the explorer if vshaxe was activated in the workspace ([#174](https://github.com/vshaxe/vshaxe/issues/174))
- adapt to latest Haxe 4 (development branch) changes

### 1.9.2 (October 24, 2017)

**Bugfixes:**

- fixed [compiler error code actions](https://github.com/vshaxe/vshaxe/wiki/Code-Actions#compiler-error-actions) for indent lengths != 2 ([#168](https://github.com/vshaxe/vshaxe/issues/168))
- fixed completion in workspaces where the selected completion provider doesn't exist anymore
- fixed `package` statement insertion randomly not working ([#172](https://github.com/vshaxe/vshaxe/issues/172))

**Changes and Improvements:**

- added `final` keyword to syntax highlighting

### 1.9.1 (August 16, 2017)

**Bugfixes:**

- fixed the dependency explorer for local haxelib repos ([#162](https://github.com/vshaxe/vshaxe/issues/162))
- fixed some issues with Haxe executable handling ([#163](https://github.com/vshaxe/vshaxe/issues/163), [#166](https://github.com/vshaxe/vshaxe/issues/166))

**Changes and Improvements:**

- added missing compiler metadata identifiers to syntax highlighting

### 1.9.0 (July 21, 2017)

**New Features:**

- added a `"haxe.executable"` setting
- added a task provider for top-level HXML files
- added support for using top-level HXML files as display configurations
- added an extension API enabling Haxe build tools to provide completion ([#18](https://github.com/vshaxe/vshaxe/issues/18))
- added a `Select Completion Provider` command

**Bugfixes:**

- fixed the dependency explorer for `haxelib dev` libs in the haxelib repo ([#141](https://github.com/vshaxe/vshaxe/issues/141))
- fixed the dependency explorer with a relative `"haxe.executable"` path ([#58](https://github.com/vshaxe/vshaxe/issues/58))
- fixed the dependency explorer with invalid classpaths
- fixed a minor anon function highlighting issue ([haxe-TmLanguage#31](https://github.com/vshaxe/haxe-TmLanguage/issues/31))
- fixed renaming `expr` in `case macro $expr:` ([#142](https://github.com/vshaxe/vshaxe/issues/142))
- fixed a regression with duplicated Haxe output channels ([#87](https://github.com/vshaxe/vshaxe/issues/87))
- fixed line break handling in completion docs ([#150](https://github.com/vshaxe/vshaxe/issues/150))

**Changes and Improvements:**

- changed the required VSCode version to 1.14.0
- changed dependency explorer selection to open files permanently on double-click
- added support for `@event` JavaDoc tags in highlighting and completion
- reduced Haxe server restarts to changes of relevant settings ([#153](https://github.com/vshaxe/vshaxe/issues/153))
- greatly simplified the `Initialize VS Code Project` command
- deprecated `"haxe.displayServer"`'s `"haxePath"` / `"env"` in favor of `"haxe.executable"`

### 1.8.0 (June 28, 2017)

**New Features:**

- added a "Haxe Dependencies" view to the explorer
- added support for renaming local variables and parameters ([haxe-languageserver#32](https://github.com/vshaxe/haxe-languageserver/issues/32))

**Bugfixes:**

- fixed a minor string interpolation highlighting issue ([haxe-TmLanguage#27](https://github.com/vshaxe/haxe-TmLanguage/issues/27))
- fixed catch variables not being listed in document symbols
- fixed diagnostics of deleted / renamed files not being removed ([#132](https://github.com/vshaxe/vshaxe/issues/132))

**Changes and Improvements:**

- changed the required VSCode version to 1.13.0
- allowed filtering by path in the display configuration picker
- init project command: replaced `-js` with `--interp` ([#124](https://github.com/vshaxe/vshaxe/issues/124))
- adjusted column index handling to support changes in Haxe 4 ([#134](https://github.com/vshaxe/vshaxe/issues/134))

### 1.7.0 (May 24, 2017)

**Bugfixes:**

- fixed Unicode character handling for completion with Haxe 4
- fixed filtering in metadata completion ([#121](https://github.com/vshaxe/vshaxe/issues/121))

**Changes and Improvements:**

- changed the required VSCode version to 1.12.0
- added a progress indicator for Completion Cache Initialization (#108)
- added a progress indicator for Global Diagnostics Checks
- made document symbols much more robust ([haxe-languageserver#31](https://github.com/vshaxe/haxe-languageserver/issues/31))

### 1.6.0 (May 13, 2017)

**New Features:**

- added highlighting support for Haxe 4 arrow functions ([HXP-0002](https://github.com/HaxeFoundation/haxe-evolution/blob/master/proposals/0002-arrow-functions.md#arrow-functions))
- added a `useArrowSyntax` option for anonymous function generation
- added a "Generate capture variables" code action

**Bugfixes:**

- fixed several small highlighting issues ([haxe-TmLanguage](https://github.com/vshaxe/haxe-TmLanguage)[[#4](https://github.com/vshaxe/haxe-TmLanguage/issues/4), [#6](https://github.com/vshaxe/haxe-TmLanguage/issues/6), [#11](https://github.com/vshaxe/haxe-TmLanguage/issues/11), [#16](https://github.com/vshaxe/haxe-TmLanguage/issues/16), [#22](https://github.com/vshaxe/haxe-TmLanguage/issues/22)])

### 1.5.1 (April 21, 2017)

**Bugfixes:**

- fixed toplevel completion hanging in some cases ([haxe-languageserver#23](https://github.com/vshaxe/haxe-languageserver/pull/23#issuecomment-295468634))

### 1.5.0 (April 7, 2017)

**New Features:**

- added a Haxe problem matcher (referenced with `"problemMatcher": "$haxe"`, VSCode 1.11.0+)

**Changes and Improvements:**

- use the Haxe problem matcher in "Init Project"

**Bugfixes:**

- fixed support for Haxe 4+ (development branch)

### 1.4.0 (International Women's Day, 2017)

**New Features:**

- added a `Toggle Code Lens` command ([#94](https://github.com/vshaxe/vshaxe/issues/94))

**Bugfixes:**

- fixed several small highlighting issues ([haxe-TmLanguage](https://github.com/vshaxe/haxe-TmLanguage)[[#2](https://github.com/vshaxe/haxe-TmLanguage/issues/2), [#5](https://github.com/vshaxe/haxe-TmLanguage/issues/5), [#8](https://github.com/vshaxe/haxe-TmLanguage/issues/8), [#14](https://github.com/vshaxe/haxe-TmLanguage/issues/14), [#15](https://github.com/vshaxe/haxe-TmLanguage/issues/15), [#17](https://github.com/vshaxe/haxe-TmLanguage/issues/17)])
- fixed signature help sometimes not having argument names ([haxe#6064](https://github.com/HaxeFoundation/haxe/issues/6064))
- fixed argument name generation with anon structure types

**Changes and Improvements:**

- diagnostics now update when the active editor is changed
- init project command: `.hxml` files in local haxelib repos are now ignored ([#93](https://github.com/vshaxe/vshaxe/issues/93))
- init project command: moved the comments in the generated `settings.json` to `README.md`
- init project command: added `-D analyzer-optimize` to the generated `build.hxml`
- init project command: a quick pick selection is no longer required with only one `.hxml` file
- init project command: use `version` 2.0.0 in `tasks.json` (VSCode 1.10.0)
- still attempt display requests without any `displayConfigurations` ([#105](https://github.com/vshaxe/vshaxe/issues/105))

### 1.3.3 (February 16, 2017)

**Bugfixes:**

- fixed diagnostics always being filtered if `diagnosticsPathFilter` is set

### 1.3.2 (February 14, 2017)

**Bugfixes:**

- properly handle cancelled requests in the language server (so dead requests don't pile up inside VS Code)

**Changes and Improvements:**

- no longer request diagnostics if `diagnosticsPathFilter` doesn't match

### 1.3.1 (February 9, 2017)

**Bugfixes:**

- fixed invalid argument name generation with type parameters ([haxe-languageserver#28](https://github.com/vshaxe/haxe-languageserver/issues/28))
- fixed inconsistent icon usage in field and toplevel completion
- fixed diagnostics sometimes being reported for the wrong file

**Changes and Improvements:**

- smarter error handling ([#20](https://github.com/vshaxe/vshaxe/issues/20), [haxe-languageserver#20](https://github.com/vshaxe/haxe-languageserver/issues/20))
- ignore hidden files in the "init project" command ([#10](https://github.com/vshaxe/vshaxe/issues/10))
- some minor highlighting improvements ([haxe-TmLanguage#10](https://github.com/vshaxe/haxe-TmLanguage/issues/10))
- added a quick fix for "invalid package" diagnostics
- leading `*` characters are now removed from signature help docs

### 1.3.0 (February 2, 2017)

**New Features:**

- allow generation of anonymous functions in signature completion
- added a `"haxe.codeGeneration"` setting

**Bugfixes:**

- fixed regex highlighting in VSCode 1.9.0
- fixed highlighting of constructor references (`Class.new`)
- fixed highlighting of package names with underscores
- fixed highlighting of comments after conditionals ([haxe-TmLanguage#1](https://github.com/vshaxe/haxe-TmLanguage/issues/1))
- fixed indentation when writing a comment after `}` ([#83](https://github.com/vshaxe/vshaxe/issues/83))
- fixed display requests being attempted with no display config
- fixed toplevel completion with whitespace after `:` ([haxe-languageserver#22](https://github.com/vshaxe/haxe-languageserver/issues/22))
- fixed some compiler errors not being highlighted by diagnostics ([#62](https://github.com/vshaxe/vshaxe/issues/62))

**Changes and Improvements:**

- improved handling of Haxe crashes, e.g. with invalid arguments ([haxe-languageserver#20](https://github.com/vshaxe/haxe-languageserver/issues/20))
- support auto closing and surrounding brackets in hxml files (for `--macro` arguments)

### 1.2.0 (January 23, 2017)

**Bugfixes:**

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

**Changes and Improvements:**

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

**Bugfixes:**

- fixed a highlighting-related crash when typing `static` before a field

### 1.1.0 (January 12, 2017)

**New Features:**

- added proper highlighting for string interpolation ([#26](https://github.com/vshaxe/vshaxe/issues/26))
- added proper highlighting for regex literals
- added proper highlighting for identifiers (method and variable names)
- added highlighting for JavaDoc-tags in block comments (`@param`, `@return` etc)

**Bugfixes:**

- fixed diagnostics not working if project path contains a `'` ([#64](https://github.com/vshaxe/vshaxe/issues/64))
- fixed the import insert position with file header comments ([haxe-languageserver#27](https://github.com/vshaxe/haxe-languageserver/issues/27))
- `$type` is now highlighted as a keyword
- `in` in `for`-loops is now highlighted as a keyword
- fixed `*` in imports being highlighted as a class name
- fixed highlighting for negated conditionals (e.g. `#if !js`)
- fixed highlighting of variable initialization expressions ([#42](https://github.com/vshaxe/vshaxe/issues/42))

### 1.0.1 (December 6, 2016)

**Bugfixes:**

- fixed parsing types of methods with 10+ arguments ([haxe-languageserver#26](https://github.com/vshaxe/haxe-languageserver/issues/26))

### 1.0.0 (December 1, 2016)

**New Features:**

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

**Changes and Improvements:**

- improved code highlighting
- improved handling of unsupported Haxe versions ([#16](https://github.com/vshaxe/vshaxe/issues/16))
