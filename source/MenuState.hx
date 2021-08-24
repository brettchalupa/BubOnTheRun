package;

import Color;
import GameType;
import InputManager.Action;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.tweens.FlxTween;
import flixel.util.FlxAxes;
import haxe.iterators.StringKeyValueIterator;

class MenuState extends BaseState
{
	var selectedGame:GameState;
	var games:Array<GameState> = [
		new GbloxState(),
		new SlitherState(),
		new DogfightState(),
		new QuickDrawState(),
		new RoyaltyState(),
		new HeartsState()
	];

	override public function new(initialGameType:GameType = HEARTS)
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

		FlxG.sound.pause();

		add(new FlxSprite(0, 0).makeGraphic(FlxG.width, FlxG.height, Color.BLUE));

		addText("Mimeo", 24).screenCenter(FlxAxes.X);

		addText("Select a game", 12, 0, FlxG.height - 12 - 20).screenCenter(FlxAxes.X);

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
		if (input.justReleased(Action.LEFT))
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

		if (input.justReleased(Action.RIGHT))
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
		if (input.justReleased(Action.CANCEL))
		{
			Sys.exit(0);
		}
		#end

		if (input.justReleased(Action.CONFIRM))
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
