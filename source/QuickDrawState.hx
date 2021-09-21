package;

import InputManager.Action;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.util.FlxAxes;
import flixel.util.FlxTimer;

using flixel.util.FlxSpriteUtil;

enum DrawType
{
	ROCK;
	PAPER;
	SCISSORS;
}

enum Outcome
{
	WIN;
	LOSE;
	DRAW;
}

class QuickDrawState extends GameState
{
	override function slug():String
	{
		return "quick-draw";
	}

	override public function gameType():GameType
	{
		return GameType.QUICK_DRAW;
	}

	final DRAW_OPTIONS:Array<DrawType> = [ROCK, PAPER, SCISSORS];
	var rock:FlxSprite;
	var paper:FlxSprite;
	var scissors:FlxSprite;
	var leftArrow:FlxSprite;
	var upArrow:FlxSprite;
	var rightArrow:FlxSprite;
	var drawing:Bool = false;
	var resultsText:MimeoText;
	var playerWins:Int = 0;
	var cpuWins:Int = 0;
	var drawCount:Int = 0;
	var scoresText:MimeoText;

	final PADDING = 2;

	override public function create()
	{
		super.create();

		add(new FlxSprite(0, 0).makeGraphic(FlxG.width, FlxG.height, Color.YELLOW));

		leftArrow = new FlxSprite();
		leftArrow.loadGraphic("assets/images/quick-draw/left-arrow.png");
		leftArrow.screenCenter();
		leftArrow.x -= leftArrow.width;
		add(leftArrow);

		rock = new FlxSprite();
		rock.loadGraphic("assets/images/quick-draw/rock.png");
		rock.setPosition(leftArrow.x - rock.width - PADDING, leftArrow.y);
		add(rock);

		upArrow = new FlxSprite();
		upArrow.loadGraphic("assets/images/quick-draw/up-arrow.png");
		upArrow.screenCenter();
		upArrow.y -= upArrow.height;
		add(upArrow);

		paper = new FlxSprite();
		paper.loadGraphic("assets/images/quick-draw/paper.png");
		paper.setPosition(upArrow.x, upArrow.y - paper.height - PADDING);
		add(paper);

		rightArrow = new FlxSprite();
		rightArrow.loadGraphic("assets/images/quick-draw/right-arrow.png");
		rightArrow.screenCenter();
		rightArrow.x += rightArrow.width;
		add(rightArrow);

		scissors = new FlxSprite();
		scissors.loadGraphic("assets/images/quick-draw/scissors.png");
		scissors.setPosition(rightArrow.x + scissors.width + PADDING, rightArrow.y);
		add(scissors);

		var drawText = addText('QUICK DRAW!', 12, 0, 12, Color.BLACK).screenCenter(FlxAxes.X);

		resultsText = addText('', 12, -1000, -1000);
		resultsText.visible = false;

		scoresText = addText(scoresString(), 12, PADDING);
		scoresText.y = FlxG.height - scoresText.height - (PADDING * 8);
	}

	override public function update(elapsed:Float)
	{
		if (!drawing)
		{
			if (input.justPressed(Action.LEFT))
			{
				doDraw(ROCK);
			}
			else if (input.justPressed(Action.UP))
			{
				doDraw(PAPER);
			}
			else if (input.justPressed(Action.RIGHT))
			{
				doDraw(SCISSORS);
			}
		}

		super.update(elapsed);
	}

	function doDraw(drawType:DrawType)
	{
		drawing = true;
		resultsText.visible = false;
		FlxG.sound.play("assets/sounds/click.wav");

		switch (drawType)
		{
			case ROCK:
				animateOption(rock, leftArrow, drawType);
			case PAPER:
				animateOption(paper, upArrow, drawType);
			case SCISSORS:
				animateOption(scissors, rightArrow, drawType);
		}
	}

	function animateOption(option:FlxSprite, control:FlxSprite, playerDraw:DrawType)
	{
		option.scale.set(2, 2);
		control.scale.set(2, 2);
		new FlxTimer().start(0.1, function(_)
		{
			option.scale.set(1, 1);
			control.scale.set(1, 1);
			handleResults(playerDraw);
		}, 1);
	}

	function handleResults(playerPlayed)
	{
		FlxG.camera.flash(Color.WHITE, 0.75, function()
		{
			var cpuPlayed:DrawType = DRAW_OPTIONS[FlxG.random.int(0, DRAW_OPTIONS.length - 1)];
			renderResultsText(playerPlayed, cpuPlayed);
			drawing = false;
		});
	}

	function renderResultsText(playerPlayed, cpuPlayed)
	{
		var winner = winnerString(determineOutcome(playerPlayed, cpuPlayed));
		resultsText.text = 'Player: $playerPlayed\nCPU: $cpuPlayed\nWinner: $winner';
		resultsText.setPosition(FlxG.width - resultsText.width - PADDING, FlxG.height - resultsText.height - (PADDING * 8));
		resultsText.visible = true;
		scoresText.text = scoresString();
	}

	function winnerString(outcome:Outcome):String
	{
		if (outcome == DRAW)
		{
			drawCount++;
			return "DRAW";
		}
		else if (outcome == WIN)
		{
			playerWins++;
			return "PLAYER";
		}
		else if (outcome == LOSE)
		{
			cpuWins++;
			return "CPU";
		}
		else
		{
			return "";
		}
	}

	function determineOutcome(playerPlayed, cpuPlayed):Outcome
	{
		var outcome:Outcome = DRAW;

		if (playerPlayed == cpuPlayed)
		{
			outcome = DRAW;
		}
		else if (playerPlayed == ROCK)
		{
			if (cpuPlayed == SCISSORS)
			{
				outcome = WIN;
			}
			else if (cpuPlayed == PAPER)
			{
				outcome = LOSE;
			}
		}
		else if (playerPlayed == PAPER)
		{
			if (cpuPlayed == ROCK)
			{
				outcome = WIN;
			}
			else if (cpuPlayed == SCISSORS)
			{
				outcome = LOSE;
			}
		}
		else if (playerPlayed == SCISSORS)
		{
			if (cpuPlayed == PAPER)
			{
				outcome = WIN;
			}
			else if (cpuPlayed == ROCK)
			{
				outcome = LOSE;
			}
		}

		return outcome;
	}

	function scoresString():String
	{
		return 'Player wins: $playerWins\nCPU wins: $cpuWins\nDraws: $drawCount';
	}
}
