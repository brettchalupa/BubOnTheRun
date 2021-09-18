package;

import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxSprite;
import spacevania.Player;

class SpacevaniaState extends GameState
{
	override function slug():String
	{
		return "spacevania";
	}

	override public function gameType():GameType
	{
		return GameType.SPACEVANIA;
	}

	var player:Player;
	var isGameOver:Bool = false;
	var totalElapsedTime:Float;

	override public function create()
	{
		super.create();

		FlxG.cameras.bgColor = Color.BLACK;

		var bg = new FlxSprite(0, 0).loadGraphic("assets/images/spacevania-bg.png");
		add(bg);

		player = new Player(input);
		add(player);
		add(player.bullets);

		FlxG.camera.follow(player, FlxCameraFollowStyle.TOPDOWN);
		FlxG.worldBounds.set(0, 0, FlxG.width, FlxG.height);
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);
	}
}
