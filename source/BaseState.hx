import Color;
import InputManager;
import flixel.FlxState;

class BaseState extends FlxState
{
	var input:InputManager = new InputManager();

	function addText(_text:String, _size:Int = 12, _x:Float = 0, _y:Float = 0, _color:Int = Color.WHITE):MimeoText
	{
		var text = new MimeoText(_text);
		text.setPosition(_x, _y);
		text.textColor = _color;
		add(text);
		return text;
	}
}
