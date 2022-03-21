package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.animation.FlxBaseAnimation;
import flixel.graphics.frames.FlxAtlasFrames;

using StringTools;

class StaticArrow extends FlxSprite
{
	public var modifiedByLua:Bool = false;
	public var modAngle:Float = 0; // The angle set by modcharts
	public var localAngle:Float = 0; // The angle to be edited inside here

	public function new(xx:Float, yy:Float)
	{
		x = xx;
		y = yy;
		super(x, y);
		updateHitbox();
	}

	override function update(elapsed:Float)
	{
		if (!modifiedByLua)
			angle = localAngle + modAngle;
		else
			angle = modAngle;
		super.update(elapsed);

		/*if (FlxG.keys.justPressed.THREE)
		{
			localAngle += 10;
		}*/
	}

	public function generateAnims(direction:String):Void
	{
		var lowerDir:String = direction.toLowerCase();

		animation.addByPrefix('static', 'arrow' + direction);
		animation.addByPrefix('pressed', lowerDir + ' press', 24, false);
		animation.addByPrefix('confirm', lowerDir + ' confirm', 24, false);

		var dataSuffix = ['left', 'down', 'yellowArrow', 'up', 'right'];

		if (lowerDir == 'center')
		{
			dataSuffix = ['purpleCenter', 'blueCenter', 'center', 'greenCenter', 'redCenter'];
		}

		for (j in 0...5)
		{
			animation.addByPrefix('dirCon' + j, dataSuffix[j] + ' confirm', 24, false);
		}
	}

	public function playAnim(AnimName:String, ?force:Bool = false):Void
	{
		animation.play(AnimName, force);

		if (!AnimName.startsWith('dirCon'))
		{
			localAngle = 0;
		}
		updateHitbox();
		offset.set(frameWidth / 2, frameHeight / 2);

		var noteScale = ( PlayState.SONG.fiveKey ? 0.8 : 1 );
		offset.x -= 54 * noteScale;
		offset.y -= 56 * noteScale;

		angle = localAngle + modAngle;
	}
}
