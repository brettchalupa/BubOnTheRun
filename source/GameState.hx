package;

import Input.Action;
import flixel.FlxG;
import flixel.FlxState;
import flixel.util.FlxAxes;

class GameState extends FlxState
{
	var game:Game;

	public function new(_game:Game)
	{
		super();
		game = _game;
	}

	override public function create()
	{
		if (game == null)
		{
			for (_game in Reg.games)
			{
				if (_game.state == Type.getClass(this))
					game = _game;
			}
		}

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
