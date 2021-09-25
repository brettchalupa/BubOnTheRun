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
using StringTools;

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
	final MAX_BALL_VEL:Int = 180;
	final BALL_VEL_MODIFIER:Float = 1.01;

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
	var score:Int = 0;
	var highScore:Int = 0;
	var scoreText:MimeoText;
	var newHighScore = false;

	final STAR_VALUE = 1000;
	final BUDDY_VALUE = 200;

	override public function create()
	{
		FlxG.cameras.bgColor = Color.GREEN;

		super.create();

		if (save.data.highScore != null)
		{
			highScore = Std.int(save.data.highScore);
		}

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

		scoreText = new MimeoText("", Color.WHITE, 1, 2, 2);
		updateScoreText();
		add(scoreText);

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
			
			updateScoreText();

			if (balls.getFirstAlive() == null)
			{
				gameOver = true;

				if (score > highScore)
				{
					newHighScore = true;
					save.data.highScore = score;
					save.flush();
				}

				FlxG.camera.flash(Color.WHITE, 0.75, function() {
					final spacingModifier = 16;

					var gameOverBG = new FlxSprite();
					gameOverBG.makeGraphic(FlxG.width, FlxG.height, Color.BLACK);
					gameOverBG.alpha = 0.9;
					gameOverBG.screenCenter();
					add(gameOverBG);
					var gameOverText = new MimeoText("Game Over", Color.WHITE, 2).screenCenter();
					gameOverText.y -= spacingModifier * 2;
					add(gameOverText);

					var resultsText = new MimeoText("Score: " + formattedScore(score), Color.WHITE, 1).screenCenter();
					add(resultsText);

					var hsText:String;
					if (newHighScore)
					{
						hsText = "New high-score!";
					}
					else
					{
						hsText = "High-Score: " + formattedScore(highScore);
					}

					var highScoreText = new MimeoText(hsText, Color.LIGHT_GREEN, 1).screenCenter();
					highScoreText.y = spacingModifier * 5;
					add(highScoreText);

					var restartText = new MimeoText("Press ACTION to restart", Color.WHITE).screenCenter();
					restartText.y = spacingModifier * 7;
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

	function updateScoreText()
	{
		scoreText.text = "Score: " + formattedScore(score);
	}

	function formattedScore(_score):String
	{
		 return Std.string(_score).lpad("0", 6);
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
	}

	function ballHitStar(_, _)
	{
		score += STAR_VALUE;
		starSound.play();
		star.kill();
		spawnBall();
		timeSinceStar = 0;
	}

	function ballHitBuddy(_, buddy)
	{
		score += BUDDY_VALUE;
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

	function ballHitCollidable(_ball:FlxSprite, _collidable:FlxSprite)
	{
		hitSound.play(true);
		_ball.velocity.x = Std.int(_ball.velocity.x * BALL_VEL_MODIFIER);
		_ball.velocity.y = Std.int(_ball.velocity.y * BALL_VEL_MODIFIER);
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

	function scaleTween(object:FlxSprite)
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
