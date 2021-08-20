import Color;
import InputManager;
import flixel.FlxState;
import flixel.math.FlxPoint;
import flixel.text.FlxText;

class BaseState extends FlxState
{
	var input:InputManager = new InputManager();

	function addText(text:String, size:Int = 8, x:Float = 0, y:Float = 0, color:Int = Color.WHITE):FlxText
	{
		var text = new FlxText(x, y, 0, text, size);
		text.font = "Fairfax";
		text.color = color;
		add(text);
		return text;
	}
}
