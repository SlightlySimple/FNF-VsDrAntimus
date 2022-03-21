package;

import flixel.system.FlxSound;
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
import flixel.tweens.FlxEase;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import lime.net.curl.CURLCode;
import flixel.ui.FlxBar;

#if desktop
import Discord.DiscordClient;
#end

using StringTools;

class OpeningCutsceneState extends MusicBeatState
{

	var GirlfriendBody:FlxSprite;
	var GirlfriendFace:FlxSprite;
	var BoyfriendBody:FlxSprite;
	var BoyfriendFace:FlxSprite;
	var GirlfriendArm:FlxSprite;
	var SpinningPhone:FlxSprite;
	var letter:FlxSprite;
	var cutsceneEnter:FlxSprite;

	var cutsceneStatus:Int = 0;
	var animFrame:Int = 0;
	var animFramePrev:Int = 0;

	var cutsceneSkipProgress:Float = 0;
	var cutsceneSkipProgressBar:FlxBar;

	override function create()
	{
		var back:FlxSprite = new FlxSprite(-124, -125).loadGraphic(Paths.image('openingCutscene/back', 'cutscenes'));
		back.antialiasing = FlxG.save.data.antialiasing;
		add(back);

		var bed:FlxSprite = new FlxSprite(307 * 1.5, 286 * 1.5).loadGraphic(Paths.image('openingCutscene/bed', 'cutscenes'));
		bed.antialiasing = FlxG.save.data.antialiasing;
		add(bed);

		GirlfriendBody = new FlxSprite(-328 * 1.5, -29 * 1.5);
		GirlfriendBody.antialiasing = FlxG.save.data.antialiasing;
		GirlfriendBody.frames = Paths.getSparrowAtlas('openingCutscene/GirlfriendBody', 'cutscenes');
		GirlfriendBody.animation.addByPrefix('anim1', 'anim 1', 24, false);
		GirlfriendBody.animation.addByPrefix('anim2', 'anim 2', 24, false);
		add(GirlfriendBody);

		GirlfriendFace = new FlxSprite(-122 * 1.5, 133 * 1.5);
		GirlfriendFace.antialiasing = FlxG.save.data.antialiasing;
		GirlfriendFace.frames = Paths.getSparrowAtlas('openingCutscene/GirlfriendFace', 'cutscenes');
		GirlfriendFace.animation.addByPrefix('anim1', 'anim 1', 24, false);
		GirlfriendFace.animation.addByPrefix('anim2', 'anim 2', 24, false);
		add(GirlfriendFace);

		BoyfriendBody = new FlxSprite(312 * 1.5, -28 * 1.5);
		BoyfriendBody.antialiasing = FlxG.save.data.antialiasing;
		BoyfriendBody.frames = Paths.getSparrowAtlas('openingCutscene/BoyfriendBody', 'cutscenes');
		BoyfriendBody.animation.addByPrefix('anim1', 'anim 1', 24, false);
		BoyfriendBody.animation.addByPrefix('anim2', 'anim 2', 24, false);
		add(BoyfriendBody);

		BoyfriendFace = new FlxSprite(425 * 1.5, 32 * 1.5);
		BoyfriendFace.antialiasing = FlxG.save.data.antialiasing;
		BoyfriendFace.frames = Paths.getSparrowAtlas('openingCutscene/BoyfriendFace', 'cutscenes');
		BoyfriendFace.animation.addByPrefix('anim1', 'anim 1', 24, false);
		BoyfriendFace.animation.addByPrefix('anim2', 'anim 2', 24, false);
		add(BoyfriendFace);

		GirlfriendArm = new FlxSprite(-92 * 1.5, 94 * 1.5);
		GirlfriendArm.antialiasing = FlxG.save.data.antialiasing;
		GirlfriendArm.frames = Paths.getSparrowAtlas('openingCutscene/GirlfriendArm', 'cutscenes');
		GirlfriendArm.animation.addByPrefix('anim1', 'anim 1', 24, false);
		GirlfriendArm.animation.addByPrefix('anim2', 'anim 2', 24, false);
		add(GirlfriendArm);

		SpinningPhone = new FlxSprite(374 * 1.5, 132 * 1.5);
		SpinningPhone.antialiasing = FlxG.save.data.antialiasing;
		SpinningPhone.frames = Paths.getSparrowAtlas('openingCutscene/SpinningPhone', 'cutscenes');
		SpinningPhone.animation.addByPrefix('anim', 'anim', 24, true);

		letter = new FlxSprite(0, 0).loadGraphic(Paths.image('openingCutscene/letter', 'cutscenes'));
		letter.antialiasing = FlxG.save.data.antialiasing;
		letter.setGraphicSize(Std.int(letter.width * 2 / 3));
		letter.screenCenter();
		letter.alpha = 0;
		add(letter);

		cutsceneEnter = new FlxSprite(FlxG.width - 300, 20);
		cutsceneEnter.frames = Paths.getSparrowAtlas('cutsceneEnter', 'cutscenes');
		cutsceneEnter.animation.addByPrefix('anim', 'idle', 12, true);
		cutsceneEnter.antialiasing = FlxG.save.data.antialiasing;
		cutsceneEnter.setGraphicSize(Std.int(cutsceneEnter.width * 3 / 4));

		GirlfriendBody.animation.play('anim1');
		GirlfriendFace.animation.play('anim1');
		BoyfriendBody.animation.play('anim1');
		BoyfriendFace.animation.play('anim1');
		GirlfriendArm.animation.play('anim1');

		cutsceneStatus = 0;
		animFrame = 0;
		animFramePrev = 0;

		FlxG.sound.playMusic(Paths.music('breakfast'));
		FlxG.sound.music.fadeIn(1, 0, 0.2);

		cutsceneSkipProgressBar = new FlxBar(200, FlxG.height - 150, FlxBarFillDirection.LEFT_TO_RIGHT, FlxG.width - 400, 25, this, "cutsceneSkipProgress", 0, 1);
        cutsceneSkipProgressBar.createFilledBar(FlxColor.BLACK, FlxColor.WHITE);
		cutsceneSkipProgressBar.alpha = 0;
		add(cutsceneSkipProgressBar);

		super.create();
	}

	override function update(elapsed:Float)
	{
		if (FlxG.keys.pressed.SPACE)
		{
			if (cutsceneSkipProgress < 1)
			{
				cutsceneSkipProgress += elapsed;
				cutsceneSkipProgressBar.alpha = Math.min( 1, cutsceneSkipProgress * 10 );
			}
			else
			{
				transIn = FlxTransitionableState.defaultTransIn;
				transOut = FlxTransitionableState.defaultTransOut;

				FlxTransitionableState.skipNextTransIn = false;
				FlxTransitionableState.skipNextTransOut = false;

				FlxG.sound.music.fadeOut(2.5);
				PlayState.hasPlayedCutscene = true;
				LoadingState.loadAndSwitchState(new PlayState());
				clean();
			}
		}
		else
		{
			cutsceneSkipProgress = 0;
			cutsceneSkipProgressBar.alpha = 0;
		}

		animFrame = BoyfriendBody.animation.curAnim.curFrame;
		switch (cutsceneStatus)
		{
			case 0:
				if (animFramePrev != animFrame)
				{
					switch (animFrame)
					{
						case 29 | 38 | 46 | 53 | 62 | 70 | 79:
							FlxG.sound.play(Paths.soundRandom('openingCutscene/step', 1, 5, 'cutscenes'));

						case 111:
							add(SpinningPhone);
							SpinningPhone.animation.play('anim');

							FlxTween.tween(SpinningPhone, {y: -350}, 0.5, {
								ease: FlxEase.quadOut,
								onComplete: function(twn) {
									FlxTween.tween(SpinningPhone, {y: 146 * 1.5}, 0.5, {
										ease: FlxEase.quadIn
									});
								}
							});

							FlxTween.tween(SpinningPhone, {x: 278 * 1.5}, 0.91, {
								ease: FlxEase.linear
							});

							FlxG.sound.play(Paths.sound('openingCutscene/phoneFlyLoop', 'cutscenes'));

						case 134:
							remove(SpinningPhone);
							FlxG.sound.play(Paths.sound('openingCutscene/phoneGrab', 'cutscenes'));

						case 212:
							FlxG.sound.play(Paths.sound('openingCutscene/showLetter', 'cutscenes'));
					}
				}

				if (BoyfriendBody.animation.curAnim.finished)
				{
					cutsceneStatus = 1;
					letter.alpha = 1;
					add(cutsceneEnter);
					cutsceneEnter.alpha = 0;
					cutsceneEnter.x -= 150;
					cutsceneEnter.animation.play('anim');
					FlxTween.tween(cutsceneEnter, {x: cutsceneEnter.x + 150, alpha: 1}, 0.5, {
						ease: FlxEase.quadOut
					});
				}

			case 1:
				if (controls.ACCEPT)
				{
					cutsceneStatus = 2;
					remove(letter);
					FlxTween.tween(cutsceneEnter, {x: cutsceneEnter.x + 150, alpha: 0}, 0.25, {
						ease: FlxEase.quadIn
					});

					GirlfriendBody.animation.play('anim2');
					GirlfriendFace.animation.play('anim2');
					BoyfriendBody.animation.play('anim2');
					BoyfriendFace.animation.play('anim2');
					GirlfriendArm.animation.play('anim2');
				}

			case 2:
				if (GirlfriendBody.animation.curAnim.finished)
				{
					cutsceneStatus = 3;

					transIn = FlxTransitionableState.defaultTransIn;
					transOut = FlxTransitionableState.defaultTransOut;

					FlxTransitionableState.skipNextTransIn = false;
					FlxTransitionableState.skipNextTransOut = false;

					FlxG.sound.music.fadeOut(2.5);
					new FlxTimer().start(2, function(tmr:FlxTimer)
					{
						PlayState.hasPlayedCutscene = false;
						LoadingState.loadAndSwitchState(new PlayState());
						clean();
					});
				}
		}
		animFramePrev = animFrame;

		super.update(elapsed);
	}
}
