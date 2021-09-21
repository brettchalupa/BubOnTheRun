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

using StringTools;
using flixel.util.FlxSpriteUtil;

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
	var elapsedTimeText:FlxBitmapText;
	var startHud:FlxTypedGroup<FlxSprite>;
	var hud:FlxTypedGroup<FlxSprite>;
	var save:FlxSave;
	var highScore:Float = 0;

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
		save.bind("runny");

		if (save.data.highScore != null)
		{
			highScore = Std.int(save.data.highScore);
		}

		FlxG.cameras.bgColor = Color.BLACK;

		add(new FlxBackdrop("assets/images/runny/bg.png"));

		var ground = new FlxSprite(0, FlxG.height - 10).makeGraphic(randomGroundWidth(), GROUND_HEIGHT, Color.PINK);
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
		player.loadGraphic("assets/images/runny/player.png", true, 16, 16);
		player.screenCenter();
		player.animation.add("walk", [2, 3], 7, true);
		player.animation.add("jump", [4]);
		player.animation.add("wall", [5]);
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
		startText.y = player.y + player.height + 12;
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

				if (player.y > (FlxG.height * 2))
				{
					isGameOver = true;
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
				startHud.kill();
				FlxG.camera.follow(player, FlxCameraFollowStyle.PLATFORMER, 1);
				player.setPosition(10, FlxG.height - 70);
				player.visible = false;

				FlxG.camera.flash(Color.WHITE, 1, function()
				{
					FlxG.worldBounds.set(0, 0, 100000000, FlxG.height * 2);
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
		ground.setGraphicSize(randomGroundWidth(), GROUND_HEIGHT);
		ground.updateHitbox();
		ground.color = GROUND_COLORS[FlxG.random.int(0, GROUND_COLORS.length - 1)];
		ground.x = lastGround.x + lastGround.width + FlxG.random.int(20, 80);
		ground.y = lastGround.y - FlxG.random.int(-30, 30);
	}

	function randomGroundWidth():Int
	{
		return FlxG.random.int(Std.int(FlxG.width / 3), Std.int(FlxG.width * 0.75));
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
				FlxG.sound.play("assets/sounds/click.wav");
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
