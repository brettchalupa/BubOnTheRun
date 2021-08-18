import flixel.FlxG;

enum Action
{
	LEFT;
	RIGHT;
	UP;
	DOWN;
	CONFIRM;
	CANCEL;
}

class InputManager
{
	public function new() {}

	public function released(action:Action):Bool
	{
		switch action
		{
			case LEFT:
				return FlxG.keys.justReleased.LEFT || releasedGamepad(action);

			case RIGHT:
				return FlxG.keys.justReleased.RIGHT || releasedGamepad(action);

			case CANCEL:
				return FlxG.keys.justReleased.BACKSPACE || FlxG.keys.justReleased.X || releasedGamepad(action);

			case CONFIRM:
				return FlxG.keys.justReleased.ENTER || FlxG.keys.justReleased.Z || releasedGamepad(action);

			default:
				return false;
		}

		return false;
	}

	private function releasedGamepad(action:Action):Bool
	{
		var gamepad = FlxG.gamepads.lastActive;
		if (gamepad == null)
			return false;
		switch action
		{
			case LEFT:
				return gamepad.justReleased.DPAD_LEFT || gamepad.justReleased.LEFT_STICK_DIGITAL_LEFT;
			case RIGHT:
				return gamepad.justReleased.DPAD_RIGHT || gamepad.justReleased.LEFT_STICK_DIGITAL_RIGHT;
			case CANCEL:
				return gamepad.justReleased.B;
			case CONFIRM:
				return gamepad.justReleased.A;
			default:
				return false;
		}
	}
}
