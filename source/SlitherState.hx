package;

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
}
