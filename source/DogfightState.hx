package;

import dogfight.Player;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.addons.display.FlxBackdrop;

class DogfightState extends GameState
{
	override function slug():String
	{
		return "dogfight";
	}

	override public function gameType():GameType
	{
		return GameType.DOGFIGHT;
	}

	var player:Player;
	var isGameOver:Bool = false;
	var totalElapsedTime:Float;

	override public function create()
	{
		super.create();

		FlxG.cameras.bgColor = Color.BLACK;

		add(new FlxBackdrop("assets/images/dogfight/bg.png"));

		player = new Player();
		add(player.bullets);
		add(player);

		FlxG.camera.follow(player, FlxCameraFollowStyle.LOCKON);
		FlxG.worldBounds.set(0, 0, FlxG.width, FlxG.height);
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);
	}
}
