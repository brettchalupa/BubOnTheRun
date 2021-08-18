package;

import GameType;
import InputManager.Action;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.text.FlxText;
import flixel.tweens.FlxTween;
import flixel.util.FlxAxes;
import flixel.util.FlxColor;

class MenuState extends BaseState
{
	var selectedGame:GameState;
	var games:Array<GameState> = [new GbloxState(), new SlitherState(), new DogfightState()];

	override public function new(initialGameType:GameType = GBLOX)
	{
		for (game in games)
		{
			if (game.gameType() == initialGameType)
				selectedGame = game;
		}
		super();
	}

	override public function create()
	{
		super.create();

		add(new FlxSprite(0, 0).makeGraphic(FlxG.width, FlxG.height, FlxColor.PINK));

		var title = new FlxText(0, 4, 0, "Mimeo", 24);
		title.font = "Fairfax";
		title.screenCenter(FlxAxes.X);
		add(title);

		var help = new FlxText(0, FlxG.height - 12 - 20, 0, "Select a game", 12);
		help.font = "Fairfax";
		help.screenCenter(FlxAxes.X);
		add(help);

		for (game in games)
		{
			add(game.loadCover());
		}

		var caret = new FlxSprite();
		caret.loadGraphic("assets/images/caret.png");
		caret.screenCenter(FlxAxes.X);
		caret.y = selectedGame.cover.y + selectedGame.cover.height + 5;
		FlxTween.tween(caret, {y: caret.y + 2.0}, 0.5, {
			type: FlxTweenType.PINGPONG
		});
		add(caret);

		positionGames();
	}

	override public function update(elapsed:Float)
	{
		if (input.released(Action.LEFT))
		{
			var index = games.indexOf(selectedGame);
			index = index - 1;
			if (index < 0)
			{
				index = games.length - 1;
			}
			selectedGame = games[index];
			FlxG.sound.play(AssetPaths.click__wav);
			positionGames();
		}

		if (input.released(Action.RIGHT))
		{
			var index = games.indexOf(selectedGame);
			index = index + 1;
			if (index >= games.length)
			{
				index = 0;
			}
			selectedGame = games[index];
			FlxG.sound.play(AssetPaths.click__wav);
			positionGames();
		}

		#if desktop
		if (input.released(Action.CANCEL))
		{
			Sys.exit(0);
		}
		#end

		if (input.released(Action.CONFIRM))
		{
			FlxG.switchState(selectedGame);
		}
		super.update(elapsed);
	}

	private function positionGames()
	{
		for (game in games)
		{
			var index = games.indexOf(game);
			var cover = game.cover;
			cover.screenCenter();
			cover.x = cover.x + (cover.width + 10) * (index - games.indexOf(selectedGame));
		}
	}
}
