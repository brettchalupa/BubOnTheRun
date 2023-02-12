package;

class Reg
{
	public static final version = haxe.macro.Compiler.getDefine("gameVer");

	public static var games:Array<Game>;

	public static function loadGames()
	{
		games = [
			new Game(
				"Bub on the Run",
				"bub-on-the-run",
				"Infinite runner",
				true,
				BubOnTheRunState
			),
		];
	}
}
