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

		#if debug
		addChild(new FlxGame(240, 135, RunnyState, 1, 60, 60, true, false));
		#else
		addChild(new FlxGame(240, 135, MenuState, 1, 60, 60, true, false));
		#end

		FlxG.sound.volume = 0.5;

		if (FlxG.mouse != null)
		{
			FlxG.mouse.visible = false;
		}

		FlxAssets.FONT_DEFAULT = "Fairfax";
	}
}
