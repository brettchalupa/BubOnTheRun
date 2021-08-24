package;

import InputManager.Action;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.text.FlxTypeText;

class HeartsState extends GameState
{
	override function slug():String
	{
		return "hearts";
	}

	override public function gameType():GameType
	{
		return GameType.HEARTS;
	}

	var typeText:FlxTypeText;
	var lines:Array<String>;
	var currentLine = 0;

	override public function create()
	{
		super.create();

		addText("Hearts");

		FlxG.cameras.bgColor = 0xff131c1b;

		lines = [
			"Hello, what are you doing here?",
			"Oh, I see. You want to play a game. Well, let's play a game.",
			"Guess what number I'm thinking..."
		];

		typeText = new FlxTypeText(8, 16, FlxG.width - 30, "", 12, true);

		typeText.delay = 0.1;
		typeText.eraseDelay = 0.2;
		typeText.showCursor = true;
		typeText.cursorBlinkSpeed = 1.0;
		typeText.prefix = "Wolf: ";
		typeText.autoErase = true;
		typeText.waitTime = 2.0;
		typeText.setTypingVariation(0.75, true);
		typeText.color = Color.WHITE;
		typeText.skipKeys = ["SPACE"];
		typeText.useDefaultSound = true;
		typeText.paused = true;

		add(typeText);
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);

		if (input.justPressed(Action.CONFIRM))
		{
			if (typeText.paused)
			{
				typeText.resetText(lines[currentLine]);
				startText();
			}
			else
			{
				typeText.skip();
			}
		}
	}

	function startText()
	{
		typeText.start(0.02, false, false, [], function()
		{
			currentLine++;
			if (currentLine >= lines.length)
			{
				currentLine = 0;
			}
			typeText.paused = true;
		});
	}
}
