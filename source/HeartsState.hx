package;

import InputManager.Action;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.text.FlxTypeText;
import openfl.Assets;
import openfl.utils.Assets;

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
	var characterPortrait:FlxSprite;
	var currentlySpeakingText:MimeoText;

	final PORTRAIT_SIZE = 16;

	override public function create()
	{
		super.create();

		addText("Hearts");

		FlxG.cameras.bgColor = 0xff131c1b;

		var scene1 = Assets.getText("assets/data/hearts/scene1.txt");
		lines = scene1.split("\n");

		typeText = new FlxTypeText(8, FlxG.height - 48, FlxG.width - 30, "", 12);

		typeText.delay = 0.1;
		typeText.eraseDelay = 0.2;
		typeText.showCursor = false;
		typeText.autoErase = true;
		typeText.waitTime = 2.0;
		typeText.setTypingVariation(0.75, true);
		typeText.color = Color.WHITE;
		typeText.useDefaultSound = true;
		typeText.paused = true;
		add(typeText);

		currentlySpeakingText = addText("", 12, typeText.x, typeText.y - 12, Color.BLUE);
		currentlySpeakingText.visible = false;

		characterPortrait = new FlxSprite(typeText.x + typeText.width - PORTRAIT_SIZE, typeText.y - PORTRAIT_SIZE);
		characterPortrait.visible = false;
		add(characterPortrait);
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);

		if (input.justPressed(Action.CONFIRM))
		{
			if (typeText.paused)
			{
				var currentLine = lines[currentLine];
				var split = currentLine.split(":");
				var character:String = null;
				var text;
				if (split.length > 1)
				{
					character = split[0];
					text = split.slice(1, split.length).join(":");
				}
				else
				{
					text = split[0];
				}

				typeText.resetText(text);
				if (character != null)
				{
					currentlySpeakingText.text = character;
					currentlySpeakingText.visible = true;
					characterPortrait.loadGraphic('assets/images/hearts/$character.png');
					characterPortrait.visible = true;
				}
				else
				{
					characterPortrait.visible = false;
					currentlySpeakingText.visible = false;
				}

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
