package;

import flixel.addons.effects.FlxSkewedSprite;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.math.FlxMath;
import flixel.util.FlxColor;
#if polymod
import polymod.format.ParseRules.TargetSignatureElement;
#end
import PlayState;

using StringTools;

class Note extends FlxSprite
{
	public var strumTime:Float = 0;
	public var baseStrum:Float = 0;

	public var inCharter:Bool = false;
	public var charterSelected:Bool = false;

	public var rStrumTime:Float = 0;

	public var isCenterNote:Bool = false;
	public var mustPress:Bool = false;
	public var noteData:Int = 0;
	public var rawNoteData:Int = 0;
	public var canBeHit:Bool = false;
	public var tooLate:Bool = false;
	public var wasGoodHit:Bool = false;
	public var prevNote:Note;
	public var modifiedByLua:Bool = false;
	public var sustainLength:Float = 0;
	public var isSustainNote:Bool = false;
	public var originColor:Int = 0; // The sustain note's original note's color
	public var noteSection:Int = 0;

	public var luaID:Int = 0;

	public var isAlt:Bool = false;
	public var downscroll:Bool = false;

	public var noteCharterObject:FlxSprite;

	public var noteScore:Float = 1;

	public var noteYOff:Int = 0;

	public static var swagWidth:Float = 160 * 0.7;

	public var rating:String = "shit";

	public var modAngle:Float = 0; // The angle set by modcharts
	public var localAngle:Float = 0; // The angle to be edited inside Note.hx
	public var originAngle:Float = 0; // The angle the OG note of the sus note had (?)

	public var dataColor:Array<String> = ['purple', 'blue', 'yellow', 'green', 'red'];
	public var arrowAngles:Array<Int> = [180, 90, 0, 270, 0];

	public var isParent:Bool = false;
	public var parent:Note = null;
	public var spotInLine:Int = 0;
	public var sustainActive:Bool = true;

	public var children:Array<Note> = [];

	public function new(strumTime:Float, noteData:Int, ?prevNote:Note, ?sustainNote:Bool = false, ?inCharter:Bool = false, ?isAlt:Bool = false)
	{
		super();

		if (prevNote == null)
			prevNote = this;

		var noteScale = ( PlayState.SONG.fiveKey ? 0.8 : 1 );

		if ( PlayState.SONG.fiveKey && noteData == 2 )
			isCenterNote = true;

		downscroll = isAlt;

		this.prevNote = prevNote;
		isSustainNote = sustainNote;

		x += 96;
		// MAKE SURE ITS DEFINITELY OFF SCREEN?
		y -= 2000;

		this.inCharter = inCharter;

		if (inCharter)
		{
			this.strumTime = strumTime;
			rStrumTime = strumTime;
		}
		else
		{
			this.strumTime = strumTime;
			#if FEATURE_STEPMANIA
			if (PlayState.isSM)
			{
				rStrumTime = strumTime;
			}
			else
				rStrumTime = strumTime;
			#else
			rStrumTime = strumTime;
			#end
		}

		if (this.strumTime < 0)
			this.strumTime = 0;

		if (!inCharter)
			y += FlxG.save.data.offset + PlayState.songOffset;

		this.noteData = noteData;

		var daStage:String = PlayState.Stage.curStage;

		// defaults if no noteStyle was found in chart
		var noteTypeCheck:String = 'normal';

		if (inCharter)
		{
			frames = PlayState.noteskinSprite;

			for (i in 0...dataColor.length)
			{
				if (isCenterNote)
					animation.addByPrefix(dataColor[i] + 'Scroll', dataColor[i] + ' center'); // Normal notes
				else
					animation.addByPrefix(dataColor[i] + 'Scroll', dataColor[i] + ' arrow'); // Normal notes
				animation.addByPrefix(dataColor[i] + 'hold', dataColor[i] + ' hold'); // Hold
				animation.addByPrefix(dataColor[i] + 'holdend', dataColor[i] + ' tail'); // Tails
			}

			if (isCenterNote)
			{
				for (i in 0...dataColor.length)
					animation.addByPrefix('ds' + dataColor[i] + 'Scroll', 'arrowCENTER');
			}
			else
			{
				animation.addByPrefix('ds' + dataColor[0] + 'Scroll', 'arrowLEFT');
				animation.addByPrefix('ds' + dataColor[1] + 'Scroll', 'arrowDOWN');
				animation.addByPrefix('ds' + dataColor[2] + 'Scroll', 'arrowRIGHT');
				animation.addByPrefix('ds' + dataColor[3] + 'Scroll', 'arrowUP');
				animation.addByPrefix('ds' + dataColor[4] + 'Scroll', 'arrowRIGHT');
			}

			setGraphicSize(Std.int(width * 0.7));
			updateHitbox();
			antialiasing = FlxG.save.data.antialiasing;
		}
		else
		{
			frames = PlayState.noteskinSprite;

			for (i in 0...dataColor.length)
			{
				if (isCenterNote)
					animation.addByPrefix(dataColor[i] + 'Scroll', dataColor[i] + ' center'); // Normal notes
				else
					animation.addByPrefix(dataColor[i] + 'Scroll', dataColor[i] + ' arrow'); // Normal notes
				animation.addByPrefix(dataColor[i] + 'hold', dataColor[i] + ' hold'); // Hold
				animation.addByPrefix(dataColor[i] + 'holdend', dataColor[i] + ' tail'); // Tails
			}

			setGraphicSize(Std.int(width * ( 0.7 * noteScale )));
			updateHitbox();

			antialiasing = FlxG.save.data.antialiasing;
		}

		x += ( swagWidth * noteScale ) * noteData;
		originColor = noteData; // The note's origin color will be checked by its sustain notes
		if ( originColor >= 2 && !PlayState.SONG.fiveKey )
			originColor++;
		animation.play(dataColor[originColor] + 'Scroll');

		if (FlxG.save.data.stepMania && !isSustainNote)
		{
			var col:Int = 0;

			var beat = TimingStruct.getBeatFromTime(this.strumTime);
			var beatRow = Math.round(beat * 48);

			// STOLEN ETTERNA CODE (IN 2002)

			if (beatRow % (192 / 4) == 0)
				col = FlxG.save.data.stepManiaColors[0];
			else if (beatRow % (192 / 8) == 0)
				col = FlxG.save.data.stepManiaColors[1];
			else if (beatRow % (192 / 12) == 0)
				col = FlxG.save.data.stepManiaColors[2];
			else if (beatRow % (192 / 16) == 0)
				col = FlxG.save.data.stepManiaColors[3];
			else if (beatRow % (192 / 24) == 0)
				col = FlxG.save.data.stepManiaColors[4];
			else if (beatRow % (192 / 32) == 0)
				col = FlxG.save.data.stepManiaColors[5];

			animation.play(dataColor[col] + 'Scroll');
			if (FlxG.save.data.rotateNotes && !isCenterNote)
			{
				localAngle -= arrowAngles[col];
				localAngle += arrowAngles[originColor];
				originAngle = localAngle;
			}
			originColor = col;
		}

		// So uh apparently there was an argument here or smth but uh I removed it lol
		if (downscroll && sustainNote)
			flipY = true;

		var stepHeight = (((0.45 * Conductor.stepCrochet)) * FlxMath.roundDecimal(PlayStateChangeables.scrollSpeed == 1 ? PlayState.SONG.speed : PlayStateChangeables.scrollSpeed,
			2)) / PlayState.songMultiplier;

		if (isSustainNote && prevNote != null)
		{
			noteYOff = Math.round(-stepHeight + swagWidth * 0.5);

			noteScore * 0.2;
			alpha = 0.6;

			x += ( width / 2 ) * noteScale;

			originColor = prevNote.originColor;
			originAngle = prevNote.originAngle;

			animation.play(dataColor[originColor] + 'holdend'); // This works both for normal colors and quantization colors
			updateHitbox();

			x -= ( width / 2 ) * noteScale;

			if (inCharter)
				x += 30;

			if (prevNote.isSustainNote)
			{
				prevNote.animation.play(dataColor[prevNote.originColor] + 'hold');
				prevNote.updateHitbox();

				prevNote.scale.y *= stepHeight / prevNote.height;
				prevNote.updateHitbox();

				if (antialiasing)
					prevNote.scale.y *= 1.0 + (1.0 / prevNote.frameHeight);
			}
		}
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);
		if (!modifiedByLua)
			angle = modAngle + localAngle;
		else
			angle = modAngle;

		if (!modifiedByLua)
		{
			if (!sustainActive)
			{
				alpha = 0.3;
			}
		}

		if (mustPress)
		{
			if (isSustainNote)
			{
				if (strumTime - Conductor.songPosition <= (((166 * Conductor.timeScale) / (PlayState.songMultiplier < 1 ? PlayState.songMultiplier : 1) * 0.5))
					&& strumTime - Conductor.songPosition >= (((-166 * Conductor.timeScale) / (PlayState.songMultiplier < 1 ? PlayState.songMultiplier : 1))))
					canBeHit = true;
				else
					canBeHit = false;
			}
			else
			{
				if (strumTime - Conductor.songPosition <= (((166 * Conductor.timeScale) / (PlayState.songMultiplier < 1 ? PlayState.songMultiplier : 1)))
					&& strumTime - Conductor.songPosition >= (((-166 * Conductor.timeScale) / (PlayState.songMultiplier < 1 ? PlayState.songMultiplier : 1))))
					canBeHit = true;
				else
					canBeHit = false;
			}
			/*if (strumTime - Conductor.songPosition < (-166 * Conductor.timeScale) && !wasGoodHit)
				tooLate = true; */
		}
		else
		{
			canBeHit = false;
			// if (strumTime <= Conductor.songPosition)
			//	wasGoodHit = true;
		}

		if (tooLate && !wasGoodHit)
		{
			if (alpha > 0.3)
				alpha = 0.3;
		}

		if (inCharter)
		{
			if (downscroll && !animation.curAnim.name.startsWith('ds'))
				animation.play('ds' + animation.curAnim.name);
			if (!downscroll && animation.curAnim.name.startsWith('ds'))
				animation.play(animation.curAnim.name.replace('ds',''));
		}
	}
}
