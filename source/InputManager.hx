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

	public function justReleased(action:Action):Bool
	{
		switch action
		{
			case LEFT:
				return FlxG.keys.justReleased.LEFT || justReleasedGamepad(action);

			case RIGHT:
				return FlxG.keys.justReleased.RIGHT || justReleasedGamepad(action);

			case CANCEL:
				return FlxG.keys.justReleased.BACKSPACE || FlxG.keys.justReleased.X || justReleasedGamepad(action);

			case CONFIRM:
				return FlxG.keys.justReleased.ENTER || FlxG.keys.justPressed.SPACE || FlxG.keys.justReleased.Z || justReleasedGamepad(action);

			default:
				return false;
		}

		return false;
	}

	private function justReleasedGamepad(action:Action):Bool
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

	public function pressed(action:Action):Bool
	{
		switch action
		{
			case LEFT:
				return FlxG.keys.pressed.LEFT || pressedGamepad(action);

			case RIGHT:
				return FlxG.keys.pressed.RIGHT || pressedGamepad(action);

			case CANCEL:
				return FlxG.keys.pressed.BACKSPACE || FlxG.keys.pressed.X || justReleasedGamepad(action);

			case CONFIRM:
				return FlxG.keys.pressed.ENTER || FlxG.keys.justPressed.SPACE || FlxG.keys.pressed.Z || justReleasedGamepad(action);

			default:
				return false;
		}
	}

	private function pressedGamepad(action:Action):Bool
	{
		var gamepad = FlxG.gamepads.lastActive;
		if (gamepad == null)
			return false;
		switch action
		{
			case LEFT:
				return gamepad.pressed.DPAD_LEFT || gamepad.pressed.LEFT_STICK_DIGITAL_LEFT;
			case RIGHT:
				return gamepad.pressed.DPAD_RIGHT || gamepad.pressed.LEFT_STICK_DIGITAL_RIGHT;
			case CANCEL:
				return gamepad.pressed.B;
			case CONFIRM:
				return gamepad.pressed.A;
			default:
				return false;
		}
	}

	public function justPressed(action:Action):Bool
	{
		switch action
		{
			case LEFT:
				return FlxG.keys.justPressed.LEFT || justPressedGamepad(action);

			case RIGHT:
				return FlxG.keys.justPressed.RIGHT || justPressedGamepad(action);

			case UP:
				return FlxG.keys.justPressed.UP || justPressedGamepad(action);

			case DOWN:
				return FlxG.keys.justPressed.DOWN || justPressedGamepad(action);

			case CANCEL:
				return FlxG.keys.justPressed.BACKSPACE || FlxG.keys.justPressed.X || justReleasedGamepad(action);

			case CONFIRM:
				return FlxG.keys.justPressed.ENTER || FlxG.keys.justPressed.SPACE || FlxG.keys.justPressed.Z || justReleasedGamepad(action);

			default:
				return false;
		}
	}

	private function justPressedGamepad(action:Action):Bool
	{
		var gamepad = FlxG.gamepads.lastActive;
		if (gamepad == null)
			return false;
		switch action
		{
			case LEFT:
				return gamepad.justPressed.DPAD_LEFT || gamepad.justPressed.LEFT_STICK_DIGITAL_LEFT;
			case RIGHT:
				return gamepad.justPressed.DPAD_RIGHT || gamepad.justPressed.LEFT_STICK_DIGITAL_RIGHT;
			case UP:
				return gamepad.justPressed.DPAD_UP || gamepad.justPressed.LEFT_STICK_DIGITAL_UP;
			case DOWN:
				return gamepad.justPressed.DPAD_DOWN || gamepad.justPressed.LEFT_STICK_DIGITAL_DOWN;
			case CANCEL:
				return gamepad.justPressed.B;
			case CONFIRM:
				return gamepad.justPressed.A;
			default:
				return false;
		}
	}
}
