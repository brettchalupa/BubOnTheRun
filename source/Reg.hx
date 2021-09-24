package;

class Reg
{
	public static final version = haxe.macro.Compiler.getDefine("gameVer");

	public static var games:Array<Game>;

	public static function loadGames()
	{
		games = [
			new Game(
				"Gblox",
				"gblox",
				"Block-based puzzler",
				false,
				GbloxState
			),
			new Game(
				"Slither",
				"slither",
				"Snake rip-off!",
				true,
				SlitherState
			),
			new Game(
				"Dogfight",
				"dogfight",
				"Shoot down enemy planes",
				false,
				DogfightState
			),
			new Game(
				"Quick Draw",
				"quick-draw",
				"Rock, paper, scissors",
				true,
				QuickDrawState
			),
			new Game(
				"Royalty",
				"royalty",
				"Solitaire",
				false,
				RoyaltyState
			),
			new Game(
				"Cutscene Prototype",
				"hearts",
				"Visual novel-style text display",
				true,
				HeartsState
			),
			new Game(
				"Bub on the Run",
				"bub-on-the-run",
				"Infinite runner",
				true,
				BubOnTheRunState
			),
			new Game(
				"Spacevania",
				"spacevania",
				"Space action shooter",
				false,
				SpacevaniaState
			),
			new Game(
				"Bullet Heck",
				"bullet-heck",
				"Dodge the bullets and take down enemy ships",
				true,
				BulletHeckState
			),
			new Game(
				"Lonely Paddle",
				"lonely-paddle",
				"For those without a table tennis partner",
				true,
				LonelyPaddleState
			)
		];
	}
}
