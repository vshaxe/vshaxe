# Haxe Support for Visual Studio Code

[![CI](https://img.shields.io/github/workflow/status/vshaxe/vshaxe/CI.svg?logo=github)](https://github.com/vshaxe/vshaxe/actions?query=workflow%3ACI) [![Version](https://vsmarketplacebadge.apphb.com/version-short/nadako.vshaxe.svg)](https://marketplace.visualstudio.com/items?itemName=nadako.vshaxe) [![Installs](https://vsmarketplacebadge.apphb.com/installs-short/nadako.vshaxe.svg)](https://marketplace.visualstudio.com/items?itemName=nadako.vshaxe) [![Downloads](https://vsmarketplacebadge.apphb.com/downloads-short/nadako.vshaxe.svg)](https://marketplace.visualstudio.com/items?itemName=nadako.vshaxe) [![Rating](https://vsmarketplacebadge.apphb.com/rating-short/nadako.vshaxe.svg)](https://marketplace.visualstudio.com/items?itemName=nadako.vshaxe) [![](https://img.shields.io/discord/162395145352904705.svg?logo=discord)](https://discord.gg/6qCNtGj)

This is an extension for [Visual Studio Code](https://code.visualstudio.com) that adds support for the [Haxe](http://haxe.org/) language,
leveraging the [Haxe Language Server](https://github.com/vshaxe/haxe-language-server). It works best with the [latest Haxe 4 release](https://haxe.org/download/), but supports any Haxe version starting from 3.4.0.

![demo](images/demo2.gif)

Some framework-specific extensions exist to extend the functionality further:

- If you're using [Lime](http://lime.software/) or [OpenFL](http://www.openfl.org/), you should also install the [Lime extension](https://marketplace.visualstudio.com/items?itemName=openfl.lime-vscode-extension).
- If you're using [Kha](http://kha.tech/), the [Kha Extension Pack](https://marketplace.visualstudio.com/items?itemName=kodetech.kha-extension-pack) should be used.

## Features

This is just a brief overview of the supported features. [**For more details, check out our extensive documentation**](https://github.com/vshaxe/vshaxe/wiki).

- [Syntax Highlighting](https://github.com/vshaxe/haxe-TmLanguage)
- [Tasks](https://github.com/vshaxe/vshaxe/wiki/Tasks) (Tasks -> Run Task...)
- [Debugging](https://github.com/vshaxe/vshaxe/wiki/Debugging) (<kbd>F5</kbd>)
- [Commands](https://github.com/vshaxe/vshaxe/wiki/Commands) (<kbd>F1</kbd> -> search "Haxe")
- [Dependency Explorer](https://github.com/vshaxe/vshaxe/wiki/Dependency-Explorer)
- [Auto Indentation](https://github.com/vshaxe/vshaxe/wiki/Auto-Indentation)
- [Completion](https://github.com/vshaxe/vshaxe/wiki/Completion)
- [Postfix Completion](https://github.com/vshaxe/vshaxe/wiki/Postfix-Completion)
- [Snippets](https://github.com/vshaxe/vshaxe/wiki/Snippets)
- [Code Generation](https://github.com/vshaxe/vshaxe/wiki/Code-Generation)
- [Signature Help](https://github.com/vshaxe/vshaxe/wiki/Signature-Help)
- [Hover Hints](https://github.com/vshaxe/vshaxe/wiki/Hover-Hints)
- [Go to Definition](https://github.com/vshaxe/vshaxe/wiki/Go-to-Definition) (<kbd>F12</kbd>)
- [Go to Type Definition](https://github.com/vshaxe/vshaxe/wiki/Go-to-Type-Definition)
- [Go to Implementations](https://github.com/vshaxe/vshaxe/wiki/Go-to-Implementations) (<kbd>Ctrl</kbd>+<kbd>F12</kbd>)
- [Peek Definition](https://github.com/vshaxe/vshaxe/wiki/Peek-Definition) (<kbd>Alt</kbd>+<kbd>F12</kbd>)
- [Find All References](https://github.com/vshaxe/vshaxe/wiki/Find-All-References) (<kbd>Shift</kbd>+<kbd>Alt</kbd>+<kbd>F12</kbd>)
- [Peek References](https://github.com/vshaxe/vshaxe/wiki/Find-All-References) (<kbd>Shift</kbd>+<kbd>F12</kbd>)
- [Rename Symbol](https://github.com/vshaxe/vshaxe/wiki/Rename-Symbol) (<kbd>F2</kbd>)
- [Document Symbols](https://github.com/vshaxe/vshaxe/wiki/Document-Symbols) (<kbd>Ctrl</kbd>+<kbd>Shift</kbd>+<kbd>O</kbd>)
- [Workspace Symbols](https://github.com/vshaxe/vshaxe/wiki/Workspace-Symbols) (<kbd>Ctrl</kbd>+<kbd>T</kbd>)
- [Outline](https://github.com/vshaxe/vshaxe/wiki/Outline)
- [Folding](https://github.com/vshaxe/vshaxe/wiki/Folding)
- [Diagnostics](https://github.com/vshaxe/vshaxe/wiki/Diagnostics)
- [Code Actions](https://github.com/vshaxe/vshaxe/wiki/Code-Actions) (<kbd>Ctrl</kbd>+<kbd>.</kbd> on light bulbs)
- [Code Lens](https://github.com/vshaxe/vshaxe/wiki/Code-Lens) (<kbd>F1</kbd> -> [Haxe: Toggle Code Lens](https://github.com/vshaxe/vshaxe/wiki/Commands#haxe-toggle-code-lens))
- [Formatting](https://github.com/vshaxe/vshaxe/wiki/Formatting) (<kbd>Shift</kbd>+<kbd>Alt</kbd>+<kbd>F</kbd>)
- [Extension API](https://github.com/vshaxe/vshaxe/wiki/Extension-API)

## Building

For instructions on building/installing from source, please see the dedicated [wiki page.](https://github.com/vshaxe/vshaxe/wiki/Installation)
