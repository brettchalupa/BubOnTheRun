package;

import flixel.FlxG;
import flixel.FlxGame;
import flixel.system.FlxAssets;
import openfl.display.Sprite;

class Main extends Sprite
{
	public function new()
	{
		super();
		addChild(new FlxGame(240, 160, MenuState, 1, 60, 60, true, false));

		if (FlxG.mouse != null)
		{
			FlxG.mouse.visible = false;
		}

		FlxAssets.FONT_DEFAULT = "Fairfax";
	}
}
