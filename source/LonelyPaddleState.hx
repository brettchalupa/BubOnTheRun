package;

import Input;
import flixel.FlxG;
import flixel.FlxObject;
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
	static inline final MAX_BALLS:Int = 100;
	static inline final MAX_BUDDIES:Int = 20;
	final STAR_DELAY:Float = 10.0;
	final BUDDY_DELAY:Float = 2.5;
	final WALL_THICKNESS:Int = 12;
	final PLAYER_VEL:Int = 140;
	final MAX_PLAYER_VEL:Int = 400;
	final BALL_VEL:Int = 120;
	final MAX_BALL_VEL:Int = 400;

	var walls = new FlxTypedGroup<FlxSprite>(10);
	var star:FlxSprite;
	var player:FlxSprite;
	var balls = new FlxTypedGroup<FlxSprite>(100);
	var buddies = new FlxTypedGroup<FlxSprite>(MAX_BUDDIES);
	var collidables = new FlxGroup();
	var hitSound:FlxSound;
	var ballDeathSound:FlxSound;
	var starSound:FlxSound;
	var timeSinceStar:Float = 0;
	var timeSinceBuddy:Float = 0;
	var gameOver:Bool = false;

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
		var centerWall = new FlxSprite();
		centerWall.makeGraphic(WALL_THICKNESS, WALL_THICKNESS * 4, Color.BLUE);
		centerWall.screenCenter();
		centerWall.x += WALL_THICKNESS;
		walls.add(centerWall);
		
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

		for (i in 0...MAX_BALLS)
		{
			balls.add(makeBall());
		}
		add(balls);

		for (i in 0...MAX_BUDDIES)
		{
			var buddy = new FlxSprite();
			buddy.loadGraphic("assets/images/lonely-paddle/buddy.png");
			buddy.kill();
			buddies.add(buddy);
		}
		add(buddies);

		for (i in 0...3)
		{
			spawnBuddy();
		}

		spawnBall();

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

		if (!gameOver)
		{
			if (!star.alive)
			{
				timeSinceStar += elapsed;

				if (timeSinceStar > STAR_DELAY)
				{
					placeStar();
					timeSinceStar = 0;
				}
			}

			timeSinceBuddy += elapsed;

			if (timeSinceBuddy > BUDDY_DELAY)
			{
				spawnBuddy();
				timeSinceBuddy = 0;
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

			FlxG.collide(balls, collidables, ballHitCollidable);
			FlxG.overlap(balls, star, ballHitStar);
			FlxG.overlap(balls, buddies, ballHitBuddy);

			balls.forEachAlive(function(ball) {
				if (!ball.inWorldBounds())
				{
					ballDeathSound.play();
					ball.kill();
				}
			});

			if (balls.getFirstAlive() == null)
			{
				gameOver = true;

				FlxG.camera.flash(Color.WHITE, 0.75, function() {
					var gameOverBG = new FlxSprite();
					gameOverBG.makeGraphic(FlxG.width, FlxG.height, Color.BLACK);
					gameOverBG.alpha = 0.8;
					gameOverBG.screenCenter();
					add(gameOverBG);
					var gameOverText = new MimeoText("Game Over", Color.WHITE, 2).screenCenter();
					gameOverText.y -= 18;
					add(gameOverText);
					var restartText = new MimeoText("Press ACTION to restart", Color.WHITE).screenCenter();
					restartText.y = gameOverText.y + 40;
					restartText.flicker(0, 0.4);
					add(restartText);
				});
			}
		}
		else
		{
			if (Input.justPressed(Action.CONFIRM)) 
			{
				FlxG.resetState();
			}
		}
	}


	function makeBall()
	{
		var ball = new FlxSprite();
		ball.loadGraphic("assets/images/lonely-paddle/ball.png");
		ball.solid = true;
		ball.elasticity = 1.0;
		ball.maxVelocity.set(MAX_BALL_VEL, MAX_BALL_VEL);
		ball.drag.set(0, 0);
		ball.kill();
		return ball;
	}

	function spawnBall()
	{
		var ball = balls.recycle(FlxSprite);
		ball.revive();
		ball.screenCenter();
		ball.x -= WALL_THICKNESS * 2;
		ball.flicker(1, 0.08, true, true, function(_) {
			ball.velocity.set(BALL_VEL, BALL_VEL);
		});
	}

	function spawnBuddy()
	{
		var buddy = buddies.recycle(FlxSprite);
		placeInField(buddy);
		buddy.revive();
		buddy.flicker();
	}

	function ballHitStar(_, _)
	{
		starSound.play();
		star.kill();
		spawnBall();
		timeSinceStar = 0;
	}

	function ballHitBuddy(_, buddy)
	{
		starSound.play();
		buddy.kill();
	}

	function placeStar()
	{
		placeInField(star);
		star.revive();
		star.flicker();
	}

	final FIELD_POS_MOD = 20;

	function placeInField(object:FlxObject)
	{
		object.setPosition(
			FlxG.random.int(FIELD_POS_MOD, FlxG.width - WALL_THICKNESS - FIELD_POS_MOD),
			FlxG.random.int(WALL_THICKNESS + FIELD_POS_MOD, FlxG.height - WALL_THICKNESS - FIELD_POS_MOD)
		);

		if (object.overlaps(walls))
			placeInField(object);
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
						  _collidable.angle = 0;
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
					  object.scale.set(1, 1);
				  }
			  }
			}
		);
	}
}
