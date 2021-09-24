package;

import Color;
import InputManager.Action;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.math.FlxPoint;
import flixel.util.FlxAxes;
import flixel.util.FlxTimer;

using flixel.util.FlxSpriteUtil;

enum Direction
{
	UP;
	DOWN;
	LEFT;
	RIGHT;
}

class SlitherState extends GameState
{
	override function slug():String
	{
		return "slither";
	}

	override public function gameType():GameType
	{
		return GameType.SLITHER;
	}

	var direction:Direction = UP;
	var player:FlxSprite;
	var apple:FlxSprite;
	var timeSinceLastMove:Float = 0;
	var parts:Array<FlxSprite> = [];
	var lastPlayerX:Float = 0.0;
	var lastPlayerY:Float = 0.0;
	var gameOver:Bool = false;
	var field:FlxSprite;
	var sizeText:MimeoText;

	static final MOVE_ELAPSED:Float = 0.25;
	static final TILES_WIDE:Int = 24;
	static final TILES_HIGH:Int = 14;
	static final TILE_SIZE:Int = 8;

	override public function create()
	{
		super.create();

		FlxG.camera.bgColor = Color.BLACK;

		field = new FlxSprite(0, 0).makeGraphic(TILE_SIZE * TILES_WIDE, TILE_SIZE * TILES_HIGH, Color.GREEN);
		field.screenCenter();
		add(field);

		FlxG.worldBounds.set(field.x, field.y, field.width, field.height);

		var pos:FlxPoint = positionInGrid(Std.int(TILES_WIDE / 2), Std.int(TILES_HIGH - 4));
		player = new FlxSprite(pos.x, pos.y);
		player.makeGraphic(TILE_SIZE, TILE_SIZE, Color.BLUE);
		add(player);
		lastPlayerX = player.x;
		lastPlayerY = player.y;

		apple = new FlxSprite();
		apple.makeGraphic(Std.int(TILE_SIZE / 2), Std.int(TILE_SIZE / 2), Color.RED);
		spawnApple();
		add(apple);

		updateSizeText();
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
			var prevDirection = direction;
			timeSinceLastMove += elapsed;

			if (input.justPressed(Action.LEFT))
			{
				if (parts.length > 0)
				{
					if (direction != Direction.RIGHT)
					{
						direction = Direction.LEFT;
					}
				}
				else
				{
					direction = Direction.LEFT;
				}
			}

			if (input.justPressed(Action.RIGHT))
			{
				if (parts.length > 0)
				{
					if (direction != Direction.LEFT)
					{
						direction = Direction.RIGHT;
					}
				}
				else
				{
					direction = Direction.RIGHT;
				}
			}

			if (input.justPressed(Action.UP))
			{
				if (parts.length > 0)
				{
					if (direction != Direction.DOWN)
					{
						direction = Direction.UP;
					}
				}
				else
				{
					direction = Direction.UP;
				}
			}

			if (input.justPressed(Action.DOWN))
			{
				if (parts.length > 0)
				{
					if (direction != Direction.UP)
					{
						direction = Direction.DOWN;
					}
				}
				else
				{
					direction = Direction.DOWN;
				}
			}

			#if debug
			if (input.justPressed(Action.CONFIRM))
			{
				generatePart();
			}
			#end

			if (timeSinceLastMove > (MOVE_ELAPSED / (1 + (parts.length * 0.1))))
			{
				lastPlayerX = player.x;
				lastPlayerY = player.y;

				switch (direction)
				{
					case UP:
						player.y -= player.height;

					case DOWN:
						player.y += player.height;

					case LEFT:
						player.x -= player.width;

					case RIGHT:
						player.x += player.width;
				}

				if (player.x >= (field.width + field.x))
				{
					player.x = field.x;
				}

				if (player.x < field.x)
				{
					player.x = (field.width + field.x) - player.width;
				}

				if (player.y >= field.height + field.y)
				{
					player.y = field.y;
				}

				if (player.y < field.y)
				{
					player.y = (field.height + field.y) - player.height;
				}

				timeSinceLastMove = 0;

				FlxG.overlap(player, apple, doEatApple);

				for (part in parts)
				{
					FlxG.overlap(player, part, doGameOver);
				}

				if (parts.length > 0)
				{
					var lastPartPosition = parts[0].getPosition();
					for (part in parts)
					{
						var index = parts.indexOf(part);
						if (index == 0)
						{
							part.setPosition(lastPlayerX, lastPlayerY);
						}
						else
						{
							var pos = part.getPosition();
							part.setPosition(lastPartPosition.x, lastPartPosition.y);
							lastPartPosition = pos;
						}
					}
				}
			}
		}
		super.update(elapsed);
	}

	function doGameOver(player, part)
	{
		gameOver = true;
		FlxG.camera.shake(0.05, 0.25, function()
		{
			add(new MimeoText("Game Over", Color.WHITE, 2).screenCenter());
			add(new MimeoText("Press ACTION to restart", Color.WHITE, 1, 0, field.y + field.height - 32).screenCenter(FlxAxes.X));
		});
	}

	function doEatApple(player:FlxSprite, apple:FlxSprite)
	{
		apple.kill();
		FlxG.sound.play("assets/sounds/click.ogg");
		generatePart();
		new FlxTimer().start(0.25, spawnApple, 1);
	}

	function spawnApple(?_:FlxTimer)
	{
		var x = FlxG.random.int(1, TILES_WIDE);
		var y = FlxG.random.int(1, TILES_HIGH);
		var pos = positionInGrid(x, y);
		apple.setPosition(pos.x + apple.width / 2, pos.y + apple.width / 2);
		apple.revive();
		apple.flicker(1, 0.04);
	};

	function positionInGrid(gridX:Int, gridY:Int):FlxPoint
	{
		var x = field.x + (gridX * TILE_SIZE) - TILE_SIZE;
		var y = field.y + (gridY * TILE_SIZE) - TILE_SIZE;
		return new FlxPoint(x, y);
	}

	function generatePart()
	{
		var part = new FlxSprite(-100, -100).makeGraphic(TILE_SIZE, TILE_SIZE, Color.BLUE);
		parts.push(part);
		add(part);
		updateSizeText();
	}

	function updateSizeText()
	{
		if (sizeText == null)
		{
			sizeText = new MimeoText("Parts: 0", Color.WHITE, 1, 2, FlxG.height - 9);
			add(sizeText);
		}

		var length = parts.length;
		sizeText.text = "Parts: " + parts.length;
	}
}
