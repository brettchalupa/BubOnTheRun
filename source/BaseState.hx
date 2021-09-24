import Color;
import InputManager;
import flixel.util.FlxColor;
import flixel.FlxState;

class BaseState extends FlxState
{
	var input:InputManager = new InputManager();

	function addText(_text:String, _scale:Float = 1.0, _x:Float = 0, _y:Float = 0, _color:Int = Color.BLACK):MimeoText
	{
		var text = new MimeoText(_text, _color, _scale);
		text.setPosition(_x, _y);
		add(text);
		return text;
	}
}
