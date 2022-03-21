package;

import openfl.utils.Future;
import openfl.media.Sound;
import flixel.system.FlxSound;
#if FEATURE_STEPMANIA
import smTools.SMFile;
#end
#if FEATURE_FILESYSTEM
import sys.FileSystem;
import sys.io.File;
#end
import Section.SwagSection;
import Song.SongData;
import flixel.input.gamepad.FlxGamepad;
import flash.text.TextField;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.display.FlxGridOverlay;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxStringUtil;
#if FEATURE_DISCORD
import Discord.DiscordClient;
#end

using StringTools;

class FreeplayState extends MusicBeatState
{
	public static var songs:Array<FreeplaySongMetadata> = [];

	var selector:FlxText;

	public static var rate:Float = 1.0;

	public static var curSelected:Int = 0;
	public static var curDifficulty:String = "Normal";

	var scoreText:FlxText;
	var comboText:FlxText;
	var diffText:FlxText;
	var previewtext:FlxText;
	var extraInfoText:FlxText;
	var noteImages:Array<FlxSprite>;
	var lerpScore:Int = 0;
	var intendedScore:Int = 0;
	var combo:String = '';

	private var grpSongs:FlxTypedGroup<Alphabet>;
	private var grpSongBacks:Array<FlxSprite>;
	private var grpSongSelectors:Array<FlxSprite>;
	private var curPlaying:Bool = false;

	public static var songData:Map<String, SongData> = [];

	public static function loadSongData(songId:String, difficulty:String)
	{
		return Song.loadFromJson(songId, difficulty);
	}

	public static var list:Array<String> = [];

	override function create()
	{
		clean();
		cached = false;

		populateSongData();
		PlayState.inDaPlay = false;
		PlayState.currentSong = "bruh";

		#if !FEATURE_STEPMANIA
		trace("FEATURE_STEPMANIA was not specified during build, sm file loading is disabled.");
		#elseif FEATURE_STEPMANIA
		// TODO: Refactor this to use OpenFlAssets.
		trace("tryin to load sm files");
		for (i in FileSystem.readDirectory("assets/sm/"))
		{
			trace(i);
			if (FileSystem.isDirectory("assets/sm/" + i))
			{
				trace("Reading SM file dir " + i);
				for (file in FileSystem.readDirectory("assets/sm/" + i))
				{
					if (file.contains(" "))
						FileSystem.rename("assets/sm/" + i + "/" + file, "assets/sm/" + i + "/" + file.replace(" ", "_"));
					if (file.endsWith(".sm") && !FileSystem.exists("assets/sm/" + i + "/converted.json"))
					{
						trace("reading " + file);
						var file:SMFile = SMFile.loadFile("assets/sm/" + i + "/" + file.replace(" ", "_"));
						trace("Converting " + file.header.TITLE);
						var data = file.convertToFNF("assets/sm/" + i + "/converted.json");
						var meta = new FreeplaySongMetadata(StringTools.replace(file.header.TITLE, " ", "-").toLowerCase(), FlxColor.fromString("0xEFE09B"), "sm", file, "assets/sm/" + i);
						meta.diffs = ['Normal'];
						songs.push(meta);
						var song = Song.loadFromJsonRAW(data);
						song.songId = StringTools.replace(file.header.TITLE, " ", "-").toLowerCase();
						songData.set(StringTools.replace(file.header.TITLE, " ", "-").toLowerCase() + 'Normal', song);
					}
					else if (FileSystem.exists("assets/sm/" + i + "/converted.json") && file.endsWith(".sm"))
					{
						trace("reading " + file);
						var file:SMFile = SMFile.loadFile("assets/sm/" + i + "/" + file.replace(" ", "_"));
						trace("Converting " + file.header.TITLE);
						var meta = new FreeplaySongMetadata(StringTools.replace(file.header.TITLE, " ", "-").toLowerCase(), FlxColor.fromString("0xEFE09B"), "sm", file, "assets/sm/" + i);
						meta.diffs = ['Normal'];
						songs.push(meta);
						var song = Song.loadFromJsonRAW(File.getContent("assets/sm/" + i + "/converted.json"));
						song.songId = StringTools.replace(file.header.TITLE, " ", "-").toLowerCase();
						trace("got content lol");
						songData.set(StringTools.replace(file.header.TITLE, " ", "-").toLowerCase() + 'Normal', song);
					}
				}
			}
		}
		#end

		#if FEATURE_DISCORD
		// Updating Discord Rich Presence
		DiscordClient.changePresence("In the Freeplay Menu", null);
		#end

		var isDebug:Bool = false;

		#if debug
		isDebug = true;
		#end

		persistentUpdate = true;

		// LOAD MUSIC

		// LOAD CHARACTERS

		var bg:FlxSprite = new FlxSprite().loadGraphic(Paths.loadImage('menuBGBlue'));
		bg.antialiasing = FlxG.save.data.antialiasing;
		add(bg);

		grpSongs = new FlxTypedGroup<Alphabet>();
		grpSongBacks = [];
		grpSongSelectors = [];

		var selectionFrames = Paths.getSparrowAtlas('freeplaymenu/selection');

		for (i in 0...songs.length)
		{
			var songTextData = songs[i].songName;
			var songColor = songs[i].color;
			if ( i <= 4 && FlxG.save.data.antimusProgress[i] < 1 )
			{
				songTextData = "songLocked";
				songColor = FlxColor.GRAY;
			}
			var songText:Alphabet = new Alphabet(0, (70 * i) + 30, CoolUtil.translate(songTextData), true, false, true);
			songText.targetY = i;
			grpSongs.add(songText);

			// songText.x += 40;
			// DONT PUT X IN THE FIRST PARAMETER OF new ALPHABET() !!
			songText.screenCenter(X);

			var songBack:FlxSprite = new FlxSprite(0, 0).loadGraphic(Paths.image('freeplaymenu/bg-' + songs[i].songBackImage));
			if ( i <= 4 && FlxG.save.data.antimusProgress[i] < 1 )
				songBack.loadGraphic(Paths.image('freeplaymenu/bg-locked'));
			songBack.y = songText.y - (songBack.height - songText.height) / 2;
			songBack.screenCenter(X);
			songBack.antialiasing = FlxG.save.data.antialiasing;
			if (i == 0)
				songBack.color = songColor;
			else if (songColor.saturation == 0)
				songBack.color = FlxColor.fromHSB(songColor.hue, songColor.saturation, songColor.brightness * 2 / 3);
			else
				songBack.color = FlxColor.fromHSB(songColor.hue, songColor.saturation / 2, songColor.brightness);
			add(songBack);
			grpSongBacks.push(songBack);

			var songFrame:FlxSprite = new FlxSprite(0, 0);
			songFrame.frames = selectionFrames;
			songFrame.animation.addByPrefix('idle', 'Center Box', 12, true);
			songFrame.animation.play('idle');
			songFrame.y = songBack.y - 20;
			songFrame.screenCenter(X);
			songFrame.antialiasing = FlxG.save.data.antialiasing;
			add(songFrame);
			grpSongSelectors.push(songFrame);
		}

		add(grpSongs);

		var leftArrow = new FlxSprite(0, 0);
		leftArrow.frames = selectionFrames;
		leftArrow.animation.addByPrefix('idle', 'Left Arrow', 12, true);
		leftArrow.animation.play('idle');
		leftArrow.screenCenter();
		leftArrow.antialiasing = FlxG.save.data.antialiasing;
		add(leftArrow);

		var rightArrow = new FlxSprite(0, 0);
		rightArrow.frames = selectionFrames;
		rightArrow.animation.addByPrefix('idle', 'Right Arrow', 12, true);
		rightArrow.animation.play('idle');
		rightArrow.screenCenter();
		rightArrow.antialiasing = FlxG.save.data.antialiasing;
		add(rightArrow);

		scoreText = new FlxText(FlxG.width * 0.65, 5, 0, "", 32);
		// scoreText.autoSize = false;
		scoreText.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.WHITE, RIGHT);
		// scoreText.alignment = RIGHT;

		var scoreBG:FlxSprite = new FlxSprite(scoreText.x - 6, 0);
		if (FlxG.save.data.extraSongInfo)
			scoreBG.makeGraphic(Std.int(FlxG.width * 0.4), 250, 0xFF000000);
		else
			scoreBG.makeGraphic(Std.int(FlxG.width * 0.4), 135, 0xFF000000);
		scoreBG.alpha = 0.6;
		add(scoreBG);

		diffText = new FlxText(scoreText.x, scoreText.y + 66, 0, "", 24);
		diffText.font = scoreText.font;
		add(diffText);

		previewtext = new FlxText(scoreText.x, scoreText.y + 94, 0, CoolUtil.translate('rate') + " " + FlxMath.roundDecimal(rate, 2) + "x", 24);
		previewtext.font = scoreText.font;
		add(previewtext);

		extraInfoText = new FlxText(scoreText.x, scoreText.y + 124, 0, "", 24);
		extraInfoText.font = scoreText.font;
		if (FlxG.save.data.extraSongInfo)
			add(extraInfoText);

		comboText = new FlxText(diffText.x + 100, diffText.y, 0, "", 24);
		comboText.font = diffText.font;
		add(comboText);

		noteImages = [];
		var noteAssets = NoteskinHelpers.generateNoteskinSprite(FlxG.save.data.noteskin);
		var noteColors4K = ["purple","blue","green","red","red"];
		var noteColors5K = ["purple","blue","yellow","green","red"];

		for (i in 0...5)
		{
			var note:FlxSprite = new FlxSprite( scoreText.x + (i * 36), scoreText.y + 36 );
			note.frames = noteAssets;
			note.animation.addByPrefix('four_key', noteColors4K[i] + " arrow");
			if (i == 2)
				note.animation.addByPrefix('five_key', noteColors5K[i] + " center");
			else
				note.animation.addByPrefix('five_key', noteColors5K[i] + " arrow");
			note.antialiasing = FlxG.save.data.antialiasing;
			note.origin.set( 0, 0 );
			note.setGraphicSize(30);
			note.animation.play('four_key');
			add(note);
			noteImages.push(note);
		}
		noteImages[4].alpha = 0;

		add(scoreText);

		changeSelection();
		changeDiff();

		if (FlxG.sound.music != null)
		{
			if (!FlxG.sound.music.playing)
			{
				FlxG.sound.playMusic(Paths.music('freakyMenu'));
				Conductor.changeBPM(130);
			}
		}

		selector = new FlxText();

		selector.size = 40;
		selector.text = ">";
		// add(selector);

		var swag:Alphabet = new Alphabet(1, 0, "swag");

		super.create();
	}

	public static var cached:Bool = false;

	/**
	 * Load song data from the data files.
	 */
	static function populateSongData()
	{
		cached = false;
		list = ["dungeon:antimus-bf:0x98C3E2", "risking-life:antimus-bf:0x98C3E2", "vengeance:antimus-gf:0xB6A7C9", "revival:bf-gf:0xEDAFBC", "claw-marks:antimus-gf:0xB6A7C9"];
		var listFile = CoolUtil.coolTextFile(Paths.txt('data/freeplaySonglist'));
		if (listFile.length > 0)
		{
			for (i in 0...listFile.length)
			{
				if (listFile[i] != '')
					list.push(listFile[i]);
			}
		}

		songData = [];
		songs = [];

		for (i in 0...list.length)
		{
			var data:Array<String> = list[i].split(':');
			var songId = data[0];
			var meta = new FreeplaySongMetadata(songId, FlxColor.fromString(data[2]), data[1]);

			var metaFile = Paths.loadJSON('songs/$songId/_meta');
			var diffsThatExist = metaFile.difficulties;

			meta.diffs = diffsThatExist;

			var song = FreeplayState.loadSongData(songId, diffsThatExist[0]);
			var songLen:Float = song.length;

			if (songLen == 0)
			{
				var songInst:FlxSound = new FlxSound().loadEmbedded(Paths.inst(song.songId));
				songLen = songInst.length;
			}
			meta.songLength = songLen;

			for (d in diffsThatExist)
				FreeplayState.songData.set(songId + d, FreeplayState.loadSongData(songId, d));
			trace('loaded diffs for ' + songId);
			FreeplayState.songs.push(meta);
		}
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (FlxG.sound.music.volume < 0.7)
		{
			FlxG.sound.music.volume += 0.5 * FlxG.elapsed;
		}

		var songIndex:Int = 0;
		for (item in grpSongs.members)
		{
			var scaledY = FlxMath.remapToRange(item.targetY, 0, 1, 0, 1.3);

			item.y = FlxMath.lerp(item.y, (scaledY * 240) + (FlxG.height * 0.48), 0.30);

			grpSongBacks[songIndex].y = item.y - (grpSongBacks[songIndex].height - item.height) / 2;
			grpSongSelectors[songIndex].y = grpSongBacks[songIndex].y - 20;
			songIndex++;
		}

		lerpScore = Math.floor(FlxMath.lerp(lerpScore, intendedScore, 0.4));

		if (Math.abs(lerpScore - intendedScore) <= 10)
			lerpScore = intendedScore;

		scoreText.text = CoolUtil.translate('personalBest') + lerpScore;
		comboText.text = combo + '\n';
		if (curSelected <= 4 && FlxG.save.data.antimusProgress[curSelected] <= 0)
		{
			scoreText.text = "";
			comboText.text = "";
		}

		/*if (FlxG.sound.music.volume > 0.8)
		{
			FlxG.sound.music.volume -= 0.5 * FlxG.elapsed;
		}*/

		var upP = FlxG.keys.justPressed.UP;
		var downP = FlxG.keys.justPressed.DOWN;
		var accepted = FlxG.keys.justPressed.ENTER;

		var gamepad:FlxGamepad = FlxG.gamepads.lastActive;

		if (gamepad != null)
		{
			if (gamepad.justPressed.DPAD_UP)
			{
				changeSelection(-1);
			}
			if (gamepad.justPressed.DPAD_DOWN)
			{
				changeSelection(1);
			}
			if (gamepad.justPressed.DPAD_LEFT)
			{
				changeDiff(-1);
			}
			if (gamepad.justPressed.DPAD_RIGHT)
			{
				changeDiff(1);
			}
		}

		if (upP)
		{
			changeSelection(-1);
		}
		if (downP)
		{
			changeSelection(1);
		}

		if (FlxG.keys.pressed.SHIFT)
		{
			if (FlxG.keys.justPressed.LEFT)
				rate -= 0.05;
			if (FlxG.keys.justPressed.RIGHT)
				rate += 0.05;

			if (FlxG.keys.justPressed.R)
				rate = 1;

			if (rate > 3)
				rate = 3;
			else if (rate < 0.5)
				rate = 0.5;

			previewtext.text = CoolUtil.translate('rate') + " " + FlxMath.roundDecimal(rate, 2) + "x";
		}
		else
		{
			if (FlxG.keys.justPressed.LEFT)
				changeDiff(-1);
			if (FlxG.keys.justPressed.RIGHT)
				changeDiff(1);
		}
		if (curSelected <= 4 && FlxG.save.data.antimusProgress[curSelected] <= 0)
		{
			if (curSelected == 4)
				diffText.text = CoolUtil.translate('beatStoryMode');
			else
				diffText.text = CoolUtil.translate('beatInStoryMode');
			previewtext.text = '';
		}

		if (controls.BACK)
		{
			FlxG.switchState(new MainMenuState());
		}

		if (accepted && (curSelected > 4 || FlxG.save.data.antimusProgress[curSelected] > 0))
			loadSong();
	}

	function loadAnimDebug(dad:Bool = true)
	{
		// First, get the song data.
		var hmm;
		try
		{
			hmm = songData.get(songs[curSelected].songName + curDifficulty);
			if (hmm == null)
				return;
		}
		catch (ex)
		{
			return;
		}
		PlayState.SONG = hmm;

		var character = dad ? PlayState.SONG.player2 : PlayState.SONG.player1;

		LoadingState.loadAndSwitchState(new AnimationDebug(character));
	}

	function loadSong(isCharting:Bool = false)
	{
		loadSongInFreePlay(songs[curSelected].songName, curDifficulty, isCharting);

		clean();
	}

	/**
 * Load into a song in free play, by name.
 * This is a static function, so you can call it anywhere.
 * @param songName The name of the song to load. Use the human readable name, with spaces.
 * @param isCharting If true, load into the Chart Editor instead.
 */
	public static function loadSongInFreePlay(songName:String, difficulty:String, isCharting:Bool, reloadSong:Bool = false)
	{
		// Make sure song data is initialized first.
		if (songData == null || Lambda.count(songData) == 0)
			populateSongData();

		var currentSongData;
		try
		{
			currentSongData = songData.get(songName + difficulty);
			if (songData.get(songName + difficulty) == null)
				return;
		}
		catch (ex)
		{
			return;
		}

		PlayState.SONG = currentSongData;
		PlayState.isStoryMode = false;
		PlayState.storyDifficulty = difficulty;
		PlayState.storyWeek = 0;
		Debug.logInfo('Loading song ${PlayState.SONG.songId} into Free Play...');
		#if FEATURE_STEPMANIA
		if (songs[curSelected].songBackImage == "sm")
		{
			Debug.logInfo('Song is a StepMania song!');
			PlayState.isSM = true;
			PlayState.sm = songs[curSelected].sm;
			PlayState.pathToSm = songs[curSelected].path;
		}
		else
			PlayState.isSM = false;
		#else
		PlayState.isSM = false;
		#end

		PlayState.songMultiplier = rate;

		if (isCharting)
			LoadingState.loadAndSwitchState(new ChartingState(reloadSong));
		else
			LoadingState.loadAndSwitchState(new PlayState());
	}

	function changeDiff(change:Int = 0)
	{
		var diffInt = songs[curSelected].diffs.indexOf(curDifficulty);
		var diffIntPrev = diffInt;
		diffInt += change;
		if (diffInt < 0)
			diffInt = songs[curSelected].diffs.length - 1;
		if (diffInt >= songs[curSelected].diffs.length)
			diffInt = 0;

		if (diffInt == diffIntPrev && change != 0)
			return;

		curDifficulty = songs[curSelected].diffs[diffInt];

		resetExtraInfo();

		// adjusting the highscore song name to be compatible (changeDiff)
		var songHighscore = StringTools.replace(songs[curSelected].songName, " ", "-");

		#if !switch
		intendedScore = Highscore.getScore(songHighscore, curDifficulty);
		combo = Highscore.getCombo(songHighscore, curDifficulty);
		#end
		diffText.text = CoolUtil.translate(curDifficulty).toUpperCase();
	}

	function changeSelection(change:Int = 0)
	{
		FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);

		curSelected += change;

		if (curSelected < 0)
			curSelected = songs.length - 1;
		if (curSelected >= songs.length)
			curSelected = 0;

		if (!songs[curSelected].diffs.contains(curDifficulty))
			curDifficulty = songs[curSelected].diffs[0];

		if (songData.get(songs[curSelected].songName + curDifficulty).fiveKey)
		{
			for (i in noteImages)
				i.animation.play('five_key');
			noteImages[4].alpha = 1;
		}
		else
		{
			for (i in noteImages)
				i.animation.play('four_key');
			noteImages[4].alpha = 0;
		}

		// selector.y = (70 * curSelected) + 30;

		// adjusting the highscore song name to be compatible (changeSelection)
		// would read original scores if we didn't change packages
		var songHighscore = StringTools.replace(songs[curSelected].songName, " ", "-");

		#if !switch
		intendedScore = Highscore.getScore(songHighscore, curDifficulty);
		combo = Highscore.getCombo(songHighscore, curDifficulty);
		// lerpScore = 0;
		#end

		previewtext.text = CoolUtil.translate('rate') + " " + rate + "x";
		diffText.text = CoolUtil.translate(curDifficulty).toUpperCase();

		resetExtraInfo();

		var hmm;
		try
		{
			hmm = songData.get(songs[curSelected].songName + curDifficulty);
			if (hmm != null)
			{
				Conductor.changeBPM(hmm.bpm);
				GameplayCustomizeState.freeplayBf = hmm.player1;
				GameplayCustomizeState.freeplayDad = hmm.player2;
				GameplayCustomizeState.freeplayGf = hmm.gfVersion;
				GameplayCustomizeState.freeplayNoteStyle = hmm.noteStyle;
				GameplayCustomizeState.freeplayStage = hmm.stage;
				GameplayCustomizeState.freeplaySong = hmm.songId;
				GameplayCustomizeState.freeplayWeek = 0;
			}
		}
		catch (ex)
		{
		}

		var bullShit:Int = 0;

		for (item in grpSongs.members)
		{
			item.targetY = bullShit - curSelected;
			bullShit++;

			item.alpha = 0.6;
			// item.setGraphicSize(Std.int(item.width * 0.8));

			if (item.targetY == 0)
			{
				item.alpha = 1;
				// item.setGraphicSize(Std.int(item.width));
			}
		}

		var songColor = songs[curSelected].color;
		if ( curSelected <= 4 && FlxG.save.data.antimusProgress[curSelected] <= 0 )
			songColor = FlxColor.GRAY;
		FlxTween.color(grpSongBacks[curSelected], 0.4, grpSongBacks[curSelected].color, songColor, {ease: FlxEase.quadOut});

		if (curSelected > 0)
		{
			songColor = songs[curSelected-1].color;
			if ( curSelected-1 <= 4 && FlxG.save.data.antimusProgress[curSelected-1] <= 0 )
				songColor = FlxColor.GRAY;
			if (songColor.saturation == 0)
				songColor = FlxColor.fromHSB(songColor.hue, songColor.saturation, songColor.brightness * 2 / 3);
			else
				songColor = FlxColor.fromHSB(songColor.hue, songColor.saturation / 2, songColor.brightness);
			FlxTween.color(grpSongBacks[curSelected-1], 0.4, grpSongBacks[curSelected-1].color, songColor, {ease: FlxEase.quadOut});
		}

		if (curSelected < songs.length - 1)
		{
			songColor = songs[curSelected+1].color;
			if ( curSelected+1 <= 4 && FlxG.save.data.antimusProgress[curSelected+1] <= 0 )
				songColor = FlxColor.GRAY;
			if (songColor.saturation == 0)
				songColor = FlxColor.fromHSB(songColor.hue, songColor.saturation, songColor.brightness * 2 / 3);
			else
				songColor = FlxColor.fromHSB(songColor.hue, songColor.saturation / 2, songColor.brightness);
			FlxTween.color(grpSongBacks[curSelected+1], 0.4, grpSongBacks[curSelected+1].color, songColor, {ease: FlxEase.quadOut});
		}
	}

	function resetExtraInfo()
	{
		var newExtraInfo = CoolUtil.translate('songLength') + " ";
		newExtraInfo += FlxStringUtil.formatTime(songs[curSelected].songLength / 1000.0);
		var songToGet = songData.get(songs[curSelected].songName + curDifficulty);
		var notesToGet = songToGet.notes;
		newExtraInfo += '\n' + CoolUtil.translate('songBpm') + " ";
		newExtraInfo += songToGet.bpm;

		var songStuffs = [0,0,0];		// Taps, Holds, Jumps
		var allNotes = [];
		var noteCount = ( songToGet.fiveKey ? 5 : 4 );
		for (i in notesToGet)
		{
			for (j in i.sectionNotes)
			{
				if ((i.mustHitSection && j[1] < noteCount) || (!i.mustHitSection && j[1] >= noteCount))
				{
					if (j[2] > 0)
						songStuffs[1] += 1;
					else
						allNotes.push(j[0]);
				}
			}
		}

		var totalJumps:Float = 0;
		for (i in allNotes)
		{
			var sameNotes = allNotes.filter(function(a) return a == i);
			if (sameNotes.length > 1)
				totalJumps += 1.0 / sameNotes.length;					// This is technically misleading since jumps, hands, quads, etc. are all counted as the same thing but whatever
			else
				songStuffs[0] += 1;
		}
		songStuffs[2] = Std.int( Math.round( totalJumps ) );

		newExtraInfo += '\n' + CoolUtil.translate('songTaps') + " ";
		newExtraInfo += songStuffs[0];
		newExtraInfo += '\n' + CoolUtil.translate('songJumps') + " ";
		newExtraInfo += songStuffs[2];
		newExtraInfo += '\n' + CoolUtil.translate('songHolds') + " ";
		newExtraInfo += songStuffs[1];
		newExtraInfo += '\n';

		if (curSelected <= 4 && FlxG.save.data.antimusProgress[curSelected] <= 0)
			extraInfoText.text = '';
		else
			extraInfoText.text = newExtraInfo;
	}
} class FreeplaySongMetadata
{
	public var songName:String = "";
	public var color:FlxColor = FlxColor.BLACK;
	#if FEATURE_STEPMANIA
	public var sm:SMFile;
	public var path:String;
	#end
	public var songBackImage:String = "";
	public var songLength:Float;

	public var diffs = [];

	#if FEATURE_STEPMANIA
	public function new(song:String, color:FlxColor, songBackImage:String, ?sm:SMFile = null, ?path:String = "")
	{
		this.songName = song;
		this.color = color;
		this.songBackImage = songBackImage;
		this.sm = sm;
		this.path = path;
	}
	#else
	public function new(song:String, color:FlxColor, songBackImage:String)
	{
		this.songName = song;
		this.color = color;
		this.songBackImage = songBackImage;
	}
	#end
}
