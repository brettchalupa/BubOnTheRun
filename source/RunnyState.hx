package;

import InputManager.Action;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.group.FlxGroup;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.util.FlxSort;

using StringTools;

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
	var totalElapsedTime:Float = 0.0;
	var elapsedTimeText:FlxText;

	final MAX_VEL_X = 120;
	final MAX_VEL_Y = 800;
	final ACCEL_X = 160;
	final ACCEL_Y = 900;
	final JUMP_VEL_Y = -140;
	final JUMP_VEL_X = 160;

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
		player.acceleration.set(ACCEL_X, ACCEL_Y);
		player.maxVelocity.set(MAX_VEL_X, MAX_VEL_Y);
		player.setSize(12, 9);
		player.offset.set(2, 7);
		player.solid = true;
		add(player);

		elapsedTimeText = new FlxText(4, 4, 0, "", 14);
		elapsedTimeText.color = Color.BLACK;
		elapsedTimeText.setBorderStyle(OUTLINE, Color.WHITE, 1);
		elapsedTimeText.scrollFactor.set(0, 0);
		updateTotalElapsedTime(0.0);
		add(elapsedTimeText);

		#if debug
		FlxG.debugger.drawDebug;
		FlxG.log.redirectTraces = true;
		FlxG.watch.add(player, "acceleration");
		FlxG.watch.add(player, "velocity");
		FlxG.watch.add(player, "x");
		FlxG.watch.add(player, "y");
		#end

		FlxG.worldBounds.set(0, 0, 100000000, FlxG.height * 2);
		FlxG.camera.follow(player, FlxCameraFollowStyle.TOPDOWN);
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

			updateTotalElapsedTime(elapsed);
		}

		animatePlayer();
	}

	function updateTotalElapsedTime(elapsed:Float)
	{
		totalElapsedTime += elapsed;
		#if debug
		FlxG.watch.addQuick('total elapsed time', totalElapsedTime);
		#end
		elapsedTimeText.text = Std.string(Std.int(totalElapsedTime)).lpad("0", 3) + "s";
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
		{
			jumpTimer = 0;
			player.maxVelocity.x = MAX_VEL_X;
		}

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

		if (jumpTimer > 0 && jumpTimer < 0.25)
		{
			player.maxVelocity.x = JUMP_VEL_X;
			player.velocity.x = JUMP_VEL_X;
			player.velocity.y = JUMP_VEL_Y;
		}
	}
}
