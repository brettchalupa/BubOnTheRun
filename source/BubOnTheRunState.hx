package;

import Input.Action;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.addons.display.FlxBackdrop;
import flixel.graphics.frames.FlxBitmapFont;
import flixel.group.FlxGroup;
import flixel.math.FlxPoint;
import flixel.text.FlxBitmapText;
import flixel.text.FlxText;
import flixel.util.FlxAxes;
import flixel.util.FlxColor;
import flixel.util.FlxSave;
import flixel.util.FlxSort;
import flixel.util.FlxTimer;

using StringTools;
using flixel.util.FlxSpriteUtil;

class BubOnTheRunState extends GameState
{
	override function slug():String
	{
		return "bub-on-the-run";
	}

	override public function gameType():GameType
	{
		return GameType.BUB_ON_THE_RUN;
	}

	var player:FlxSprite;
	var jumpTimer:Float = 0;
	var jumping:Bool = false;
	var grounds:FlxTypedGroup<FlxSprite>;
	var obstacles:FlxTypedGroup<FlxSprite>;
	var isGameOver:Bool = false;
	var totalElapsedTime:Float = 0.0;
	var elapsedTimeText:FlxBitmapText;
	var startHud:FlxTypedGroup<FlxSprite>;
	var hud:FlxTypedGroup<FlxSprite>;
	var save:FlxSave;
	var highScore:Float = 0;
	var worldHeight:Int;
	var justTouchedWall:Bool = false;
	var displayGameOver:Bool = false;
	var startBg:FlxSprite;
	var titleText:MimeoText;
	var startText:MimeoText;
	var premiseText:MimeoText;
	var highScoreText:MimeoText;


	final MAX_VEL_X = 140;
	final MAX_VEL_Y = 800;
	final ACCEL_X = 180;
	final ACCEL_Y = 900;
	final JUMP_VEL_Y = -140;
	final JUMP_VEL_X = 160;
	final GROUND_HEIGHT = 200;
	final GROUND_COLORS = [Color.LIGHT_BLUE, Color.LIGHT_GREEN, Color.ORANGE, Color.PINK, Color.YELLOW];

	override public function create()
	{
		super.create();

		save = new FlxSave();
		save.bind("bub-on-the-run");

		if (save.data.highScore != null)
		{
			highScore = Std.int(save.data.highScore);
		}

		FlxG.cameras.bgColor = Color.BLACK;

		add(new FlxBackdrop("assets/images/bub-on-the-run/bg.png"));
		add(new FlxBackdrop("assets/images/bub-on-the-run/parallax-bg.png", 0.8, 0.8));

		worldHeight = FlxG.height * 10;

		var ground = new FlxSprite(0, worldHeight / 2).makeGraphic(Std.int(FlxG.width * 1.2), GROUND_HEIGHT, Color.PINK);
		ground.immovable = true;
		var ground2 = new FlxSprite(ground.x + ground.width + 20, ground.y).makeGraphic(randomGroundWidth(), GROUND_HEIGHT, Color.GREEN);
		ground2.immovable = true;
		var ground3 = new FlxSprite(ground2.x + ground2.width + 10, ground.y).makeGraphic(randomGroundWidth(), GROUND_HEIGHT, Color.ORANGE);
		ground3.immovable = true;
		var ground4 = new FlxSprite(ground3.x + ground3.width + 40, ground.y).makeGraphic(randomGroundWidth(), GROUND_HEIGHT, Color.YELLOW);
		ground4.immovable = true;

		grounds = new FlxTypedGroup<FlxSprite>();
		grounds.add(ground);
		grounds.add(ground2);
		grounds.add(ground3);
		grounds.add(ground4);
		add(grounds);
		grounds.kill();

		var obstacleSize = 10;
		obstacles = new FlxTypedGroup<FlxSprite>(obstacleSize);
		for (i in 0...obstacleSize)
		{
			var obstacle = new FlxSprite();
			obstacle.kill();
			obstacle.solid = true;
			obstacle.immovable = true;
			obstacles.add(obstacle);
		}
		add(obstacles);

		player = new FlxSprite();
		player.loadGraphic("assets/images/bub-on-the-run/player.png", true, 16, 16);
		player.screenCenter();
		player.animation.add("walk", [2, 3], 7, true);
		player.animation.add("jump", [4]);
		player.animation.add("wall", [5]);
		player.animation.add("dead", [6]);
		player.acceleration.set(ACCEL_X, ACCEL_Y);
		player.maxVelocity.set(MAX_VEL_X, MAX_VEL_Y);
		player.setSize(8, 9);
		player.offset.set(4, 7);
		player.solid = true;
		player.active = false;

		hud = new FlxTypedGroup<FlxSprite>();

		var hudBg = new FlxSprite(0, 0);
		hudBg.makeGraphic(FlxG.width, 16, Color.WHITE);
		hudBg.scrollFactor.set(0, 0);
		hud.add(hudBg);

		elapsedTimeText = new MimeoText("");
		elapsedTimeText.setPosition(4, 4);
		elapsedTimeText.scrollFactor.set(0, 0);
		hud.add(elapsedTimeText);

		var instructionsText = new MimeoText("outrun ur inner-demons");
		instructionsText.y = 4;
		instructionsText.x = FlxG.width - instructionsText.width - 2;
		instructionsText.scrollFactor.set(0, 0);
		hud.add(instructionsText);

		add(hud);
		hud.kill();

		startHud = new FlxTypedGroup<FlxSprite>();
		startBg = new FlxSprite();
		startBg.makeGraphic(FlxG.width, Std.int(FlxG.height), Color.WHITE);
		startHud.add(startBg);
		titleText = new MimeoText("BUB ON THE RUN");
		titleText.screenCenter();
		titleText.y = 16;
		startHud.add(titleText);
		premiseText = new MimeoText("outrun ur inner-demons");
		premiseText.screenCenter();
		premiseText.y = titleText.y + titleText.height + 4;
		startHud.add(premiseText);
		startText = new MimeoText("tap to start");
		startText.screenCenter();
		startText.y = player.y + player.height + 24;
		startText.flicker(0, 0.5);
		startHud.add(startText);
		highScoreText = new MimeoText('high-score: $highScore' + 's');
		highScoreText.screenCenter();
		highScoreText.y = startText.y + startText.height + 12;
		startHud.add(highScoreText);
		for (item in startHud)
		{
			item.scrollFactor.set(0, 0);
		}
		add(startHud);

		updateTotalElapsedTime(0.0);

		add(player);

		FlxG.sound.playMusic("assets/music/botr.ogg", 0.5, true);

		#if debug
		FlxG.debugger.drawDebug;
		FlxG.log.redirectTraces = true;
		FlxG.watch.add(player, "acceleration");
		FlxG.watch.add(player, "velocity");
		FlxG.watch.add(player, "x");
		FlxG.watch.add(player, "y");
		#end
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);

		if (player.active)
		{
			FlxG.collide(grounds, player);
			FlxG.collide(obstacles, player);
			FlxG.collide(obstacles, grounds);

			if (!isGameOver)
			{
				handleJump(elapsed);

				if (player.y > worldHeight || player.isTouching(FlxObject.WALL))
				{
					isGameOver = true;
					new FlxTimer().start(0.33, function(_) {
						FlxG.sound.play("assets/sounds/death.ogg");
						player.animation.play("dead");
						FlxG.camera.flash(Color.WHITE, 1.2, function()
						{
							handleGameOver();
						});
					}, 1);
				}

				for (ground in grounds)
				{
					if ((ground.x + ground.width < player.x) && !ground.isOnScreen(FlxG.camera))
					{
						positionGround(ground);
					}
				}

				for (obstacle in obstacles)
				{
					if ((obstacle.x + obstacle.width < player.x) && !obstacle.isOnScreen(FlxG.camera))
						obstacle.kill();
				}

				updateTotalElapsedTime(elapsed);

				animatePlayer();
			}
			else if (displayGameOver)
			{
				if (Input.justPressed(CONFIRM))
				{
					FlxG.sound.play("assets/sounds/jump.ogg");
					FlxG.camera.fade(Color.BLACK, 1, false, function()
					{
						FlxG.resetState();
					});
				}
			}
		}
		else
		{
			if (Input.justPressed(CONFIRM))
			{
				FlxG.sound.play("assets/sounds/jump.ogg");
				startHud.kill();
				FlxG.camera.follow(player, FlxCameraFollowStyle.PLATFORMER, 1);
				var dz = FlxG.camera.deadzone;
				dz.height *= 1.5;
				FlxG.camera.deadzone = dz;
				player.setPosition(grounds.members[0].x + 40, grounds.members[0].y - 80);
				player.visible = false;

				FlxG.camera.flash(Color.WHITE, 1, function()
				{
					FlxG.worldBounds.set(0, 0, 100000000, worldHeight);
					grounds.revive();
					hud.revive();
					player.active = true;
					player.visible = true;
				});
			}
		}
	}

	function handleGameOver()
	{
		displayGameOver = true;

		grounds.kill();
		startHud.revive();

		player.velocity.set(0, 0);
		player.acceleration.set(0, 0);
		FlxG.camera.setPosition(0, 0);
		FlxG.camera.color = FlxColor.TRANSPARENT;
		player.setPosition(FlxG.camera.width / 2 - player.width / 2 + 16, FlxG.camera.height / 2 - player.height / 2 + 8);

		var newHighScore = false;
		var newScore = Std.int(totalElapsedTime);

		if (newScore > highScore)
		{
			newHighScore = true;
			save.data.highScore = newScore;
			save.flush();
		}

		titleText.text = "GAME OVER";
		titleText.screenCenter(FlxAxes.X);

		if (newHighScore)
			premiseText.text = "nice work\nur doin' better!";
		else
			premiseText.text = "keep on trying!!";

		startText.text = "tap to restart";
		startText.screenCenter();

		premiseText.screenCenter();
		premiseText.y = startText.y + startText.height + 8;

		if (newHighScore)
			highScoreText.text = 'new high-score: $newScore' + "s\n" + 'previous high-score: $highScore' + 's';
		else
			highScoreText.text = 'ur score: $newScore' + "s\n" + 'high-score: $highScore' + "s";
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

			if (!justTouchedWall)
			{
				FlxG.sound.play("assets/sounds/crash.ogg");
			}
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

		if (player.isTouching(FlxObject.WALL))
			justTouchedWall = true;
		else
			justTouchedWall = false;
	}

	function positionGround(ground:FlxSprite)
	{
		grounds.sort(function(order, obj1, obj2)
		{
			return FlxSort.byValues(order, obj1.x, obj2.x);
		}, FlxSort.ASCENDING);
		var lastGround = grounds.members[grounds.length - 1];
		ground.makeGraphic(randomGroundWidth(), GROUND_HEIGHT, randomGroundColor());
		ground.updateHitbox();
		ground.x = lastGround.x + lastGround.width + FlxG.random.int(20, 80);
		var newGroundY = lastGround.y - FlxG.random.int(-30, 30);

		if (newGroundY > worldHeight - 60)
		{
			ground.y = lastGround.y - 30;
		}
		else if (newGroundY < 100)
		{
			ground.y = lastGround.y + 30;
		}
		else
		{
			ground.y = newGroundY;
		}

		if (FlxG.random.bool(50)) {
			addObstacleToGround(ground);
		}
	}

	function randomGroundColor():FlxColor
	{
		return cast(GROUND_COLORS[FlxG.random.int(0, GROUND_COLORS.length - 1)], FlxColor);
	}

	function addObstacleToGround(ground:FlxSprite)
	{
		var size = FlxG.random.int(8, 12);
		var obstacle = obstacles.recycle(FlxSprite);
		obstacle.makeGraphic(size, size, randomGroundColor());
		var randomX = FlxG.random.int(Std.int(ground.x + (size * 1.5)), Std.int(ground.x + ground.width - (size * 1.5)));
		obstacle.setPosition(randomX, ground.y - size);
	}

	function randomGroundWidth():Int
	{
		return FlxG.random.int(Std.int(FlxG.width / 3), Std.int(FlxG.width * 1.25));
	}

	function handleJump(elapsed:Float)
	{
		var jumpPressed:Bool = Input.pressed(Action.CONFIRM);

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
				FlxG.sound.play("assets/sounds/jump.ogg");
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
