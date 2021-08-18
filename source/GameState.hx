package;

import GameType;
import InputManager.Action;
import flixel.FlxG;
import flixel.FlxSprite;

class GameState extends BaseState
{
	public var cover(default, null):FlxSprite;

	override public function create()
	{
		super.create();

		var text = new flixel.text.FlxText(0, 4, 0, slug(), 12);
		text.screenCenter();
		text.font = "Fairfax";
		add(text);
	}

	override public function update(elapsed:Float)
	{
		if (input.released(Action.CANCEL))
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
