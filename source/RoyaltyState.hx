package;

class RoyaltyState extends GameState
{
	override public function create()
	{
		super.create();

		add(new MimeoText(game.name, Color.WHITE, 1));
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);
	}
}
