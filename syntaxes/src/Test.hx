import sys.FileSystem;
import sys.io.File;
using StringTools;

import Build.GENERATED_DIR;

// ported and adapted from https://github.com/Microsoft/TypeScript-TmLanguage
class Test {
    static inline var BASELINES_DIR = "baselines";

    static function main() {
        var hasError = false;
        for (file in FileSystem.readDirectory(GENERATED_DIR)) {
            var generatedText = File.getContent('$GENERATED_DIR/$file');
            var baselinesText = File.getContent('$BASELINES_DIR/$file');
            if (removeNewlines(generatedText) != removeNewlines(baselinesText)) {
                hasError = true;
                Sys.println('File $file is not the same as the baseline!');
            }
        }
        if (hasError)
            Sys.exit(1);
        Sys.println("Test done.");
    }

    static function removeNewlines(text:String):String {
        return text.replace('\r\n', '').replace('\n', '');
    }
}
