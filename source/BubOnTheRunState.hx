package;

import InputManager.Action;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.addons.display.FlxBackdrop;
import flixel.graphics.frames.FlxBitmapFont;
import flixel.group.FlxGroup;
import flixel.math.FlxPoint;
import flixel.text.FlxBitmapText;
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
	var isGameOver:Bool = false;
	var totalElapsedTime:Float = 0.0;
	var elapsedTimeText:FlxBitmapText;
	var startHud:FlxTypedGroup<FlxSprite>;
	var hud:FlxTypedGroup<FlxSprite>;
	var save:FlxSave;
	var highScore:Float = 0;
	var worldHeight:Int;
	var justTouchedWall:Bool = false;

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

		worldHeight = FlxG.height * 10;

		var ground = new FlxSprite(0, worldHeight / 2).makeGraphic(randomGroundWidth(), GROUND_HEIGHT, Color.PINK);
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

		player = new FlxSprite();
		player.loadGraphic("assets/images/bub-on-the-run/player.png", true, 16, 16);
		player.screenCenter();
		player.animation.add("walk", [2, 3], 7, true);
		player.animation.add("jump", [4]);
		player.animation.add("wall", [5]);
		player.animation.add("dead", [6]);
		player.acceleration.set(ACCEL_X, ACCEL_Y);
		player.maxVelocity.set(MAX_VEL_X, MAX_VEL_Y);
		player.setSize(12, 9);
		player.offset.set(2, 7);
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
		var startBg = new FlxSprite();
		startBg.makeGraphic(FlxG.width, Std.int(FlxG.height), Color.WHITE);
		startHud.add(startBg);
		var titleText = new MimeoText("BUB ON THE RUN");
		titleText.screenCenter();
		titleText.y = 16;
		startHud.add(titleText);
		var premiseText = new MimeoText("outrun ur inner-demons");
		premiseText.screenCenter();
		premiseText.y = titleText.y + titleText.height + 4;
		startHud.add(premiseText);
		var startText = new MimeoText("tap to start");
		startText.screenCenter();
		startText.y = player.y + player.height + 24;
		startText.flicker(0, 0.5);
		startHud.add(startText);
		var highScoreText = new MimeoText('high-score: $highScore' + 's');
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
			if (!isGameOver)
			{
				FlxG.collide(grounds, player);

				handleJump(elapsed);

				if (player.y > worldHeight)
				{
					isGameOver = true;
					FlxG.sound.play("assets/sounds/death.ogg");
					new FlxTimer().start(0.5, function(_) {
						FlxG.camera.flash(Color.WHITE, 0.5, function()
						{
							FlxG.camera.fade(Color.BLACK, 1, false, function()
							{
								if (Std.int(totalElapsedTime) > highScore)
								{
									save.data.highScore = totalElapsedTime;
									save.flush();
								}
								FlxG.resetState();
							});
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

				updateTotalElapsedTime(elapsed);

				animatePlayer();
			}
		}
		else
		{
			if (input.justPressed(CONFIRM))
			{
				FlxG.sound.play("assets/sounds/jump.ogg");
				startHud.kill();
				FlxG.camera.follow(player, FlxCameraFollowStyle.PLATFORMER, 1);
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
		if (isGameOver)
		{
			player.animation.play("dead");
		}
		else if (player.isTouching(FlxObject.WALL))
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
		ground.makeGraphic(randomGroundWidth(), GROUND_HEIGHT, GROUND_COLORS[FlxG.random.int(0, GROUND_COLORS.length - 1)]);
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
	}

	function randomGroundWidth():Int
	{
		return FlxG.random.int(Std.int(FlxG.width / 4), Std.int(FlxG.width * 0.75));
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
