package;

import flixel.FlxG;
import flixel.FlxGame;
import flixel.system.FlxAssets;
import openfl.display.Sprite;

#if debug
import openfl.display.FPS;
#end

class Main extends Sprite
{
	public function new()
	{
		super();

		Reg.loadGames();

		addChild(new FlxGame(240, 135, BubOnTheRunState, 3, 60, 60, true, false));

		#if debug
		addChild(new FPS(4, 512, Color.WHITE));
		#end

		FlxG.sound.volume = 0.5;

		if (FlxG.mouse != null)
		{
			FlxG.mouse.visible = false;
		}
	}
}
