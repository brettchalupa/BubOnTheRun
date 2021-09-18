package;

import InputManager.Action;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.group.FlxGroup;
import flixel.util.FlxColor;
import flixel.util.FlxSort;

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

	var player:FlxSprite;
	var isGameOver:Bool = false;
	var totalElapsedTime:Float;

	override public function create()
	{
		super.create();

		FlxG.cameras.bgColor = Color.BLACK;

		player = new FlxSprite(10, FlxG.height - 30).makeGraphic(4, 10, Color.WHITE);
		player.maxVelocity.set(200, 400);
		player.solid = true;
		add(player);

		FlxG.camera.follow(player, FlxCameraFollowStyle.PLATFORMER);
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);
	}
}
