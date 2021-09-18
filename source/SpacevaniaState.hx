package;

import InputManager.Action;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.group.FlxGroup;
import flixel.math.FlxAngle;
import flixel.math.FlxVelocity;
import flixel.util.FlxColor;
import flixel.util.FlxDirectionFlags;
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

		var bg = new FlxSprite(0, 0).loadGraphic("assets/images/spacevania-bg.png");
		add(bg);

		player = new FlxSprite(0, 0).makeGraphic(10, 4, Color.WHITE);
		player.screenCenter();
		player.facing = FlxDirectionFlags.UP;
		player.drag.set(DRAG, DRAG);
		player.solid = true;
		add(player);

		FlxG.camera.follow(player, FlxCameraFollowStyle.TOPDOWN);
		FlxG.worldBounds.set(0, 0, FlxG.width, FlxG.height);

		FlxG.watch.add(player, "angle");
		FlxG.watch.add(player, "velocity");
		FlxG.watch.add(player, "acceleration");
	}

	var lastAcceleration = 0.0;

	final MAX_BASE_VEL = 60;
	final MAX_THRUST_VEL = 220;
	final DRAG = 100;
	final THRUST_ACCEL = 180;
	final BASE_ACCEL = 40;
	final BRAKE_ACCEL = -40;
	final ANG_CHANGE_PER_SEC = 2;

	override public function update(elapsed:Float)
	{
		super.update(elapsed);

		var acceleration = lastAcceleration;
		var frameTime = elapsed * FlxG.updateFramerate;
		var maxVel = MAX_BASE_VEL;

		if (input.pressed(Action.UP))
		{
			player.color = Color.PINK;
			acceleration = THRUST_ACCEL * frameTime;
			maxVel = MAX_THRUST_VEL;
		}
		else if (input.pressed(Action.DOWN))
		{
			player.color = Color.ORANGE;
			acceleration = BRAKE_ACCEL * frameTime;
		}
		else
		{
			player.color = Color.WHITE;

			acceleration = BASE_ACCEL * frameTime;
		}

		if (input.pressed(Action.LEFT))
		{
			player.angle -= (ANG_CHANGE_PER_SEC * frameTime);
		}
		else if (input.pressed(Action.RIGHT))
		{
			player.angle += (ANG_CHANGE_PER_SEC * frameTime);
		}

		FlxG.watch.addQuick('update#acceleration', acceleration);
		FlxG.watch.addQuick('update#frameTime', frameTime);

		FlxVelocity.accelerateFromAngle(player, FlxAngle.asRadians(player.angle), acceleration, maxVel, false);
		lastAcceleration = acceleration;
	}
}
