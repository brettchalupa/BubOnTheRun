package;

import Input.Action;
import flixel.FlxG;
import flixel.FlxState;
import flixel.util.FlxAxes;

class GameState extends FlxState
{
	final game:Game;

	public function new(_game:Game)
	{
		super();
		game = _game;
	}

	override public function create()
	{
		super.create();
	}

	override public function update(elapsed:Float)
	{
		if (Input.justReleased(Action.CANCEL))
		{
			FlxG.switchState(new MenuState(game.slug));
		}

		super.update(elapsed);
	}
}
