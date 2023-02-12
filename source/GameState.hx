package;

import Input.Action;
import flixel.FlxG;
import flixel.FlxState;
import flixel.util.FlxAxes;
import flixel.util.FlxSave;

class GameState extends FlxState
{
	var game:Game;
	var save:FlxSave;

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

		save = new FlxSave();
		save.bind(game.slug);

		super.create();
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);
	}
}
