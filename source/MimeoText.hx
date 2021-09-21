package;

import flixel.graphics.frames.FlxBitmapFont;
import flixel.math.FlxPoint;
import flixel.text.FlxBitmapText;

class MimeoText extends FlxBitmapText
{
	static final CHARS:String = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz1234567890+-=/\\*:;()[]{}<>!?.,'\"&¡#%^~±`||$¢£™•¥@§©_";

	static var FONT:FlxBitmapFont;

	public static function loadFont()
	{
		FONT = FlxBitmapFont.fromMonospace("assets/fonts/mono.png", CHARS, FlxPoint.get(6, 9));
	}

	public override function new(_text:String)
	{
		if (FONT == null)
		{
			loadFont();
		}

		super(FONT);
		text = _text;
	}
}
