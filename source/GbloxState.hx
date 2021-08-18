package;

class GbloxState extends GameState
{
	override function slug():String
	{
		return "gblox";
	}

	override public function gameType():GameType
	{
		return GameType.GBLOX;
	}
}
