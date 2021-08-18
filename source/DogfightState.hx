package;

class DogfightState extends GameState
{
	override function slug():String
	{
		return "dogfight";
	}

	override public function gameType():GameType
	{
		return GameType.DOGFIGHT;
	}
}
