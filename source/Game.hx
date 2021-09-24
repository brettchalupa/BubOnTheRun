package;

import flixel.FlxSprite;

class Game {
	public final name:String;
	public final slug: String;
	public final description: String;
	public final publiclyVisible: Bool;
	public final state:Class<GameState>;

	public var cover:FlxSprite;

	public function new(
		_name: String,
		_slug: String,
		_description: String,
		_publiclyVisible: Bool,
		_state: Class<GameState>
	)
	{
		name = _name;
		slug = _slug;
		description = _description;
		publiclyVisible = _publiclyVisible;
		state = _state;

	}

	public function loadCover():FlxSprite
	{
		cover = new FlxSprite();
		var path = "assets/images/cover-" + slug + ".png";
		cover.loadGraphic(path);
		cover.screenCenter();
		return cover;
	}

	public function newState():GameState
	{
		return Type.createInstance(state, [this]);
	}
}
