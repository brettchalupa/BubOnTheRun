package spacevania;

import InputManager.Action;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.group.FlxGroup;
import flixel.math.FlxAngle;
import flixel.math.FlxVelocity;
import flixel.util.FlxColor;
import flixel.util.FlxSort;

class Player extends FlxSprite
{
	public var bullets:FlxTypedGroup<FlxSprite>;

	final MAX_BASE_VEL = 60;
	final MAX_THRUST_VEL = 200;
	final DRAG = 100;
	final THRUST_ACCEL = 160;
	final BASE_ACCEL = 40;
	final BRAKE_ACCEL = -40;
	final ANG_CHANGE_PER_SEC = 2;
	final MAX_BULLETS = 40;
	var lastAcceleration = 0.0;
	var input:InputManager;

	public function new(_input:InputManager)
	{
		super();
		input = _input;
		makeGraphic(10, 4, Color.WHITE);
		screenCenter();
		drag.set(DRAG, DRAG);
		solid = true;

		bullets = new FlxTypedGroup<FlxSprite>(MAX_BULLETS);

		for (i in 0...MAX_BULLETS)
		{
			var bullet = new FlxSprite().makeGraphic(2, 2, Color.WHITE);
			bullet.kill();
			bullets.add(bullet);
		}

		FlxG.watch.add(this, "angle");
		FlxG.watch.add(this, "velocity");
		FlxG.watch.add(this, "acceleration");
	}

	override public function update(elapsed:Float):Void
	{
		trace("player update");
		super.update(elapsed);

		handleInput(elapsed);

		bullets.forEachAlive(function(b)
		{
			if (!b.inWorldBounds())
			{
				b.kill();
			}
		});
	}

	public function handleInput(elapsed:Float)
	{
		handleSteering(elapsed);

		if (input.pressed(Action.CONFIRM))
		{
			fireBullet();
		}
	}

	function fireBullet()
	{
		var bullet = bullets.recycle(FlxSprite);
		bullet.setPosition(getMidpoint().x, getMidpoint().y);
		bullet.velocity.set(velocity.x, velocity.y);
		FlxVelocity.accelerateFromAngle(bullet, FlxAngle.asRadians(angle), 100, 100);
	}

	function handleSteering(elapsed:Float)
	{
		var acceleration = lastAcceleration;
		var frameTime = elapsed * FlxG.updateFramerate;
		var maxVel = MAX_BASE_VEL;
		if (input.pressed(Action.UP))
		{
			color = Color.PINK;
			acceleration = THRUST_ACCEL * frameTime;
			maxVel = MAX_THRUST_VEL;
		}
		else if (input.pressed(Action.DOWN))
		{
			color = Color.ORANGE;
			acceleration = BRAKE_ACCEL * frameTime;
		}
		else
		{
			color = Color.WHITE;
			acceleration = BASE_ACCEL * frameTime;
		}
		if (input.pressed(Action.LEFT))
		{
			angle -= (ANG_CHANGE_PER_SEC * frameTime);
		}
		else if (input.pressed(Action.RIGHT))
		{
			angle += (ANG_CHANGE_PER_SEC * frameTime);
		}
		FlxG.watch.addQuick('update#acceleration', acceleration);
		FlxG.watch.addQuick('update#frameTime', frameTime);
		FlxVelocity.accelerateFromAngle(this, FlxAngle.asRadians(angle), acceleration, maxVel, false);
		lastAcceleration = acceleration;
	}
}
