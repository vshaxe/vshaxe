package vshaxe;

import haxe.Timer;
import haxe.crypto.Base64;
import haxe.io.Bytes;

using StringTools;

class ColorDecorations {
	final subscriptions:Array<{function dispose():Void;}> = [];
	final computer:ColorRangeComputer;
	var activeEditor:Null<TextEditor>;
	var updateTimeout:Null<Timer>;
	final decorationTypes:Map<String, TextEditorDecorationType> = [];

	public function new(context:ExtensionContext) {
		computer = new ColorRangeComputer();
		context.subscriptions.push(workspace.onDidChangeTextDocument(e -> {
			if (activeEditor != null && e.document == activeEditor.document) {
				// Delay so if we're getting lots of updates we don't flicker.
				if (updateTimeout != null)
					updateTimeout.stop();
				updateTimeout = Timer.delay(() -> update(), 1000);
			}
		}));
		subscriptions.push(window.onDidChangeActiveTextEditor(e -> {
			setTrackingFile(e);
			update();
		}));
		if (window.activeTextEditor != null) {
			setTrackingFile(window.activeTextEditor);
			update();
		}
	}

	public static function init(context:ExtensionContext):Void {
		var colorDecorations:Null<ColorDecorations> = null;
		final enabled = workspace.getConfiguration("haxe").get("enableGutterColors", false);
		if (enabled) {
			colorDecorations = new ColorDecorations(context);
			context.subscriptions.push(colorDecorations);
		}

		context.subscriptions.push(workspace.onDidChangeConfiguration(_ -> {
			final enabled = workspace.getConfiguration("haxe").get("enableGutterColors", false);
			if (enabled) {
				if (colorDecorations != null)
					return;
				colorDecorations = new ColorDecorations(context);
				context.subscriptions.push(colorDecorations);
			} else {
				if (colorDecorations == null)
					return;
				colorDecorations.dispose();
				context.subscriptions.remove(colorDecorations);
				colorDecorations = null;
			}
		}));
	}

	function update() {
		if (activeEditor == null)
			return;

		final results = computer.compute(activeEditor.document);

		// Each color needs to be its own decoration, so here we update our main list
		// with any new ones we hadn't previously created.
		for (colorHex in results.keys()) {
			final fileData = createImageFile(colorHex);
			final base64Data = Base64.encode(Bytes.ofString(fileData));
			if (fileData != null && decorationTypes[colorHex] == null) {
				decorationTypes[colorHex] = window.createTextEditorDecorationType({
					gutterIconPath: Uri.parse("data:image/svg+xml;base64," + base64Data),
					gutterIconSize: "50%",
				});
			}
		}

		@:nullSafety(Off)
		for (colorHex in decorationTypes.keys()) {
			activeEditor.setDecorations(decorationTypes[colorHex], results[colorHex] ?? []);
		}
	}

	function setTrackingFile(editor:Null<TextEditor>) {
		if (editor != null && editor.document.uri.toString().endsWith(".hx")) {
			activeEditor = editor;
		} else {
			activeEditor = null;
		}
	}

	final svgContents = '<svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 16 16">
		<rect fill="#{HEX-6}" x="0" y="0" width="16" height="16" fill-opacity="{OPACITY}" />
	</svg>';

	function createImageFile(hex:String):String {
		final opacity = (Std.parseInt("0x" + hex.substr(0, 2)) ?? 255) / 255;
		final hex6 = hex.substr(2);
		final imageContents = svgContents.replace("{HEX-6}", hex6).replace("{OPACITY}", '$opacity');
		return imageContents;
	}

	public function dispose():Void {
		if (activeEditor != null) {
			@:nullSafety(Off)
			for (colorHex in decorationTypes.keys())
				activeEditor.setDecorations(decorationTypes[colorHex], []);
		}

		activeEditor = null;
		for (disposable in subscriptions) {
			disposable.dispose();
		}
	}
}

private class ColorRangeComputer {
	final argbHexRegex = ~/0x([A-Fa-f0-9]{8})/g;
	final rgbHexRegex = ~/0x([A-Fa-f0-9]{6})/g;

	public function new() {}

	public function compute(document:TextDocument):Map<String, Array<Range>> {
		var text = document.getText();

		// Build a map of all possible decorations, with those in this file. We need to include all
		// colors so if any were removed, we will clear their decorations.
		final decs:Map<String, Array<Range>> = [];

		text = argbHexRegex.map(text, r -> {
			final colorHex = r.matched(1);
			final p = r.matchedPos();
			if (decs[colorHex] == null)
				decs[colorHex] = [];
			@:nullSafety(Off)
			final group:Array<Range> = decs[colorHex];
			group.push(toRange(document, p.pos, p.len));
			// replace to random value with same length
			return "0xAARRGGBB";
		});
		text = rgbHexRegex.map(text, r -> {
			final colorHex = extractRgbColor(r.matched(1));
			if (colorHex == null)
				return "";
			final p = r.matchedPos();
			if (decs[colorHex] == null)
				decs[colorHex] = [];
			@:nullSafety(Off)
			final group:Array<Range> = decs[colorHex];
			group.push(toRange(document, p.pos, p.len));
			return "0xRRGGBB";
		});

		return decs;
	}

	function toRange(document:TextDocument, offset:Int, length:Int):Range {
		return new Range(document.positionAt(offset), document.positionAt(offset + length));
	}

	function extractRgbColor(input:String):Null<String> {
		return asHex(255) + input;
	}

	function asHexColor(a:Float, r:Float, g:Float, b:Float):String {
		a = clamp(a, 0, 255);
		r = clamp(r, 0, 255);
		g = clamp(g, 0, 255);
		b = clamp(b, 0, 255);
		return '${asHex(a)}${asHex(r)}${asHex(g)}${asHex(b)}'.toLowerCase();
	}

	function asHex(v:Float):String {
		return StringTools.hex(Math.round(v), 2);
	}

	function clamp(v:Float, min:Float, max:Float):Float {
		return Math.min(Math.max(min, v), max);
	}
}
