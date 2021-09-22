package;

import Color;
import GameType;
import InputManager.Action;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.tweens.FlxTween;
import flixel.util.FlxAxes;

class MenuState extends BaseState
{
	var selectedGame:GameState;

	#if debug
	var games:Array<GameState> = [
		new GbloxState(),
		new SlitherState(),
		new DogfightState(),
		new QuickDrawState(),
		new RoyaltyState(),
		new HeartsState(),
		new BubOnTheRunState(),
		new SpacevaniaState(),
		new BulletHeckState()
	];
	#else
	var games:Array<GameState> = [
		new SlitherState(),
		new QuickDrawState(),
		new HeartsState(),
		new BubOnTheRunState(),
		new SpacevaniaState(),
		new BulletHeckState()
	];
	#end

	override public function new(initialGameType:GameType = BUB_ON_THE_RUN)
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
		if (FlxG.sound.music != null)
		{
			FlxG.sound.music.stop();
		}

		add(new FlxSprite(0, 0).makeGraphic(FlxG.width, FlxG.height, Color.BLUE));

		var title = addText("MIMEO");
		title.scale.set(2, 2);
		title.updateHitbox();
		title.setPosition(0, 16);
		title.screenCenter(FlxAxes.X);

		addText("Select a game", 12, 0, FlxG.height - 28).screenCenter(FlxAxes.X);

		var versionText = addText("r" + Reg.version);
		versionText.scale.set(0.5, 0.5);
		versionText.updateHitbox();
		versionText.setPosition(FlxG.width - versionText.width, FlxG.height - versionText.height);

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
			FlxG.sound.play("assets/sounds/click.ogg");

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
			FlxG.sound.play("assets/sounds/click.ogg");
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
