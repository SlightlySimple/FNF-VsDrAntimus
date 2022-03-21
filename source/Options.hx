package;

import lime.app.Application;
import lime.system.DisplayMode;
import flixel.util.FlxColor;
import Controls.KeyboardScheme;
import flixel.FlxG;
import openfl.display.FPS;
import openfl.Lib;

class Option
{
	public function new()
	{
		display = updateDisplay();
	}

	private var description:String = "";
	private var display:String;
	private var acceptValues:Bool = false;

	public var acceptType:Bool = false;

	public var waitingType:Bool = false;

	public final function getDisplay():String
	{
		return display;
	}

	public final function getAccept():Bool
	{
		return acceptValues;
	}

	public final function getDescription():String
	{
		return description;
	}

	public function getValue():String
	{
		return updateDisplay();
	};

	public function onType(text:String)
	{
	}

	// Returns whether the label is to be updated.
	public function press():Bool
	{
		return true;
	}

	private function updateDisplay():String
	{
		return "";
	}

	public function left():Bool
	{
		return false;
	}

	public function right():Bool
	{
		return false;
	}

	public function isCheckable():Bool { return false; }
	public function isChecked():Bool { return false; }
}

class OptionTypeCheckmark extends Option
{
	private var label:String = "";
	private var inPause:Bool = false;
	private var myVar:String = "";

	public function new(label:String, desc:String, inPause:Bool, myVar:String)
	{
		super();
		if (OptionsMenu.isInPause && !inPause)
			description = CoolUtil.translate('optionsUnavailableInPause');
		else
			description = CoolUtil.translate(desc);
		this.label = label;
		this.inPause = inPause;
		this.myVar = myVar;
	}

	public override function isCheckable():Bool { return true; }
	public override function isChecked():Bool { return Reflect.getProperty(FlxG.save.data, myVar); }

	public override function press():Bool
	{
		if (OptionsMenu.isInPause && !inPause)
			return false;
		Reflect.setProperty(FlxG.save.data, myVar, !Reflect.getProperty(FlxG.save.data, myVar));
		display = updateDisplay();
		return true;
	}

	private override function updateDisplay():String
	{
		return CoolUtil.translate(label);
	}
}

class DFJKOption extends Option
{
	public function new()
	{
		super();
		description = CoolUtil.translate('optionsDescDFJK');
	}

	public override function press():Bool
	{
		OptionsMenu.instance.selectedCatIndex = 4;
		OptionsMenu.instance.switchCat(OptionsMenu.instance.options[4], false);
		return false;
	}

	private override function updateDisplay():String
	{
		return CoolUtil.translate('optionsDFJK');
	}
}

class UpKeybind extends Option
{
	public function new(desc:String)
	{
		super();
		description = CoolUtil.translate(desc);
		acceptType = true;
	}

	public override function onType(text:String)
	{
		if (waitingType)
		{
			FlxG.save.data.upBind = text;
			waitingType = false;
		}
	}

	public override function press()
	{
		Debug.logTrace("keybind change");
		waitingType = !waitingType;

		return true;
	}

	private override function updateDisplay():String
	{
		return CoolUtil.translate('optionsKeybindUp') + " " + (waitingType ? "> " + FlxG.save.data.upBind + " <" : FlxG.save.data.upBind) + "";
	}
}

class DownKeybind extends Option
{
	public function new(desc:String)
	{
		super();
		description = CoolUtil.translate(desc);
		acceptType = true;
	}

	public override function onType(text:String)
	{
		if (waitingType)
		{
			FlxG.save.data.downBind = text;
			waitingType = false;
		}
	}

	public override function press()
	{
		Debug.logTrace("keybind change");
		waitingType = !waitingType;

		return true;
	}

	private override function updateDisplay():String
	{
		return CoolUtil.translate('optionsKeybindDown') + " " + (waitingType ? "> " + FlxG.save.data.downBind + " <" : FlxG.save.data.downBind) + "";
	}
}

class RightKeybind extends Option
{
	public function new(desc:String)
	{
		super();
		description = CoolUtil.translate(desc);
		acceptType = true;
	}

	public override function onType(text:String)
	{
		if (waitingType)
		{
			FlxG.save.data.rightBind = text;
			waitingType = false;
		}
	}

	public override function press()
	{
		Debug.logTrace("keybind change");
		waitingType = !waitingType;

		return true;
	}

	private override function updateDisplay():String
	{
		return CoolUtil.translate('optionsKeybindRight') + " " + (waitingType ? "> " + FlxG.save.data.rightBind + " <" : FlxG.save.data.rightBind) + "";
	}
}

class LeftKeybind extends Option
{
	public function new(desc:String)
	{
		super();
		description = CoolUtil.translate(desc);
		acceptType = true;
	}

	public override function onType(text:String)
	{
		if (waitingType)
		{
			FlxG.save.data.leftBind = text;
			waitingType = false;
		}
	}

	public override function press()
	{
		Debug.logTrace("keybind change");
		waitingType = !waitingType;

		return true;
	}

	private override function updateDisplay():String
	{
		return CoolUtil.translate('optionsKeybindLeft') + " " + (waitingType ? "> " + FlxG.save.data.leftBind + " <" : FlxG.save.data.leftBind) + "";
	}
}

class UpFiveKeybind extends Option
{
	public function new(desc:String)
	{
		super();
		description = CoolUtil.translate(desc);
		acceptType = true;
	}

	public override function onType(text:String)
	{
		if (waitingType)
		{
			FlxG.save.data.upFiveBind = text;
			waitingType = false;
		}
	}

	public override function press()
	{
		trace("keybind change");
		waitingType = !waitingType;

		return true;
	}

	private override function updateDisplay():String
	{
		return CoolUtil.translate('optionsKeybindUpFive') + " " + (waitingType ? "> " + FlxG.save.data.upFiveBind + " <" : FlxG.save.data.upFiveBind) + "";
	}
}

class DownFiveKeybind extends Option
{
	public function new(desc:String)
	{
		super();
		description = CoolUtil.translate(desc);
		acceptType = true;
	}

	public override function onType(text:String)
	{
		if (waitingType)
		{
			FlxG.save.data.downFiveBind = text;
			waitingType = false;
		}
	}

	public override function press()
	{
		trace("keybind change");
		waitingType = !waitingType;

		return true;
	}

	private override function updateDisplay():String
	{
		return CoolUtil.translate('optionsKeybindDownFive') + " " + (waitingType ? "> " + FlxG.save.data.downFiveBind + " <" : FlxG.save.data.downFiveBind) + "";
	}
}

class RightFiveKeybind extends Option
{
	public function new(desc:String)
	{
		super();
		description = CoolUtil.translate(desc);
		acceptType = true;
	}

	public override function onType(text:String)
	{
		if (waitingType)
		{
			FlxG.save.data.rightFiveBind = text;
			waitingType = false;
		}
	}

	public override function press()
	{
		trace("keybind change");
		waitingType = !waitingType;

		return true;
	}

	private override function updateDisplay():String
	{
		return CoolUtil.translate('optionsKeybindRightFive') + " " + (waitingType ? "> " + FlxG.save.data.rightFiveBind + " <" : FlxG.save.data.rightFiveBind) + "";
	}
}

class LeftFiveKeybind extends Option
{
	public function new(desc:String)
	{
		super();
		description = CoolUtil.translate(desc);
		acceptType = true;
	}

	public override function onType(text:String)
	{
		if (waitingType)
		{
			FlxG.save.data.leftFiveBind = text;
			waitingType = false;
		}
	}

	public override function press()
	{
		trace("keybind change");
		waitingType = !waitingType;

		return true;
	}

	private override function updateDisplay():String
	{
		return CoolUtil.translate('optionsKeybindLeftFive') + " " + (waitingType ? "> " + FlxG.save.data.leftFiveBind + " <" : FlxG.save.data.leftFiveBind) + "";
	}
}

class CenterKeybind extends Option
{
	public function new(desc:String)
	{
		super();
		description = CoolUtil.translate(desc);
		acceptType = true;
	}

	public override function onType(text:String)
	{
		if (waitingType)
		{
			FlxG.save.data.centerBind = text;
			waitingType = false;
		}
	}

	public override function press()
	{
		trace("keybind change");
		waitingType = !waitingType;

		return true;
	}

	private override function updateDisplay():String
	{
		return CoolUtil.translate('optionsKeybindCenter') + " " + (waitingType ? "> " + FlxG.save.data.centerBind + " <" : FlxG.save.data.centerBind) + "";
	}
}

class PauseKeybind extends Option
{
	public function new(desc:String)
	{
		super();
		description = CoolUtil.translate(desc);
		acceptType = true;
	}

	public override function onType(text:String)
	{
		if (waitingType)
		{
			FlxG.save.data.pauseBind = text;
			waitingType = false;
		}
	}

	public override function press()
	{
		Debug.logTrace("keybind change");
		waitingType = !waitingType;

		return true;
	}

	private override function updateDisplay():String
	{
		return CoolUtil.translate('optionsKeybindPause') + " " + (waitingType ? "> " + FlxG.save.data.pauseBind + " <" : FlxG.save.data.pauseBind) + "";
	}
}

class ResetBind extends Option
{
	public function new(desc:String)
	{
		super();
		description = CoolUtil.translate(desc);
		acceptType = true;
	}

	public override function onType(text:String)
	{
		if (waitingType)
		{
			FlxG.save.data.resetBind = text;
			waitingType = false;
		}
	}

	public override function press()
	{
		Debug.logTrace("keybind change");
		waitingType = !waitingType;

		return true;
	}

	private override function updateDisplay():String
	{
		return CoolUtil.translate('optionsKeybindReset') + " " + (waitingType ? "> " + FlxG.save.data.resetBind + " <" : FlxG.save.data.resetBind) + "";
	}
}

class MuteBind extends Option
{
	public function new(desc:String)
	{
		super();
		description = CoolUtil.translate(desc);
		acceptType = true;
	}

	public override function onType(text:String)
	{
		if (waitingType)
		{
			FlxG.save.data.muteBind = text;
			waitingType = false;
		}
	}

	public override function press()
	{
		Debug.logTrace("keybind change");
		waitingType = !waitingType;

		return true;
	}

	private override function updateDisplay():String
	{
		return CoolUtil.translate('optionsKeybindMute') + " " + (waitingType ? "> " + FlxG.save.data.muteBind + " <" : FlxG.save.data.muteBind) + "";
	}
}

class VolUpBind extends Option
{
	public function new(desc:String)
	{
		super();
		description = CoolUtil.translate(desc);
		acceptType = true;
	}

	public override function onType(text:String)
	{
		if (waitingType)
		{
			FlxG.save.data.volUpBind = text;
			waitingType = false;
		}
	}

	public override function press()
	{
		Debug.logTrace("keybind change");
		waitingType = !waitingType;

		return true;
	}

	private override function updateDisplay():String
	{
		return CoolUtil.translate('optionsKeybindVolUp') + " " + (waitingType ? "> " + FlxG.save.data.volUpBind + " <" : FlxG.save.data.volUpBind) + "";
	}
}

class VolDownBind extends Option
{
	public function new(desc:String)
	{
		super();
		description = CoolUtil.translate(desc);
		acceptType = true;
	}

	public override function onType(text:String)
	{
		if (waitingType)
		{
			FlxG.save.data.volDownBind = text;
			waitingType = false;
		}
	}

	public override function press()
	{
		Debug.logTrace("keybind change");
		waitingType = !waitingType;

		return true;
	}

	private override function updateDisplay():String
	{
		return CoolUtil.translate('optionsKeybindVolDown') + " " + (waitingType ? "> " + FlxG.save.data.volDownBind + " <" : FlxG.save.data.volDownBind) + "";
	}
}

class FullscreenBind extends Option
{
	public function new(desc:String)
	{
		super();
		description = CoolUtil.translate(desc);
		acceptType = true;
	}

	public override function onType(text:String)
	{
		if (waitingType)
		{
			FlxG.save.data.fullscreenBind = text;
			waitingType = false;
		}
	}

	public override function press()
	{
		Debug.logTrace("keybind change");
		waitingType = !waitingType;

		return true;
	}

	private override function updateDisplay():String
	{
		return CoolUtil.translate('optionsKeybindFullscreen') + " " + (waitingType ? "> " + FlxG.save.data.fullscreenBind + " <" : FlxG.save.data.fullscreenBind) + "";
	}
}

class EditorBind extends Option
{
	public function new(desc:String)
	{
		super();
		description = CoolUtil.translate(desc);
		acceptType = true;
	}

	public override function onType(text:String)
	{
		if (waitingType)
		{
			FlxG.save.data.editorBind = text;
			waitingType = false;
		}
	}

	public override function press()
	{
		trace("keybind change");
		waitingType = !waitingType;

		return true;
	}

	private override function updateDisplay():String
	{
		return CoolUtil.translate('optionsKeybindEditor') + " " + (waitingType ? "> " + FlxG.save.data.editorBind + " <" : FlxG.save.data.editorBind) + "";
	}
}

class SickMSOption extends Option
{
	public function new(desc:String)
	{
		super();
		description = CoolUtil.translate(desc);
		acceptType = true;
	}

	public override function left():Bool
	{
		FlxG.save.data.sickMs--;
		if (FlxG.save.data.sickMs < 0)
			FlxG.save.data.sickMs = 0;
		display = updateDisplay();
		return true;
	}

	public override function right():Bool
	{
		FlxG.save.data.sickMs++;
		display = updateDisplay();
		return true;
	}

	public override function onType(char:String)
	{
		if (char.toLowerCase() == "r")
			FlxG.save.data.sickMs = 45;
	}

	private override function updateDisplay():String
	{
		return CoolUtil.translate('optionsMSSick') + " < " + FlxG.save.data.sickMs + CoolUtil.translate('optionsMS') + " >";
	}
}

class GoodMsOption extends Option
{
	public function new(desc:String)
	{
		super();
		description = CoolUtil.translate(desc);
		acceptType = true;
	}

	public override function left():Bool
	{
		FlxG.save.data.goodMs--;
		if (FlxG.save.data.goodMs < 0)
			FlxG.save.data.goodMs = 0;
		display = updateDisplay();
		return true;
	}

	public override function right():Bool
	{
		FlxG.save.data.goodMs++;
		display = updateDisplay();
		return true;
	}

	public override function onType(char:String)
	{
		if (char.toLowerCase() == "r")
			FlxG.save.data.goodMs = 90;
	}

	private override function updateDisplay():String
	{
		return CoolUtil.translate('optionsMSGood') + " < " + FlxG.save.data.goodMs + CoolUtil.translate('optionsMS') + " >";
	}
}

class BadMsOption extends Option
{
	public function new(desc:String)
	{
		super();
		description = CoolUtil.translate(desc);
		acceptType = true;
	}

	public override function left():Bool
	{
		FlxG.save.data.badMs--;
		if (FlxG.save.data.badMs < 0)
			FlxG.save.data.badMs = 0;
		display = updateDisplay();
		return true;
	}

	public override function right():Bool
	{
		FlxG.save.data.badMs++;
		display = updateDisplay();
		return true;
	}

	public override function onType(char:String)
	{
		if (char.toLowerCase() == "r")
			FlxG.save.data.badMs = 135;
	}

	private override function updateDisplay():String
	{
		return CoolUtil.translate('optionsMSBad') + " < " + FlxG.save.data.badMs + CoolUtil.translate('optionsMS') + " >";
	}
}

class ShitMsOption extends Option
{
	public function new(desc:String)
	{
		super();
		description = CoolUtil.translate(desc);
		acceptType = true;
	}

	public override function left():Bool
	{
		FlxG.save.data.shitMs--;
		if (FlxG.save.data.shitMs < 0)
			FlxG.save.data.shitMs = 0;
		display = updateDisplay();
		return true;
	}

	public override function onType(char:String)
	{
		if (char.toLowerCase() == "r")
			FlxG.save.data.shitMs = 160;
	}

	public override function right():Bool
	{
		FlxG.save.data.shitMs++;
		display = updateDisplay();
		return true;
	}

	private override function updateDisplay():String
	{
		return CoolUtil.translate('optionsMSShit') + " < " + FlxG.save.data.shitMs + CoolUtil.translate('optionsMS') + " >";
	}
}

class EditorZoomOption extends Option
{
	public function new(desc:String)
	{
		super();
		description = CoolUtil.translate(desc);
	}

	public override function left():Bool
	{
		FlxG.save.data.editorZoom -= 0.02;
		if (FlxG.save.data.editorZoom < 0.1)
			FlxG.save.data.editorZoom = 0.1;
		display = updateDisplay();
		return true;
	}

	public override function right():Bool
	{
		FlxG.save.data.editorZoom += 0.02;
		if (FlxG.save.data.editorZoom > 2)
			FlxG.save.data.editorZoom = 2;
		display = updateDisplay();
		return true;
	}

	private override function updateDisplay():String
	{
		return CoolUtil.translate('optionsEditorZoom') + " < " + FlxG.save.data.editorZoom + " >";
	}
}

class StepManiaAdvancedOption extends Option
{
	public function new(desc:String)
	{
		super();
		if (OptionsMenu.isInPause)
			description = CoolUtil.translate('optionsUnavailableInPause');
		else
			description = CoolUtil.translate(desc);
	}

	public override function press():Bool
	{
		if (OptionsMenu.isInPause)
			return false;
		OptionsMenu.instance.selectedCatIndex = 6;
		OptionsMenu.instance.switchCat(OptionsMenu.instance.options[6], false);
		return false;
	}

	private override function updateDisplay():String
	{
		return CoolUtil.translate('optionsStepManiaAdvanced');
	}
}

class RotateNotesOption extends Option
{
	public function new(desc:String)
	{
		super();
		if (OptionsMenu.isInPause)
			description = CoolUtil.translate('optionsUnavailableInPause');
		else
			description = CoolUtil.translate(desc);
	}

	public override function press():Bool
	{
		if (OptionsMenu.isInPause)
			return false;
		FlxG.save.data.rotateNotes = !FlxG.save.data.rotateNotes;
		display = updateDisplay();
		return true;
	}

	public override function left():Bool
	{
		return press();
	}

	public override function right():Bool
	{
		return press();
	}

	private override function updateDisplay():String
	{
		return CoolUtil.translate('optionsRotateNotes' + ( FlxG.save.data.rotateNotes ? '1' : '0' ));
	}
}

class QuantColorOption extends Option
{
	var color:Int;

	public function new(desc:String, color:Int)
	{
		super();
		description = CoolUtil.translate(desc);
		this.color = color;
		acceptType = true;
	}

	public override function left():Bool
	{
		FlxG.save.data.stepManiaColors[color]--;
		if (FlxG.save.data.stepManiaColors[color] < 0)
			FlxG.save.data.stepManiaColors[color] = 4;
		display = updateDisplay();
		return true;
	}

	public override function right():Bool
	{
		FlxG.save.data.stepManiaColors[color]++;
		if (FlxG.save.data.stepManiaColors[color] > 4)
			FlxG.save.data.stepManiaColors[color] = 0;
		display = updateDisplay();
		return true;
	}

	private override function updateDisplay():String
	{
		return CoolUtil.translate('optionsQuantColor' + color) + " < " + CoolUtil.translate('optionsQuantColorValue' + FlxG.save.data.stepManiaColors[color]) + " >";
	}
}

class Judgement extends Option
{
	public function new(desc:String)
	{
		super();
		if (OptionsMenu.isInPause)
			description = CoolUtil.translate('optionsUnavailableInPause');
		else
			description = CoolUtil.translate(desc);
		acceptValues = true;
	}

	public override function press():Bool
	{
		if (OptionsMenu.isInPause)
			return false;
		OptionsMenu.instance.selectedCatIndex = 5;
		OptionsMenu.instance.switchCat(OptionsMenu.instance.options[5], false);
		return true;
	}

	private override function updateDisplay():String
	{
		return CoolUtil.translate('optionsJudgement');
	}
}

class FPSOption extends OptionTypeCheckmark
{
	public override function press():Bool
	{
		var ret:Bool = super.press();
		(cast(Lib.current.getChildAt(0), Main)).toggleFPS(FlxG.save.data.fps);
		return ret;
	}
}

class FPSCapOption extends Option
{
	public function new(desc:String)
	{
		super();
		description = CoolUtil.translate(desc);
		acceptValues = true;
	}

	public override function press():Bool
	{
		return false;
	}

	private override function updateDisplay():String
	{
		return CoolUtil.translate('optionsFPSCap') + " < " + FlxG.save.data.fpsCap + 
		(FlxG.save.data.fpsCap == Application.current.window.displayMode.refreshRate ? CoolUtil.translate('optionsRefreshRate') : "") + " >";
	}

	override function right():Bool
	{
		if (FlxG.save.data.fpsCap >= 290)
		{
			FlxG.save.data.fpsCap = 290;
			(cast(Lib.current.getChildAt(0), Main)).setFPSCap(290);
		}
		else
			FlxG.save.data.fpsCap = FlxG.save.data.fpsCap + 10;
		(cast(Lib.current.getChildAt(0), Main)).setFPSCap(FlxG.save.data.fpsCap);

		return true;
	}

	override function left():Bool
	{
		if (FlxG.save.data.fpsCap > 290)
			FlxG.save.data.fpsCap = 290;
		else if (FlxG.save.data.fpsCap < 60)
			FlxG.save.data.fpsCap = Application.current.window.displayMode.refreshRate;
		else
			FlxG.save.data.fpsCap = FlxG.save.data.fpsCap - 10;
				(cast(Lib.current.getChildAt(0), Main)).setFPSCap(FlxG.save.data.fpsCap);
		return true;
	}

	override function getValue():String
	{
		return updateDisplay();
	}
}

class ScrollSpeedOption extends Option
{
	public function new(desc:String)
	{
		super();
		description = CoolUtil.translate(desc);
		acceptValues = true;
	}

	public override function press():Bool
	{
		return false;
	}

	private override function updateDisplay():String
	{
		return CoolUtil.translate('optionsScrollSpeed') + " < " + HelperFunctions.truncateFloat(FlxG.save.data.scrollSpeed,1) + " >";
	}

	override function right():Bool
	{
		FlxG.save.data.scrollSpeed += 0.1;

		if (FlxG.save.data.scrollSpeed < 1)
			FlxG.save.data.scrollSpeed = 1;

		if (FlxG.save.data.scrollSpeed > 4)
			FlxG.save.data.scrollSpeed = 4;
		return true;
	}

	override function getValue():String
	{
		return CoolUtil.translate('optionsScrollSpeed') + " < " + HelperFunctions.truncateFloat(FlxG.save.data.scrollSpeed,1) + " >";
	}

	override function left():Bool
	{
		FlxG.save.data.scrollSpeed -= 0.1;

		if (FlxG.save.data.scrollSpeed < 1)
			FlxG.save.data.scrollSpeed = 1;

		if (FlxG.save.data.scrollSpeed > 4)
			FlxG.save.data.scrollSpeed = 4;

		return true;
	}
}

class RainbowFPSOption extends OptionTypeCheckmark
{
	public override function press():Bool
	{
		(cast(Lib.current.getChildAt(0), Main)).changeFPSColor(FlxColor.WHITE);
		return super.press();
	}
}

class AccuracyDOption extends Option
{
	public function new(desc:String)
	{
		super();
		if (OptionsMenu.isInPause)
			description = CoolUtil.translate('optionsUnavailableInPause');
		else
			description = CoolUtil.translate(desc);
	}

	public override function left():Bool
	{
		if (OptionsMenu.isInPause)
			return false;
		FlxG.save.data.accuracyMod = FlxG.save.data.accuracyMod == 1 ? 0 : 1;
		display = updateDisplay();
		return true;
	}

	public override function right():Bool
	{
		left();
		return true;
	}

	private override function updateDisplay():String
	{
		return CoolUtil.translate('optionsAccuracyCalc' + FlxG.save.data.accuracyMod);
	}
}

class CustomizeGameplay extends Option
{
	public function new(desc:String)
	{
		super();
		if (OptionsMenu.isInPause)
			description = CoolUtil.translate('optionsUnavailableInPause');
		else
			description = CoolUtil.translate(desc);
	}

	public override function press():Bool
	{
		if (OptionsMenu.isInPause)
			return false;
		trace("switch");
		FlxG.switchState(new GameplayCustomizeState());
		return false;
	}

	private override function updateDisplay():String
	{
		return CoolUtil.translate('optionsCustomizeGameplay');
	}
}

class WatermarkOption extends OptionTypeCheckmark
{
	public override function isChecked():Bool { return Main.watermarks; }

	public override function press():Bool
	{
		if (OptionsMenu.isInPause)
			return false;
		Main.watermarks = !Main.watermarks;
		FlxG.save.data.watermark = Main.watermarks;
		display = updateDisplay();
		return true;
	}
}

class OffsetThing extends Option
{
	public function new(desc:String)
	{
		super();
		if (OptionsMenu.isInPause)
			description = CoolUtil.translate('optionsUnavailableInPause');
		else
			description = CoolUtil.translate(desc);
	}

	public override function left():Bool
	{
		if (OptionsMenu.isInPause)
			return false;
		FlxG.save.data.offset--;
		display = updateDisplay();
		return true;
	}

	public override function right():Bool
	{
		if (OptionsMenu.isInPause)
			return false;
		FlxG.save.data.offset++;
		display = updateDisplay();
		return true;
	}

	private override function updateDisplay():String
	{
		return CoolUtil.translate('optionsOffsetThing') + " < " + HelperFunctions.truncateFloat(FlxG.save.data.offset, 0) + " >";
	}

	public override function getValue():String
	{
		return CoolUtil.translate('optionsOffsetThing') + " < " + HelperFunctions.truncateFloat(FlxG.save.data.offset, 0) + " >";
	}
}

class NoteskinOption extends Option
{
	public function new(desc:String)
	{
		super();
		if (OptionsMenu.isInPause)
			description = CoolUtil.translate('optionsUnavailableInPause');
		else
			description = CoolUtil.translate(desc);
	}

	public override function left():Bool
	{
		if (OptionsMenu.isInPause)
			return false;
		FlxG.save.data.noteskin--;
		if (FlxG.save.data.noteskin < 0)
			FlxG.save.data.noteskin = NoteskinHelpers.getNoteskins().length - 1;
		display = updateDisplay();
		return true;
	}

	public override function right():Bool
	{
		if (OptionsMenu.isInPause)
			return false;
		FlxG.save.data.noteskin++;
		if (FlxG.save.data.noteskin > NoteskinHelpers.getNoteskins().length - 1)
			FlxG.save.data.noteskin = 0;
		display = updateDisplay();
		return true;
	}

	public override function getValue():String
	{
		return CoolUtil.translate('optionsNoteskin') + " < " + NoteskinHelpers.getNoteskinByID(FlxG.save.data.noteskin) + " >";
	}
}

class LaneUnderlayOption extends Option
{
	public function new(desc:String)
	{
		super();
		if (OptionsMenu.isInPause)
			description = CoolUtil.translate('optionsUnavailableInPause');
		else
			description = CoolUtil.translate(desc);
		acceptValues = true;
	}

	private override function updateDisplay():String
	{
		return CoolUtil.translate('optionsLaneUnderlay') + " < " + HelperFunctions.truncateFloat(FlxG.save.data.laneTransparency, 1) + " >";
	}

	override function right():Bool
	{
		if (OptionsMenu.isInPause)
			return false;
		FlxG.save.data.laneTransparency += 0.1;

		if (FlxG.save.data.laneTransparency > 1)
			FlxG.save.data.laneTransparency = 1;
		return true;
	}

	override function left():Bool
	{
		if (OptionsMenu.isInPause)
			return false;
		FlxG.save.data.laneTransparency -= 0.1;

		if (FlxG.save.data.laneTransparency < 0)
			FlxG.save.data.laneTransparency = 0;

		return true;
	}
}

class LaneBorderOption extends Option
{
	public function new(desc:String)
	{
		super();
		if (OptionsMenu.isInPause)
			description = CoolUtil.translate('optionsUnavailableInPause');
		else
			description = CoolUtil.translate(desc);
		acceptValues = true;
	}

	public override function press():Bool
	{
		return false;
	}

	private override function updateDisplay():String
	{
		return CoolUtil.translate('optionsLaneBorder');
	}

	override function right():Bool {
		if (OptionsMenu.isInPause)
			return false;
		FlxG.save.data.laneBorder += 1;

		if (FlxG.save.data.laneBorder > 50)
			FlxG.save.data.laneBorder = 50;
		return true;
	}

	override function getValue():String {
		return CoolUtil.translate('optionsLaneBorder') + " < " + HelperFunctions.truncateFloat(FlxG.save.data.laneBorder, 1) + " >";
	}

	override function left():Bool {
		if (OptionsMenu.isInPause)
			return false;
		FlxG.save.data.laneBorder -= 1;

		if (FlxG.save.data.laneBorder < 0)
			FlxG.save.data.laneBorder = 0;

		return true;
	}
}

class DebugMode extends Option
{
	public function new(desc:String)
	{
		description = CoolUtil.translate(desc);
		super();
	}

	public override function press():Bool
	{
		FlxG.switchState(new AnimationDebug());
		return false;
	}

	private override function updateDisplay():String
	{
		return "Animation Debug";
	}
}

class ResetScoreOption extends Option
{
	var confirm:Bool = false;

	public function new(desc:String)
	{
		super();
		if (OptionsMenu.isInPause)
			description = CoolUtil.translate('optionsUnavailableInPause');
		else
			description = CoolUtil.translate(desc);
	}

	public override function press():Bool
	{
		if (OptionsMenu.isInPause)
			return false;
		if (!confirm)
		{
			confirm = true;
			display = updateDisplay();
			return true;
		}
		FlxG.save.data.songScores = null;
		for (key in Highscore.songScores.keys())
		{
			Highscore.songScores[key] = 0;
		}
		FlxG.save.data.songCombos = null;
		for (key in Highscore.songCombos.keys())
		{
			Highscore.songCombos[key] = '';
		}
		confirm = false;
		trace('Highscores Wiped');
		display = updateDisplay();
		return true;
	}

	private override function updateDisplay():String
	{
		return confirm ? CoolUtil.translate('optionsResetScoreConfirm') : CoolUtil.translate('optionsResetScore');
	}
}

class ResetSettings extends Option
{
	var confirm:Bool = false;

	public function new(desc:String)
	{
		super();
		if (OptionsMenu.isInPause)
			description = CoolUtil.translate('optionsUnavailableInPause');
		else
			description = CoolUtil.translate(desc);
	}

	public override function press():Bool
	{
		if (OptionsMenu.isInPause)
			return false;
		if (!confirm)
		{
			confirm = true;
			display = updateDisplay();
			return true;
		}
		FlxG.save.data.downscroll = null;
		FlxG.save.data.antialiasing = null;
		FlxG.save.data.missSounds = null;
		FlxG.save.data.dfjk = null;
		FlxG.save.data.accuracyDisplay = null;
		FlxG.save.data.offset = null;
		FlxG.save.data.songPosition = null;
		FlxG.save.data.fps = null;
		FlxG.save.data.changedHit = null;
		FlxG.save.data.fpsRain = null;
		FlxG.save.data.fpsCap = null;
		FlxG.save.data.scrollSpeed = null;
		FlxG.save.data.npsDisplay = null;
		FlxG.save.data.frames = null;
		FlxG.save.data.accuracyMod = null;
		FlxG.save.data.watermark = null;
		FlxG.save.data.distractions = null;
		FlxG.save.data.colour = null;
		FlxG.save.data.stepMania = null;
		FlxG.save.data.stepManiaColors = null;
		FlxG.save.data.rotateNotes = null;
		FlxG.save.data.flashing = null;
		FlxG.save.data.resetButton = null;
		FlxG.save.data.botplay = null;
		FlxG.save.data.cpuStrums = null;
		FlxG.save.data.strumline = null;
		FlxG.save.data.customStrumLine = null;
		FlxG.save.data.camzoom = null;
		FlxG.save.data.scoreScreen = null;
		FlxG.save.data.inputShow = null;
		FlxG.save.data.cacheImages = null;
		FlxG.save.data.editor = null;
		FlxG.save.data.colorIcons = null;
		FlxG.save.data.subtitles = null;
		FlxG.save.data.laneTransparency = 0;
		FlxG.save.data.laneBorder = null;
		FlxG.save.data.extraSongInfo = null;

		KadeEngineData.initSave();
		confirm = false;
		trace('All settings have been reset');
		display = updateDisplay();
		return true;
	}

	private override function updateDisplay():String
	{
		return confirm ? CoolUtil.translate('optionsResetSettingsConfirm') : CoolUtil.translate('optionsResetSettings');
	}
}
