package;

import Input;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup;
import flixel.system.FlxSound;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxAxes;
import flixel.util.FlxTimer;

using flixel.util.FlxSpriteUtil;

class LonelyPaddleState extends GameState
{
	var walls = new FlxTypedGroup<FlxSprite>(3);
	var star:FlxSprite;
	var player:FlxSprite;
	var ball:FlxSprite;
	var collidables = new FlxGroup();
	var hitSound:FlxSound;
	var ballDeathSound:FlxSound;
	var starSound:FlxSound;
	var timeSinceStar:Float = 0;

	final STAR_DELAY = 10.0;

	final WALL_THICKNESS:Int = 12;
	final PLAYER_VEL:Int = 120;
	final MAX_PLAYER_VEL:Int = 400;
	final BALL_VEL:Int = 120;
	final MAX_BALL_VEL:Int = 400;

	override public function create()
	{
		FlxG.cameras.bgColor = Color.GREEN;

		super.create();

		add(new FlxSprite().loadGraphic("assets/images/lonely-paddle/field.png"));

		var topWall = new FlxSprite(-WALL_THICKNESS / 2, 0);
		topWall.makeGraphic(FlxG.width + WALL_THICKNESS, WALL_THICKNESS, Color.BLUE);
		walls.add(topWall);
		var bottomWall = new FlxSprite(-WALL_THICKNESS / 2, FlxG.height - WALL_THICKNESS);
		bottomWall.makeGraphic(FlxG.width, WALL_THICKNESS + WALL_THICKNESS, Color.BLUE);
		walls.add(bottomWall);
		var rightWall = new FlxSprite(FlxG.width - WALL_THICKNESS, -WALL_THICKNESS / 2);
		rightWall.makeGraphic(WALL_THICKNESS, FlxG.height + WALL_THICKNESS, Color.BLUE);
		walls.add(rightWall);
		
		for (wall in walls)
		{
			wall.solid = true;
			wall.immovable = true;
		}

		add(walls);

		star = new FlxSprite();
		star.loadGraphic("assets/images/lonely-paddle/star.png");
		star.kill();
		add(star);

		player = new FlxSprite(4, 0);
		player.loadGraphic("assets/images/lonely-paddle/paddle.png");
		player.screenCenter(FlxAxes.Y);
		player.solid = true;
		player.immovable = true;
		player.drag.y = MAX_PLAYER_VEL;
		add(player);

		ball = new FlxSprite();
		ball.loadGraphic("assets/images/lonely-paddle/ball.png");
		ball.solid = true;
		ball.elasticity = 1.0;
		ball.maxVelocity.set(MAX_BALL_VEL, MAX_BALL_VEL);
		ball.drag.set(0, 0);
		resetBall();
		add(ball);

		collidables.add(player);
		collidables.add(walls);

		FlxG.worldBounds.set(0, 0, FlxG.width, FlxG.height);

		hitSound = FlxG.sound.load("assets/sounds/crash.ogg");
		ballDeathSound = FlxG.sound.load("assets/sounds/death.ogg");
		starSound = FlxG.sound.load("assets/sounds/jump.ogg");
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);

		if (!star.alive)
		{
			timeSinceStar += elapsed;

			if (timeSinceStar > STAR_DELAY)
			{
				placeStar();
				timeSinceStar = 0;
			}
		}

		if (Input.pressed(Action.UP))
		{
			player.velocity.y = -PLAYER_VEL;
		}
		else if (Input.pressed(Action.DOWN))
		{
			player.velocity.y = PLAYER_VEL;
		}
		else
		{
			player.velocity.y = 0;
		}

		if (player.y < WALL_THICKNESS)
		{
			player.y = WALL_THICKNESS;
		}
		else if (player.y > FlxG.height - WALL_THICKNESS - player.height)
		{
			player.y = FlxG.height - WALL_THICKNESS - player.height;
		}

		FlxG.collide(ball, collidables, ballHitCollidable);
		FlxG.overlap(ball, star, ballHitStar);

		if (!ball.inWorldBounds())
		{
			timeSinceStar = 0;
			ballDeathSound.play();
			new FlxTimer().start(0.4, function(_) {
				ball.velocity.set(0, 0);
				resetBall();
			});
		}
	}

	function resetBall()
	{
		ball.screenCenter();
		ball.flicker(1, 0.08, true, true, function(_) {
			ball.velocity.set(BALL_VEL, BALL_VEL);
		});
	}

	function ballHitStar(_, _)
	{
		starSound.play();
		star.kill();
		timeSinceStar = 0;
	}

	final STAR_POS_MOD = 20;

	function placeStar()
	{
		star.setPosition(
			FlxG.random.int(STAR_POS_MOD, FlxG.width - WALL_THICKNESS - STAR_POS_MOD),
			FlxG.random.int(WALL_THICKNESS + STAR_POS_MOD, FlxG.height - WALL_THICKNESS - STAR_POS_MOD)
		);
		star.revive();
		star.flicker();
	}

	function ballHitCollidable(_ball, _collidable)
	{
		hitSound.play(true);
		scaleTween(_collidable);
		scaleTween(_ball);

		if (_collidable == player)
		{
			var angleModifier = 0;

			if (_ball.y + _ball.origin.y > _collidable.y + _collidable.origin.y)
				angleModifier = -1;
			else if (_ball.y + _ball.origin.y < _collidable.y + _collidable.origin.y)
				angleModifier = 1;

			FlxTween.tween(
				_collidable,
				{ "angle": 10 * angleModifier },
				0.2,
				{ 
					type: FlxTweenType.PINGPONG,
					ease: FlxEase.elasticInOut,
					onComplete: function(tween:FlxTween) {
					  if (tween.executions == 2) {
						  tween.cancel();
					  }
				  }
				}
			);
		}
	}

	function scaleTween(object)
	{
		FlxTween.tween(
			object,
			{ "scale.x": 1.2, "scale.y": 1.2 },
			0.2,
			{ 
				type: FlxTweenType.PINGPONG,
				ease: FlxEase.elasticInOut,
				onComplete: function(tween:FlxTween) {
				  if (tween.executions == 2) {
																													  tween.cancel();
																												  }
			  }
			}
		);
	}
}
