package;

import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.addons.display.FlxBackdrop;
import flixel.addons.editors.ogmo.FlxOgmo3Loader;
import flixel.tile.FlxTilemap;
import spacevania.Player;

class SpacevaniaState extends GameState
{
	override function slug():String
	{
		return "spacevania";
	}

	override public function gameType():GameType
	{
		return GameType.SPACEVANIA;
	}

	var player:Player;
	var isGameOver:Bool = false;
	var totalElapsedTime:Float;
	var map:FlxOgmo3Loader;
	var walls:FlxTilemap;

	override public function create()
	{
		super.create();

		FlxG.cameras.bgColor = Color.BLACK;

		add(new FlxBackdrop("assets/images/spacevania/bg.png"));

		map = new FlxOgmo3Loader("assets/data/spacevania/Spacevania.ogmo", "assets/data/spacevania/test-level.json");

		walls = map.loadTilemap("assets/images/spacevania/tiles.png", "walls");
		walls.follow();
		walls.setTileProperties(0, FlxObject.NONE);
		walls.setTileProperties(1, FlxObject.ANY);
		add(walls);

		player = new Player();
		add(player.bullets);
		add(player);

		map.loadEntities(function(entity)
		{
			if (entity.name == "player")
			{
				player.setPosition(entity.x, entity.y);
			}
		});

		FlxG.camera.follow(player, FlxCameraFollowStyle.TOPDOWN);
		FlxG.worldBounds.set(0, 0, walls.width, walls.height);
		FlxG.watch.add(walls, "width");
		FlxG.watch.add(walls, "height");
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);

		FlxG.collide(walls, player);
		FlxG.collide(walls, player.bullets, function(wall, bullet)
		{
			bullet.kill();
		});
	}
}
