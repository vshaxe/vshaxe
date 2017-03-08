# Haxe project

This is an example Haxe project scaffolded by Visual Studio Code.

Without further changes the structure is following:

 * `.vscode/settings.json`: VS Code workspace configuration
 * `.vscode/tasks.json`: VS Code build task configuration
 * `src/Main.hx`: Entry point Haxe source file
 * `build.hxml`: Haxe command line file used to build the project
 * `README.md`: This file

Build output:

 * `main.js`: JavaScript file, generated when building the project

Some notes on `.vscode/settings.json`:

  - This file contains the configurations for completion.

  - Each configuration is an array of arguments that will be passed to the Haxe completion server. They should only contain arguments and/or hxml files that are needed for completion such as `-cp`, `-lib`, target output settings and defines.

  - If a hxml file is safe to use (like the default `build.hxml`), we can just pass it as argument like so:

    ```json
    "haxe.displayConfigurations": [
        ["build.hxml"]
    ]
    ```