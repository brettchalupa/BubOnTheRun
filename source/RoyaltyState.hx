package;

class RoyaltyState extends GameState
{
	override function slug():String
	{
		return "royalty";
	}

	override public function gameType():GameType
	{
		return GameType.ROYALTY;
	}

	override public function create()
	{
		super.create();

		addText("Royalty");
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);
	}
}
