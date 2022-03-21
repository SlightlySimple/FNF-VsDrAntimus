package;

import flixel.input.gamepad.FlxGamepad;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.transition.FlxTransitionableState;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.group.FlxGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import lime.net.curl.CURLCode;

#if desktop
import Discord.DiscordClient;
#end

using StringTools;

class StoryBeatenState extends MusicBeatState
{
	override function create()
	{
		var endText = new FlxText(0, 0, 0, CoolUtil.translate('endText1'), 48);
		endText.setFormat("VCR OSD Mono", 48);
		if (PlayState.storyDifficulty == "Hard")
		{
			if (FlxG.save.data.antimusProgress[0] < 3 || FlxG.save.data.antimusProgress[1] < 3 || FlxG.save.data.antimusProgress[2] < 3 || FlxG.save.data.antimusProgress[3] < 3)
				endText.text = CoolUtil.translate('endText2');
			else
			{
				endText.text = CoolUtil.translate('endText3');
				FlxG.save.data.antimusProgress[4] = 1;
			}
		}
		endText.alignment = FlxTextAlign.CENTER;
		endText.screenCenter();
		add(endText);

		super.create();
	}

	override function update(elapsed:Float)
	{
		if (controls.ACCEPT)
		{
			FlxG.sound.playMusic(Paths.music('freakyMenu'));
			Conductor.changeBPM(130);
			FlxG.switchState(new StoryMenuState());
			clean();
		}

		super.update(elapsed);
	}
}
