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
#if FEATURE_DISCORD
import Discord.DiscordClient;
#end

using StringTools;

class StoryMenuState extends MusicBeatState
{
	var scoreText:FlxText;

	static function weekData():Array<String>
	{
		return ['dungeon', 'risking-life', 'vengeance', 'revival'];
	}

	var curDifficulty:String = "Normal";

	var diffs:Array<String> = [];

	var curWeek:Int = 0;

	var grpWeekText:FlxTypedGroup<MenuItem>;

	var difficultySelectors:FlxGroup;
	var sprDifficulty:FlxSprite;
	var leftArrow:FlxSprite;
	var rightArrow:FlxSprite;

	function loadDifficulties()
	{
		diffs = CoolUtil.coolTextFile(Paths.txt('data/storyDifficulties'));
		if (diffs.contains("Normal"))
			curDifficulty = "Normal"
		else
			curDifficulty = diffs[0];
	}

	override function create()
	{
		loadDifficulties();

		PlayState.currentSong = "bruh";
		PlayState.inDaPlay = false;
		#if FEATURE_DISCORD
		// Updating Discord Rich Presence
		DiscordClient.changePresence("In the Story Mode Menu", null);
		#end

		transIn = FlxTransitionableState.defaultTransIn;
		transOut = FlxTransitionableState.defaultTransOut;

		if (FlxG.sound.music != null)
		{
			if (!FlxG.sound.music.playing)
			{
				FlxG.sound.playMusic(Paths.music('freakyMenu'));
				Conductor.changeBPM(130);
			}
		}

		persistentUpdate = persistentDraw = true;

		scoreText = new FlxText(10, 10, 0, "SCORE: 49324858", 36);
		scoreText.setFormat("VCR OSD Mono", 32);

		var ui_tex = Paths.getSparrowAtlas('campaign_menu_UI_assets');
		var yellowBG:FlxSprite = new FlxSprite(0, 56).makeGraphic(FlxG.width, 400, 0xFF8B8E98);

		var storyBanner:FlxSprite = new FlxSprite(0, -44).loadGraphic(Paths.image('storymenu/storyBanner'));
		storyBanner.setGraphicSize(Std.int(storyBanner.width * 2 / 3));
		storyBanner.screenCenter(X);
		storyBanner.antialiasing = FlxG.save.data.antialiasing;

		grpWeekText = new FlxTypedGroup<MenuItem>();
		add(grpWeekText);

		var blackBarThingie:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, 56, FlxColor.BLACK);
		add(blackBarThingie);

		trace("Line 70");

		var weekThing:MenuItem = new MenuItem(0, yellowBG.y + yellowBG.height + 10, 0);
		grpWeekText.add(weekThing);

		weekThing.screenCenter(X);
		weekThing.antialiasing = FlxG.save.data.antialiasing;

		trace("Line 96");

		difficultySelectors = new FlxGroup();
		add(difficultySelectors);

		trace("Line 124");

		leftArrow = new FlxSprite(grpWeekText.members[0].x - 30, grpWeekText.members[0].y + 120);
		leftArrow.frames = ui_tex;
		leftArrow.animation.addByPrefix('idle', "arrow left");
		leftArrow.animation.addByPrefix('press', "arrow push left");
		leftArrow.animation.play('idle');
		leftArrow.antialiasing = FlxG.save.data.antialiasing;
		leftArrow.offset.y = -5;
		difficultySelectors.add(leftArrow);

		sprDifficulty = new FlxSprite(leftArrow.x + 130, leftArrow.y);
		sprDifficulty.loadGraphic(Paths.image('storymenu/diff' + curDifficulty));
		sprDifficulty.antialiasing = FlxG.save.data.antialiasing;
		changeDifficulty();

		difficultySelectors.add(sprDifficulty);

		rightArrow = new FlxSprite(sprDifficulty.x + 250, leftArrow.y);
		rightArrow.frames = ui_tex;
		rightArrow.animation.addByPrefix('idle', 'arrow right');
		rightArrow.animation.addByPrefix('press', "arrow push right", 24, false);
		rightArrow.animation.play('idle');
		rightArrow.antialiasing = FlxG.save.data.antialiasing;
		rightArrow.offset.y = -5;
		difficultySelectors.add(rightArrow);

		trace("Line 150");

		add(yellowBG);
		add(storyBanner);

		add(scoreText);

		updateText();

		trace("Line 165");

		super.create();
	}

	override function update(elapsed:Float)
	{
		// scoreText.setFormat('VCR OSD Mono', 32);
		lerpScore = Math.floor(FlxMath.lerp(lerpScore, intendedScore, 0.5));

		scoreText.text = "WEEK SCORE:" + lerpScore;

		// FlxG.watch.addQuick('font', scoreText.font);

		if (!movedBack)
		{
			if (!selectedWeek)
			{
				var gamepad:FlxGamepad = FlxG.gamepads.lastActive;

				if (gamepad != null)
				{
					if (gamepad.pressed.DPAD_RIGHT)
					{
						rightArrow.animation.play('press');
						rightArrow.offset.y = 0;
					}
					else
					{
						rightArrow.animation.play('idle');
						rightArrow.offset.y = -5;
					}
					if (gamepad.pressed.DPAD_LEFT)
					{
						leftArrow.animation.play('press');
						leftArrow.offset.x = 6;
						leftArrow.offset.y = 0;
					}
					else
					{
						leftArrow.animation.play('idle');
						leftArrow.offset.x = 0;
						leftArrow.offset.y = -5;
					}

					if (gamepad.justPressed.DPAD_RIGHT)
					{
						changeDifficulty(1);
					}
					if (gamepad.justPressed.DPAD_LEFT)
					{
						changeDifficulty(-1);
					}
				}

				if (controls.RIGHT)
				{
					rightArrow.animation.play('press');
					rightArrow.offset.y = 0;
				}
				else
				{
					rightArrow.animation.play('idle');
					rightArrow.offset.y = -5;
				}

				if (controls.LEFT)
				{
					leftArrow.animation.play('press');
					leftArrow.offset.x = 6;
					leftArrow.offset.y = 0;
				}
				else
				{
					leftArrow.animation.play('idle');
					leftArrow.offset.x = 0;
					leftArrow.offset.y = -5;
				}

				if (controls.RIGHT_P)
					changeDifficulty(1);
				if (controls.LEFT_P)
					changeDifficulty(-1);
			}

			if (controls.ACCEPT)
			{
				selectWeek();
			}
		}

		if (controls.BACK && !movedBack && !selectedWeek)
		{
			FlxG.sound.play(Paths.sound('cancelMenu'));
			movedBack = true;
			FlxG.switchState(new MainMenuState());
		}

		if (FlxG.sound.music != null)
			Conductor.songPosition = FlxG.sound.music.time;

		super.update(elapsed);
	}

	var movedBack:Bool = false;
	var selectedWeek:Bool = false;
	var stopspamming:Bool = false;

	function selectWeek()
	{
		if (stopspamming == false)
		{
			FlxG.sound.play(Paths.sound('confirmMenu'));

			grpWeekText.members[curWeek].startFlashing();
			stopspamming = true;
		}

		PlayState.storyPlaylist = weekData();
		PlayState.isStoryMode = true;
		selectedWeek = true;
		PlayState.songMultiplier = 1;

		PlayState.isSM = false;

		PlayState.storyDifficulty = curDifficulty;

		PlayState.sicks = 0;
		PlayState.bads = 0;
		PlayState.shits = 0;
		PlayState.goods = 0;
		PlayState.campaignMisses = 0;
		PlayState.SONG = Song.conversionChecks(Song.loadFromJson(PlayState.storyPlaylist[0], curDifficulty));
		PlayState.storyWeek = 0;
		PlayState.campaignScore = 0;
		PlayState.hasSkipped = false;
		FlxG.sound.music.fadeOut(1.5);
		new FlxTimer().start(1, function(tmr:FlxTimer)
		{
			LoadingState.loadAndSwitchState(new OpeningCutsceneState(), true);
		});
	}

	function changeDifficulty(change:Int = 0):Void
	{
		var diffInt = diffs.indexOf(curDifficulty);
		var diffIntPrev = diffInt;
		diffInt += change;
		if (diffInt < 0)
			diffInt = diffs.length - 1;
		if (diffInt >= diffs.length)
			diffInt = 0;

		if (diffInt == diffIntPrev && change != 0)
			return;

		curDifficulty = diffs[diffInt];

		sprDifficulty.loadGraphic(Paths.image('storymenu/diff' + curDifficulty));
		sprDifficulty.offset.x = Std.int((sprDifficulty.width / 2) - 80);

		sprDifficulty.alpha = 0;

		// USING THESE WEIRD VALUES SO THAT IT DOESNT FLOAT UP
		sprDifficulty.y = leftArrow.y - 15;
		intendedScore = Highscore.getWeekScore(curWeek, curDifficulty);

		#if !switch
		intendedScore = Highscore.getWeekScore(curWeek, curDifficulty);
		#end

		FlxTween.tween(sprDifficulty, {y: leftArrow.y + 15, alpha: 1}, 0.07);
	}

	var lerpScore:Int = 0;
	var intendedScore:Int = 0;

	function updateText()
	{
		#if !switch
		intendedScore = Highscore.getWeekScore(curWeek, curDifficulty);
		#end
	}
}
