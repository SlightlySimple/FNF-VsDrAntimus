package;

import sys.FileSystem;
import sys.io.File;

import flixel.FlxG;
import flixel.FlxBasic;
import openfl.utils.Assets as OpenFlAssets;
import flixel.addons.transition.FlxTransitionableState;

import flixel.FlxSprite;
import flixel.system.FlxSound;
import flixel.FlxCamera;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.ui.FlxBar;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;

import hscript.Parser as HSParser;
import hscript.Interp as HSInterp;

using StringTools;

class HscriptHandler
{
	var interp:HSInterp;

	public static function parseColor(col:String)
	{
		return FlxColor.fromString(col);
	}

	public function new(scriptFile:String)
	{
		var myCode = OpenFlAssets.getText(Paths.hs(scriptFile));
		var parser = new HSParser();
		var program = parser.parseString(myCode);
		interp = new HSInterp();

		refreshVariables();

		interp.execute(program); 
	}

	public function refreshVariables()
	{
		interp.variables.set("Math", Math);
		interp.variables.set("StringTools", StringTools);
		interp.variables.set("FlxG", FlxG);
		interp.variables.set("FlxG.random.bool", FlxG.random.bool);
		interp.variables.set("FlxG.sound.cache", FlxG.sound.cache);
		interp.variables.set("FlxTransitionableState", FlxTransitionableState);
		interp.variables.set("FlxSprite", FlxSprite);
		interp.variables.set("FlxSound", FlxSound);
		interp.variables.set("FlxCamera", FlxCamera);
		interp.variables.set("FlxCameraFollowStyle", FlxCameraFollowStyle);
		interp.variables.set("FlxMath", FlxMath);
		interp.variables.set("FlxText", FlxText);
		interp.variables.set("FlxTextBorderStyle", FlxTextBorderStyle);
		interp.variables.set("FlxBar", FlxBar);
		interp.variables.set("FlxBarFillDirection", FlxBarFillDirection);
		interp.variables.set("FlxTween", FlxTween);
		interp.variables.set("FlxEase", FlxEase);
		interp.variables.set("FlxTimer", FlxTimer);
		interp.variables.set("Std", Std);
		interp.variables.set("Paths", Paths);
		interp.variables.set("Paths.soundRandom", Paths.soundRandom);
		interp.variables.set("Paths.music", Paths.music);
		interp.variables.set("Paths.font", Paths.font);
		interp.variables.set("parseColor", HscriptHandler.parseColor);
		interp.variables.set("Character", Character);

		interp.variables.set("Conductor", Conductor);
		interp.variables.set("PlayState", PlayState);
		interp.variables.set("PlayStateInstance", PlayState.instance);
		interp.variables.set("PlayStateChangeables", PlayStateChangeables);
		interp.variables.set("add", PlayState.instance.add);
		interp.variables.set("remove", PlayState.instance.remove);
		interp.variables.set("SONG", PlayState.SONG);
		interp.variables.set("boyfriend", PlayState.boyfriend);
		interp.variables.set("gf", PlayState.gf);
		interp.variables.set("dad", PlayState.dad);
		interp.variables.set("Stage", PlayState.Stage);
		interp.variables.set("camHUD", PlayState.instance.camHUD);
		interp.variables.set("camCutsceneHUD", PlayState.instance.camCutsceneHUD);
		interp.variables.set("saveData", FlxG.save.data);
	}

	public function execFunc(func:String, args:Array<Dynamic>)
	{
		if (interp.variables.exists(func))
		{
			var execMe = interp.variables.get(func);
			if (Reflect.isFunction(execMe))
			{
				switch (args.length)
				{
					case 1:
						execMe(args[0]);
					case 2:
						execMe(args[0], args[1]);
					case 3:
						execMe(args[0], args[1], args[2]);
					case 4:
						execMe(args[0], args[1], args[2], args[3]);
					default:
						execMe();
				}
			}
		}
	}

	public function setVar(vari:String, val:Dynamic)
	{
		interp.variables.set(vari, val);
	}
}