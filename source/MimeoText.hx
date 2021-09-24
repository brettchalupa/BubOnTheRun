package;

import flixel.graphics.frames.FlxBitmapFont;
import flixel.math.FlxPoint;
import flixel.text.FlxBitmapText;
import flixel.util.FlxColor;

class MimeoText extends FlxBitmapText
{
	static final CHARS:String = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz1234567890+-=/\\*:;()[]{}<>!?.,'\"&¡#%^~±`||$¢£™•¥@§©_";

	static var FONT:FlxBitmapFont;
	
	/* textColor multiplies itself by color, so this calculates the 1 val for RGB to multiply by and get itself */
	static final COLOR_ONE = FlxColor.fromRGB(1, 1, 1);

	public static function loadFont()
	{
		FONT = FlxBitmapFont.fromMonospace("assets/fonts/mono.png", CHARS, FlxPoint.get(6, 9));
	}

	public function new(_text:String, _color:Int = Color.BLACK, _scale:Float = 1.0)
	{
		if (FONT == null)
		{
			loadFont();
		}

		super(FONT);

		text = _text;
		color = COLOR_ONE;
		useTextColor = true;
		textColor = _color;
		scale.set(_scale, _scale);
		width = width;
		updateHitbox();
	}
}
