package dogfight;

import InputManager.Action;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.group.FlxGroup;
import flixel.math.FlxAngle;
import flixel.math.FlxPoint;
import flixel.math.FlxVelocity;
import flixel.math.FlxVelocity;
import flixel.util.FlxColor;
import flixel.util.FlxSort;

class Player extends FlxSprite
{
	public var bullets:FlxTypedGroup<FlxSprite>;

	final MAX_BASE_VEL = 70;
	final MAX_THRUST_VEL = 160;
	final THRUST_ACCEL = 120;
	final BASE_ACCEL = 50;
	final BRAKE_ACCEL = -40;
	final ANG_CHANGE_PER_SEC = 3;
	final MAX_BULLETS = 40;
	final SHOT_COOLDOWN = 0.25;
	var lastAcceleration = 0.0;
	var input:InputManager;
	var timeSinceLastShot:Float = 0.0;
	var thrust:Float = 0.0;
	final MAX_ANGULAR = 120;
	final ANGULAR_DRAG = 420;
	final DRAG = 3;

	public function new(_input:InputManager)
	{
		super();
		input = _input;
		loadGraphic("assets/images/dogfight/player.png", 16);
		screenCenter();
		drag.set(DRAG, DRAG);
		setSize(6, 6);
		centerOffsets();
		solid = true;

		maxAngular = MAX_ANGULAR;
		angularDrag = ANGULAR_DRAG;
		drag.x = DRAG;

		bullets = new FlxTypedGroup<FlxSprite>(MAX_BULLETS);

		for (i in 0...MAX_BULLETS)
		{
			var bullet = new FlxSprite().loadGraphic("assets/images/dogfight/bullet.png", 16);
			bullet.setSize(1, 2);
			bullet.kill();
			bullets.add(bullet);
		}

		#if debug
		FlxG.watch.add(this, "angle");
		FlxG.watch.add(this, "velocity");
		FlxG.watch.add(this, "acceleration");
		#end
	}

	override public function update(elapsed:Float):Void
	{
		handleInput(elapsed);

		bullets.forEachAlive(function(b)
		{
			if (!b.inWorldBounds())
			{
				b.kill();
			}
		});

		super.update(elapsed);
	}

	public function handleInput(elapsed:Float)
	{
		handleSteering(elapsed);

		if (input.pressed(Action.CONFIRM) && timeSinceLastShot >= SHOT_COOLDOWN)
		{
			timeSinceLastShot = 0.0;
			FlxG.sound.play("assets/sounds/click.ogg");
			fireBullet();
		}
		else
		{
			timeSinceLastShot += elapsed;
		}
	}

	function fireBullet()
	{
		var bullet = bullets.recycle(FlxSprite);
		bullet.setPosition(getMidpoint().x, getMidpoint().y);
		bullet.angle = angle;
		bullet.velocity.set(0, -100);
		bullet.velocity.rotate(FlxPoint.weak(0, 0), bullet.angle);
	}

	function handleSteering(elapsed:Float)
	{
		if (input.pressed(Action.LEFT))
		{
			angularAcceleration = -angularDrag;
		}
		else if (input.pressed(Action.RIGHT))
		{
			angularAcceleration = angularDrag;
		}
		else
		{
			angularAcceleration = 0;
		}

		var _up:Bool = false;
		var _down:Bool = false;

		if (input.pressed(Action.UP))
		{
			color = Color.PINK;
			_up = true;
		}
		else
		{
			color = Color.WHITE;
		}

		thrust = FlxVelocity.computeVelocity(thrust, (_up ? 90 : 0), drag.x, 60, elapsed);
		velocity.set(0, -thrust);
		velocity.rotate(FlxPoint.weak(0, 0), angle);
	}
}
