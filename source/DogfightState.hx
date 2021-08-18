package;

import Color;
import InputManager.Action;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.util.FlxAxes;

using StringTools;

class DogfightState extends GameState
{
	override public function gameType():GameType
	{
		return GameType.DOGFIGHT;
	}

	var player:FlxSprite;
	var bullets:FlxTypedGroup<FlxSprite>;
	var enemies:FlxTypedGroup<FlxSprite>;
	var score:Int = 0;
	var scoreText:FlxText;
	var gameOver:Bool = false;
	var difficultyLevel = 1;

	override public function create()
	{
		super.create();
		FlxG.worldBounds.set(0, 0, FlxG.width, FlxG.height);

		player = new FlxSprite();
		player.makeGraphic(8, 8, Color.PINK);
		player.screenCenter();
		player.y = FlxG.height - 32;
		add(player);

		bullets = new FlxTypedGroup<FlxSprite>();
		enemies = new FlxTypedGroup<FlxSprite>();

		spawnEnemies();
		spawnEnemies();
		spawnEnemies();
		spawnEnemies();
		spawnEnemies();

		add(enemies);

		scoreText = addText('Score: 000000', 12, 6, 6);
		scoreText.alignment = "right";
		scoreText.x = FlxG.width - scoreText.width - 12;
		updateScore(0);
	}

	override function slug():String
	{
		return "dogfight";
	}

	override public function update(elapsed:Float)
	{
		if (gameOver)
		{
			if (input.pressed(Action.CONFIRM))
			{
				FlxG.resetState();
			}
		}
		else
		{
			if (input.pressed(Action.LEFT))
			{
				player.x -= 2;
			}
			if (input.pressed(Action.RIGHT))
			{
				player.x += 2;
			}
			if (input.justPressed(Action.CONFIRM))
			{
				bullets.add(shootBullet(elapsed));
			}

			if (player.x < 0)
			{
				player.x = 0;
			}

			if (player.x + player.width > FlxG.width)
			{
				player.x = FlxG.width - player.width;
			}

			for (bullet in bullets)
			{
				if (bullet.y + bullet.height < 0)
				{
					bullets.remove(bullet);
					bullet.kill();
					bullet.destroy();
				}
			}

			for (enemy in enemies)
			{
				if (enemy.y >= FlxG.height)
				{
					enemies.remove(enemy);
					enemy.kill();
					enemy.destroy();
					spawnEnemies();
				}
			}

			FlxG.overlap(bullets, enemies, onBulletHitEnemy);
			FlxG.overlap(enemies, player, onEnemyHitPlayer);
		}

		super.update(elapsed);
	}

	function onBulletHitEnemy(bullet:FlxSprite, enemy:FlxSprite)
	{
		bullet.kill();
		bullets.remove(bullet);
		enemy.kill();
		enemies.remove(enemy);
		enemy.destroy();
		bullet.destroy();
		updateScore(100);
		spawnEnemies();
	}

	function onEnemyHitPlayer(enemy:FlxSprite, player:FlxSprite)
	{
		player.kill();
		enemy.kill();
		enemies.remove(enemy);
		doGameOver();
	}

	function doGameOver()
	{
		gameOver = true;
		FlxG.camera.shake(0.02, 0.25, function()
		{
			addText("Game Over", 24, 0, 0).screenCenter();
			addText("Press ACTION to restart", 12, 0, FlxG.height - 32).screenCenter(FlxAxes.X);
		});
	}

	function spawnEnemies()
	{
		for (_ in 0...difficultyLevel)
		{
			var enemy = new FlxSprite();
			enemy.makeGraphic(6, 6, Color.ORANGE);
			enemy.y = FlxG.random.float(-10, -100);
			enemy.x = FlxG.random.float(0 + enemy.width, FlxG.width - enemy.width);
			enemy.velocity.y = FlxG.random.float(20, 50);
			enemies.add(enemy);
		}
	}

	function shootBullet(elapsed:Float):FlxSprite
	{
		var bullet = new FlxSprite();
		bullet.makeGraphic(2, 2, Color.RED);
		bullet.x = player.x + player.width / 2 - bullet.width / 2;
		bullet.y = player.y - bullet.height;
		bullet.velocity.y = -100;
		add(bullet);
		FlxG.sound.play(AssetPaths.click__wav);
		return bullet;
	}

	function updateScore(amount)
	{
		score += amount;
		if (score == 1000)
		{
			difficultyLevel++;
		}
		var formattedScore = Std.string(score).lpad("0", 6);
		scoreText.text = 'Score: $formattedScore';
	};
}
