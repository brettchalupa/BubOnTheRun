import flixel.FlxG;
import flixel.input.gamepad.FlxGamepadInputID;
import flixel.input.keyboard.FlxKey;

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
	static final LEFT_KEYS = [FlxKey.LEFT, FlxKey.A];
	static final RIGHT_KEYS = [FlxKey.RIGHT, FlxKey.D];
	static final UP_KEYS = [FlxKey.UP, FlxKey.W];
	static final DOWN_KEYS = [FlxKey.DOWN, FlxKey.S];
	static final CONFIRM_KEYS = [FlxKey.Z, FlxKey.J, FlxKey.ENTER, FlxKey.SPACE];
	static final CANCEL_KEYS = [FlxKey.X, FlxKey.K, FlxKey.BACKSPACE, FlxKey.ESCAPE];

	static final LEFT_BUTTONS = [FlxGamepadInputID.DPAD_LEFT, FlxGamepadInputID.LEFT_STICK_DIGITAL_LEFT];
	static final RIGHT_BUTTONS = [FlxGamepadInputID.DPAD_RIGHT, FlxGamepadInputID.LEFT_STICK_DIGITAL_RIGHT];
	static final UP_BUTTONS = [FlxGamepadInputID.DPAD_UP, FlxGamepadInputID.LEFT_STICK_DIGITAL_UP];
	static final DOWN_BUTTONS = [FlxGamepadInputID.DPAD_DOWN, FlxGamepadInputID.LEFT_STICK_DIGITAL_DOWN];
	static final CONFIRM_BUTTONS = [FlxGamepadInputID.A];
	static final CANCEL_BUTTONS = [FlxGamepadInputID.B];

	public function new() {}

	public function justReleased(action:Action):Bool
	{
		return justReleasedKey(action) || justReleasedGamepad(action) || justReleasedMouse(action);
	}

	private function justReleasedKey(action:Action):Bool
	{
		#if FLX_KEYBOARD
		return FlxG.keys.anyJustReleased(keysForAction(action));
		#else
		return false;
		#end
	}

	private function justReleasedGamepad(action:Action):Bool
	{
		#if !FLX_NO_GAMEPAD
		var gamepad = FlxG.gamepads.lastActive;
		if (gamepad == null)
			return false;
		return gamepad.anyJustReleased(buttonsForAction(action));
		#else
		return false;
		#end
	}

	public function justReleasedMouse(action:Action):Bool
	{
		#if FLX_MOUSE
		switch (action)
		{
			case CONFIRM:
				return FlxG.mouse.justReleased;
			default:
				return false;
		}
		#else
		return false;
		#end
	}

	public function pressed(action:Action):Bool
	{
		return pressedKeyboard(action) || pressedGamepad(action) || pressedMouse(action);
	}

	private function pressedKeyboard(action:Action):Bool
	{
		#if FLX_KEYBOARD
		return FlxG.keys.anyPressed(keysForAction(action));
		#else
		return false;
		#end
	}

	private function pressedGamepad(action:Action):Bool
	{
		#if !FLX_NO_GAMEPAD
		var gamepad = FlxG.gamepads.lastActive;
		if (gamepad == null)
			return false;
		return gamepad.anyPressed(buttonsForAction(action));
		#else
		return false;
		#end
	}

	public function pressedMouse(action:Action):Bool
	{
		#if FLX_MOUSE
		switch (action)
		{
			case CONFIRM:
				return FlxG.mouse.pressed;
			default:
				return false;
		}
		#else
		return false;
		#end
	}

	public function justPressed(action:Action):Bool
	{
		return justPressedKey(action) || justPressedGamepad(action) || justPressedMouse(action);
	}

	private function justPressedKey(action:Action):Bool
	{
		#if FLX_KEYBOARD
		return FlxG.keys.anyJustPressed(keysForAction(action));
		#else
		return false;
		#end
	}

	private function justPressedGamepad(action:Action):Bool
	{
		#if !FLX_NO_GAMEPAD
		var gamepad = FlxG.gamepads.lastActive;
		if (gamepad == null)
			return false;
		return gamepad.anyJustPressed(buttonsForAction(action));
		#else
		return false;
		#end
	}

	public function justPressedMouse(action):Bool
	{
		#if FLX_MOUSE
		switch (action)
		{
			case CONFIRM:
				return FlxG.mouse.justPressed;
			default:
				return false;
		}
		#else
		return false;
		#end
	}

	private function keysForAction(action:Action):Array<FlxKey>
	{
		switch action
		{
			case LEFT:
				return LEFT_KEYS;
			case RIGHT:
				return RIGHT_KEYS;
			case UP:
				return UP_KEYS;
			case DOWN:
				return DOWN_KEYS;
			case CANCEL:
				return CANCEL_KEYS;
			case CONFIRM:
				return CONFIRM_KEYS;
			default:
				return [];
		}
	}

	private function buttonsForAction(action:Action):Array<FlxGamepadInputID>
	{
		switch action
		{
			case LEFT:
				return LEFT_BUTTONS;
			case RIGHT:
				return RIGHT_BUTTONS;
			case UP:
				return UP_BUTTONS;
			case DOWN:
				return DOWN_BUTTONS;
			case CANCEL:
				return CANCEL_BUTTONS;
			case CONFIRM:
				return CONFIRM_BUTTONS;
			default:
				return [];
		}
	}
}
