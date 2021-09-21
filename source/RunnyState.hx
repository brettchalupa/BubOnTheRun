package;

import InputManager.Action;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.group.FlxGroup;
import flixel.util.FlxColor;
import flixel.util.FlxSort;

class RunnyState extends GameState
{
	override function slug():String
	{
		return "runny";
	}

	override public function gameType():GameType
	{
		return GameType.RUNNY;
	}

	var player:FlxSprite;
	var jumpTimer:Float = 0;
	var jumping:Bool = false;
	var grounds:FlxTypedGroup<FlxSprite>;
	var isGameOver:Bool = false;
	var totalElapsedTime:Float;

	override public function create()
	{
		super.create();

		FlxG.cameras.bgColor = Color.PURPLE;

		var ground = new FlxSprite(0, FlxG.height - 10).makeGraphic(Std.int(FlxG.width / 2), 10, Color.PINK);
		ground.immovable = true;

		var ground2 = new FlxSprite(ground.x + ground.width + 20, FlxG.height - 10).makeGraphic(Std.int(FlxG.width / 2), 10, Color.GREEN);
		ground2.immovable = true;

		var ground3 = new FlxSprite(ground2.x + ground2.width + 20, FlxG.height - 10).makeGraphic(Std.int(FlxG.width / 2), 10, Color.ORANGE);
		ground3.immovable = true;

		var ground4 = new FlxSprite(ground3.x + ground3.width + 20, FlxG.height - 10).makeGraphic(Std.int(FlxG.width / 2), 10, Color.YELLOW);
		ground4.immovable = true;

		grounds = new FlxTypedGroup<FlxSprite>();
		grounds.add(ground);
		grounds.add(ground2);
		grounds.add(ground3);
		grounds.add(ground4);
		add(grounds);

		player = new FlxSprite(10, FlxG.height - 30);
		player.loadGraphic("assets/images/runny/player.png", true, 16, 16);
		player.animation.add("walk", [2, 3], 5, true);
		player.animation.add("jump", [4]);
		player.animation.add("wall", [5]);
		player.acceleration.set(100, 900);
		player.maxVelocity.set(200, 400);
		player.setSize(12, 9);
		player.offset.set(2, 7);
		player.solid = true;
		add(player);

		FlxG.worldBounds.set(0, 0, 10000000, FlxG.height * 2);

		FlxG.camera.follow(player, FlxCameraFollowStyle.PLATFORMER);
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);

		if (!isGameOver)
		{
			FlxG.collide(grounds, player);

			handleJump(elapsed);

			if (player.y > (FlxG.height * 2))
			{
				isGameOver = true;
				FlxG.camera.flash(Color.WHITE, 0.5, function()
				{
					FlxG.camera.fade(Color.BLACK, 1, false, function()
					{
						FlxG.resetState();
					});
				});
			}

			for (ground in grounds)
			{
				if (ground.x + ground.width < player.x - FlxG.camera.width / 2)
				{
					positionGround(ground);
				}
			}
		}

		animatePlayer();
	}

	function animatePlayer()
	{
		if (player.isTouching(FlxObject.WALL))
		{
			player.animation.play("wall");
		}
		else if (player.isTouching(FlxObject.FLOOR))
		{
			if (player.velocity.x == 0)
			{
				player.animation.play("idle");
			}
			else
			{
				player.animation.play("walk");
			}
		}
		else
		{
			player.animation.play("jump");
		}
	}

	function positionGround(ground:FlxSprite)
	{
		grounds.sort(function(order, obj1, obj2)
		{
			return FlxSort.byValues(order, obj1.x, obj2.x);
		}, FlxSort.ASCENDING);
		var lastGround = grounds.members[grounds.length - 1];
		ground.x = lastGround.x + lastGround.width + FlxG.random.int(20, 40);
	}

	function handleJump(elapsed:Float)
	{
		var jumpPressed:Bool = input.pressed(Action.CONFIRM);

		if (jumping && !jumpPressed)
			jumping = false;

		if (player.isTouching(FlxObject.DOWN) && !jumping)
			jumpTimer = 0;

		if (jumpTimer >= 0 && jumpPressed)
		{
			jumping = true;
			if (jumpTimer == 0)
				FlxG.sound.play(AssetPaths.click__wav);
			jumpTimer += elapsed;
		}
		else
		{
			jumpTimer = -1;
		}

		if (jumpTimer > 0 && jumpTimer < 0.50)
			player.velocity.y = ((player.velocity.x * 1.1 / 10 * 4) + 200) * -1;
	}
}
