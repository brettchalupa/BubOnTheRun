package;

import GameType;
import InputManager.Action;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.util.FlxAxes;

class GameState extends BaseState
{
	public var cover(default, null):FlxSprite;

	override public function create()
	{
		super.create();

		addText(slug(), 12, 6, 6);
	}

	override public function update(elapsed:Float)
	{
		if (input.justReleased(Action.CANCEL))
		{
			FlxG.switchState(new MenuState(gameType()));
		}

		super.update(elapsed);
	}

	public function loadCover():FlxSprite
	{
		cover = new FlxSprite();
		var path = "assets/images/cover-" + slug() + ".png";
		cover.loadGraphic(path);
		cover.screenCenter();
		return cover;
	}

	public function slug():String
	{
		return "game";
	}

	public function gameType():GameType
	{
		return GameType.DEFAULT;
	}
}
