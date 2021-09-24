package;

import InputManager.Action;
import flixel.FlxG;
import flixel.FlxSprite;
import openfl.utils.Assets;

using StringTools;

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

	var lines:Array<String>;
	var currentLineIndex:Int = 0;
	var characterPortrait:FlxSprite;
	var currentlySpeakingText:MimeoText;
	var dialogueText:MimeoText;

	final PORTRAIT_SIZE = 16;

	override public function create()
	{
		super.create();

		var title = new MimeoText("Cutscene Prototype", Color.BLACK, 2);
		title.setPosition(8, 8);
		add(title);

		FlxG.cameras.bgColor = Color.WHITE;

		var scene1 = Assets.getText("assets/data/hearts/scene1.txt");
		lines = scene1.split("\n");

		var dialogueBg = new FlxSprite(0, 0);
		dialogueBg.makeGraphic(FlxG.width - 12, 26, Color.LIGHT_BLUE);
		dialogueBg.screenCenter();
		dialogueBg.y = FlxG.height - dialogueBg.height - 4;
		add(dialogueBg);
		dialogueText = new MimeoText("Hi!");
		dialogueText.autoSize = false;
		dialogueText.setPosition(dialogueBg.x + 4, dialogueBg.y + 4);
		dialogueText.wordWrap = true;
		dialogueText.lineSpacing = 1;
		dialogueText.fieldWidth = Std.int(dialogueBg.width - 4);
		add(dialogueText);

		currentlySpeakingText = new MimeoText("", Color.BLUE, 1, dialogueBg.x + 4, dialogueBg.y - 10);
		currentlySpeakingText.visible = false;
		add(currentlySpeakingText);

		characterPortrait = new FlxSprite(dialogueBg.x + dialogueBg.width - PORTRAIT_SIZE - 4, dialogueBg.y - PORTRAIT_SIZE);
		characterPortrait.visible = false;
		add(characterPortrait);

		renderNextLine();
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);

		if (input.justPressed(Action.CONFIRM))
		{
			FlxG.sound.play("assets/sounds/crash.ogg");
			renderNextLine();
		}
	}

	function renderNextLine()
	{
		var line = lines[currentLineIndex];
		var split = line.split(":");
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

		dialogueText.text = text.trim();
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

		currentLineIndex++;
		if (currentLineIndex >= lines.length)
		{
			currentLineIndex = 0;
		}
	}
}
