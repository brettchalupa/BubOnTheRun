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

		addText("Royalty", 1, 0, 0, Color.WHITE);
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);
	}
}
