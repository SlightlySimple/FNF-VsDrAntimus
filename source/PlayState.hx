package;

import flixel.util.FlxSpriteUtil;
#if FEATURE_LUAMODCHART
import LuaClass.LuaCamera;
import LuaClass.LuaCharacter;
import LuaClass.LuaNote;
#end
import lime.media.openal.AL;
import Song.Event;
import openfl.media.Sound;
#if FEATURE_STEPMANIA
import smTools.SMFile;
#end
#if FEATURE_FILESYSTEM
import sys.io.File;
import Sys;
import sys.FileSystem;
#end
import openfl.ui.KeyLocation;
import openfl.events.Event;
import haxe.EnumTools;
import openfl.ui.Keyboard;
import openfl.events.KeyboardEvent;
import Replay.Ana;
import Replay.Analysis;
import flixel.input.keyboard.FlxKey;
import haxe.Exception;
import openfl.geom.Matrix;
import openfl.display.BitmapData;
import openfl.utils.AssetType;
import lime.graphics.Image;
import flixel.graphics.FlxGraphic;
import openfl.utils.AssetManifest;
import openfl.utils.AssetLibrary;
import lime.app.Application;
import lime.media.AudioContext;
import lime.media.AudioManager;
import openfl.Lib;
import Section.SwagSection;
import Song.SongData;
import WiggleEffect.WiggleEffectType;
import flixel.FlxBasic;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxGame;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.FlxSubState;
import flixel.addons.display.FlxGridOverlay;
import flixel.addons.effects.FlxTrail;
import flixel.addons.effects.FlxTrailArea;
import flixel.addons.effects.chainable.FlxEffectSprite;
import flixel.addons.effects.chainable.FlxWaveEffect;
import flixel.addons.transition.FlxTransitionableState;
import flixel.graphics.atlas.FlxAtlas;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import flixel.system.FlxSound;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.ui.FlxBar;
import flixel.util.FlxCollision;
import flixel.util.FlxColor;
import flixel.util.FlxSort;
import flixel.util.FlxStringUtil;
import flixel.util.FlxTimer;
import haxe.Json;
import openfl.display.BlendMode;
import openfl.display.StageQuality;
import openfl.filters.ShaderFilter;
#if FEATURE_DISCORD
import Discord.DiscordClient;
#end

using StringTools;

class PlayState extends MusicBeatState
{
	public static var instance:PlayState = null;

	public static var SONG:SongData;
	public static var isStoryMode:Bool = false;
	public static var storyWeek:Int = 0;
	public static var storyPlaylist:Array<String> = [];
	public static var storyDifficulty:String = "Normal";
	public static var weekSong:Int = 0;
	public static var weekScore:Int = 0;
	public static var shits:Int = 0;
	public static var bads:Int = 0;
	public static var goods:Int = 0;
	public static var sicks:Int = 0;
	public static var healthGraphInfo:Array<Array<Float>> = [];

	public static var songPosBG:FlxSprite;

	public var visibleCombos:Array<FlxSprite> = [];

	public var addedBotplay:Bool = false;

	public var visibleNotes:Array<Note> = [];

	public static var songPosBar:FlxBar;

	public static var noteskinSprite:FlxAtlasFrames;

	public static var rep:Replay;
	public static var loadRep:Bool = false;
	public static var inResults:Bool = false;

	public static var inDaPlay:Bool = false;

	public static var noteBools:Array<Bool> = [false, false, false, false];

	var songLength:Float = 0;
	var kadeEngineWatermark:FlxText;

	#if FEATURE_DISCORD
	// Discord RPC variables
	var storyDifficultyText:String = "";
	var iconRPC:String = "";
	var detailsText:String = "";
	var detailsPausedText:String = "";
	#end

	public var vocals:FlxSound;

	public static var isSM:Bool = false;
	#if FEATURE_STEPMANIA
	public static var sm:SMFile;
	public static var pathToSm:String;
	#end

	public static var dad:Character;
	public static var gf:Character;
	public static var boyfriend:Boyfriend;
	public static var boyfriendEyeTrail:FlxTrail;

	public var notes:FlxTypedGroup<Note>;

	private var unspawnNotes:Array<Note> = [];

	public var strumLine:FlxSprite;

	private var curSection:Int = 0;

	private var camFollow:FlxObject;

	private static var prevCamFollow:FlxObject;

	public var laneunderlay:FlxSprite;
	public var laneunderlayOpponent:FlxSprite;

	public static var strumLineNotes:FlxTypedGroup<StaticArrow> = null;
	public static var playerStrums:FlxTypedGroup<StaticArrow> = null;
	public static var cpuStrums:FlxTypedGroup<StaticArrow> = null;

	private var camZooming:Bool = false;
	private var curSong:String = "";

	private var gfSpeed:Int = 1;

	public var health:Float = 1; // making public because sethealth doesnt work without it

	private var combo:Int = 0;

	public static var misses:Int = 0;
	public static var campaignMisses:Int = 0;
	public static var campaignSicks:Int = 0;
	public static var campaignGoods:Int = 0;
	public static var campaignBads:Int = 0;
	public static var campaignShits:Int = 0;

	public var accuracy:Float = 0.00;

	private var accuracyDefault:Float = 0.00;
	private var totalNotesHit:Float = 0;
	private var totalNotesHitDefault:Float = 0;
	private var totalPlayed:Int = 0;
	private var ss:Bool = false;

	private var healthBarBG:FlxSprite;
	private var healthBar:FlxBar;
	private var songPositionBar:Float = 0;

	private var generatedMusic:Bool = false;
	private var startingSong:Bool = false;

	public var iconP1:HealthIcon; // making these public again because i may be stupid
	public var iconP2:HealthIcon; // what could go wrong?
	public var camRatings:FlxCamera;
	public var camHUD:FlxCamera;
	public var camCutsceneHUD:FlxCamera;
	public var camSustains:FlxCamera;
	public var camNotes:FlxCamera;

	private var camGame:FlxCamera;

	public var cannotDie = false;
	public var healthLimiter:Bool = false;
	public var forcedCamPosition:Bool = false;

	public static var offsetTesting:Bool = false;

	public var isSMFile:Bool = false;

	var notesHitArray:Array<Date> = [];
	var currentFrames:Int = 0;
	var idleToBeat:Bool = true; // change if bf and dad would idle to the beat of the song
	var idleBeat:Int = 2; // how frequently bf and dad would play their idle animation(1 - every beat, 2 - every 2 beats and so on)
	var forcedToIdle:Bool = false; // change if bf and dad are forced to idle to every (idleBeat) beats of the song
	var allowedToHeadbang:Bool = true; // Will decide if gf is allowed to headbang depending on the song
	var allowedToCheer:Bool = false; // Will decide if gf is allowed to cheer depending on the song

	public var dialogue:Array<String> = ['dad:blah blah blah', 'bf:coolswag'];

	var songName:FlxText;

	var altSuffix:String = "";

	public var currentSection:SwagSection;

	var fc:Bool = true;

	var wiggleShit:WiggleEffect = new WiggleEffect();

	var talking:Bool = true;

	public static var currentSong = "noneYet";

	public var songScore:Int = 0;

	var songScoreDef:Int = 0;
	var scoreTxt:FlxText;
	var judgementCounter:FlxText;
	var replayTxt:FlxText;

	var needSkip:Bool = false;
	var skipActive:Bool = false;
	var skipText:FlxText;
	var skipTo:Float;

	public static var campaignScore:Int = 0;
	public static var hasSkipped:Bool = false;

	public static var theFunne:Bool = true;

	var funneEffect:FlxSprite;
	var inCutscene:Bool = false;
	var usedTimeTravel:Bool = false;

	public static var stageTesting:Bool = false;

	var camPos:FlxPoint;

	public var randomVar = false;

	public static var Stage:Stage;

	public static var repPresses:Int = 0;
	public static var repReleases:Int = 0;

	public static var timeCurrently:Float = 0;
	public static var timeCurrentlyR:Float = 0;

	// Will fire once to prevent debug spam messages and broken animations
	private var triggeredAlready:Bool = false;

	// Per song additive offset
	public static var songOffset:Float = 0;

	// BotPlay text
	private var botPlayState:FlxText;
	// Replay shit
	private var saveNotes:Array<Dynamic> = [];
	private var saveJudge:Array<String> = [];
	private var replayAna:Analysis = new Analysis(); // replay analysis

	public static var highestCombo:Int = 0;

	public var executeModchart = false;

	public var myScripts:Map<String, HscriptHandler>;

	// Animation common suffixes
	private var dataSuffix:Array<String> = ['LEFT', 'DOWN', 'UP', 'RIGHT'];
	private var dataColor:Array<String> = ['purple', 'blue', 'green', 'red'];
	private var dataSuffixFiveK:Array<String> = ['LEFT', 'DOWN', 'CENTER', 'UP', 'RIGHT'];
	private var dataColorFiveK:Array<String> = ['purple', 'blue', 'yellow', 'green', 'red'];

	public static var startTime = 0.0;

	// API stuff

	public function addObject(object:FlxBasic)
	{
		add(object);
	}

	public function removeObject(object:FlxBasic)
	{
		remove(object);
	}

	override public function create()
	{
		FlxG.mouse.visible = false;
		instance = this;

		// grab variables here too or else its gonna break stuff later on
		GameplayCustomizeState.freeplayBf = SONG.player1;
		GameplayCustomizeState.freeplayDad = SONG.player2;
		GameplayCustomizeState.freeplayGf = SONG.gfVersion;
		GameplayCustomizeState.freeplayNoteStyle = SONG.noteStyle;
		GameplayCustomizeState.freeplayStage = SONG.stage;
		GameplayCustomizeState.freeplaySong = SONG.songId;
		GameplayCustomizeState.freeplayWeek = storyWeek;

		previousRate = songMultiplier - 0.05;

		if (previousRate < 1.00)
			previousRate = 1;

		if (FlxG.save.data.fpsCap > 290)
			(cast(Lib.current.getChildAt(0), Main)).setFPSCap(800);

		if (FlxG.sound.music != null)
			FlxG.sound.music.stop();

		inDaPlay = true;

		if (currentSong != CoolUtil.translate(SONG.songId))
		{
			currentSong = CoolUtil.translate(SONG.songId);
			Main.dumpCache();
		}

		bads = 0;
		shits = 0;
		goods = 0;
		sicks = 0;

		misses = 0;

		highestCombo = 0;
		repPresses = 0;
		repReleases = 0;
		inResults = false;

		PlayStateChangeables.useDownscroll = FlxG.save.data.downscroll;
		PlayStateChangeables.safeFrames = FlxG.save.data.frames;
		PlayStateChangeables.scrollSpeed = FlxG.save.data.scrollSpeed * songMultiplier;
		PlayStateChangeables.botPlay = FlxG.save.data.botplay;
		PlayStateChangeables.zoom = FlxG.save.data.zoom;
		PlayStateChangeables.middleScroll = FlxG.save.data.middleScroll;

		if (!isBotplayAllowed())
			PlayStateChangeables.botPlay = false;

		if (storyDifficulty == "Solo")
			PlayStateChangeables.middleScroll = true;

		#if FEATURE_LUAMODCHART
		// TODO: Refactor this to use OpenFlAssets.
		executeModchart = FileSystem.exists(Paths.lua('songs/${PlayState.SONG.songId}/modchart'));
		if (isSM)
			executeModchart = FileSystem.exists(pathToSm + "/modchart.lua");
		#end
		#if !cpp
		executeModchart = false; // FORCE disable for non cpp targets
		#end

		Debug.logInfo('Searching for mod chart? ($executeModchart) at ${Paths.lua('songs/${PlayState.SONG.songId}/modchart')}');

		if (executeModchart)
			songMultiplier = 1;

		#if FEATURE_DISCORD
		// Making difficulty text for Discord Rich Presence.
		storyDifficultyText = storyDifficulty;

		iconRPC = SONG.player2;

		// String that contains the mode defined here so it isn't necessary to call changePresence for each mode
		if (isStoryMode)
		{
			detailsText = "Story Mode: Antimus";
		}
		else
		{
			detailsText = "Freeplay";
		}

		// String for when the game is paused
		detailsPausedText = "Paused - " + detailsText;

		// Updating Discord Rich Presence.
		DiscordClient.changePresence(detailsText
			+ " "
			+ CoolUtil.translate(SONG.songId)
			+ " ("
			+ storyDifficultyText
			+ ") "
			+ Ratings.GenerateLetterRank(accuracy),
			"\nAcc: "
			+ HelperFunctions.truncateFloat(accuracy, 2)
			+ "% | Score: "
			+ songScore
			+ " | Misses: "
			+ misses, iconRPC);
		#end

		// var gameCam:FlxCamera = FlxG.camera;
		camGame = new FlxCamera();
		camRatings = new FlxCamera();
		camRatings.bgColor.alpha = 0;
		camHUD = new FlxCamera();
		camHUD.bgColor.alpha = 0;
		camCutsceneHUD = new FlxCamera();
		camCutsceneHUD.bgColor.alpha = 0;
		camSustains = new FlxCamera();
		camSustains.bgColor.alpha = 0;
		camNotes = new FlxCamera();
		camNotes.bgColor.alpha = 0;

		FlxG.cameras.reset(camGame);
		FlxG.cameras.add(camRatings);
		FlxG.cameras.add(camHUD);
		FlxG.cameras.add(camCutsceneHUD);
		FlxG.cameras.add(camSustains);
		FlxG.cameras.add(camNotes);

		camHUD.zoom = PlayStateChangeables.zoom;

		FlxCamera.defaultCameras = [camGame];

		persistentUpdate = true;
		persistentDraw = true;

		if (SONG == null)
			SONG = Song.loadFromJson('dungeon', 'Hard');

		Conductor.mapBPMChanges(SONG);
		Conductor.changeBPM(SONG.bpm);

		Conductor.bpm = SONG.bpm;

		if (SONG.eventObjects == null)
		{
			SONG.eventObjects = [new Song.Event("Init BPM", 0, SONG.bpm, "BPM Change")];
		}

		TimingStruct.clearTimings();

		FlxG.sound.cache(Paths.sound('missnote1'));
		FlxG.sound.cache(Paths.sound('missnote2'));
		FlxG.sound.cache(Paths.sound('missnote3'));

		myScripts = [];
		if (Paths.doesTextAssetExist(Paths.hs('songs/' + SONG.songId + '/script')))
		{
			var newScript = new HscriptHandler('songs/' + SONG.songId + '/script');
			newScript.execFunc('create', []);
			myScripts.set('SONG', newScript);
		}

		healthLimiter = false;

		var currentIndex = 0;
		for (i in SONG.eventObjects)
		{
			switch (i.type)
			{
				case "BPM Change":
					var beat:Float = i.position;

					var endBeat:Float = Math.POSITIVE_INFINITY;

					var bpm = i.value * songMultiplier;

					TimingStruct.addTiming(beat, bpm, endBeat, 0); // offset in this case = start time since we don't have a offset

					if (currentIndex != 0)
					{
						var data = TimingStruct.AllTimings[currentIndex - 1];
						data.endBeat = beat;
						data.length = ((data.endBeat - data.startBeat) / (data.bpm / 60)) / songMultiplier;
						var step = ((60 / data.bpm) * 1000) / 4;
						TimingStruct.AllTimings[currentIndex].startStep = Math.floor((((data.endBeat / (data.bpm / 60)) * 1000) / step) / songMultiplier);
						TimingStruct.AllTimings[currentIndex].startTime = data.startTime + data.length / songMultiplier;
					}

					currentIndex++;

				default:
					if (!myScripts.exists(i.type) && Paths.doesTextAssetExist(Paths.hs('events/' + i.type)))
					{
						var newScript = new HscriptHandler('events/' + i.type);
						newScript.execFunc('create', []);
						myScripts.set(i.type, newScript);
					}
			}
		}

		recalculateAllSectionTimes();

		trace('INFORMATION ABOUT WHAT U PLAYIN WIT:\nFRAMES: ' + PlayStateChangeables.safeFrames + '\nZONE: ' + Conductor.safeZoneOffset + '\nTS: '
			+ Conductor.timeScale + '\nBotPlay : ' + PlayStateChangeables.botPlay);

		// if the song has dialogue, so we don't accidentally try to load a nonexistant file and crash the game
		if (Paths.doesTextAssetExist(Paths.txt('data/songs/${PlayState.SONG.songId}/dialogue')))
		{
			dialogue = CoolUtil.coolTextFile(Paths.txt('data/songs/${PlayState.SONG.songId}/dialogue'));
		}

		// defaults if no stage was found in chart
		var stageCheck:String = 'lab';

		if (SONG.stage != null)
			stageCheck = SONG.stage;

		if (isStoryMode)
			songMultiplier = 1;

		// defaults if no gf was found in chart
		var gfCheck:String = 'gf';

		if (SONG.gfVersion != null)
			gfCheck = SONG.gfVersion;

		if (!stageTesting)
		{
			gf = new Character(0, 0, gfCheck);

			if (gf.frames == null)
			{
				#if debug
				FlxG.log.warn(["Couldn't load gf: " + gfCheck + ". Loading default gf"]);
				#end
				gf = new Character(0, 0, 'gf');
			}
			if (gf.myScript != null)
				myScripts.set("gf", gf.myScript);

			boyfriend = new Boyfriend(0, 0, SONG.player1);

			if (boyfriend.frames == null)
			{
				#if debug
				FlxG.log.warn(["Couldn't load boyfriend: " + SONG.player1 + ". Loading default boyfriend"]);
				#end
				boyfriend = new Boyfriend(0, 0, 'bf');
			}
			if (boyfriend.myScript != null)
				myScripts.set("boyfriend", boyfriend.myScript);

			dad = new Character(0, 0, SONG.player2);

			if (dad.frames == null)
			{
				#if debug
				FlxG.log.warn(["Couldn't load opponent: " + SONG.player2 + ". Loading default opponent"]);
				#end
				dad = new Character(0, 0, 'antimus');
			}
			if (dad.myScript != null)
				myScripts.set("dad", dad.myScript);
		}

		if (!stageTesting)
		{
			Stage = new Stage(SONG.stage);
			if (Stage.myScript != null)
				myScripts.set("Stage", Stage.myScript);
		}

		for (i in Stage.toAdd)
		{
			add(i);
		}

		for (index => array in Stage.layInFront)
		{
			switch (index)
			{
				case 0:
					add(gf);
					gf.scrollFactor.set(0.95, 0.95);
					gf.visible = !Stage.stageJson.hideGirlfriend;
					for (bg in array)
						add(bg);
				case 1:
					add(dad);
					dad.visible = !(SONG.player2 == gfCheck);
					for (bg in array)
						add(bg);
				case 2:
					add(boyfriend);
					if (boyfriend.eyeglow != null)
					{
						add(boyfriend.eyeglow);
						boyfriendEyeTrail = new FlxTrail(boyfriend.eyeglow, null, 25, 2, 0.7, 0.05);
						add( boyfriendEyeTrail );
					}
					for (bg in array)
						add(bg);
			}
		}

		boyfriend.x -= boyfriend.characterPosition[0];
		boyfriend.y += boyfriend.characterPosition[1];
		gf.x += gf.characterPosition[0];
		gf.y += gf.characterPosition[1];
		dad.x += dad.characterPosition[0];
		dad.y += dad.characterPosition[1];

		if (Stage.stageJson != null)
		{
			if (Stage.stageJson.bfPos != null)
			{
				boyfriend.x += Stage.stageJson.bfPos[0];
				boyfriend.y += Stage.stageJson.bfPos[1];
			}
			if (Stage.stageJson.gfPos != null)
			{
				gf.x += Stage.stageJson.gfPos[0];
				gf.y += Stage.stageJson.gfPos[1];
			}
			if (Stage.stageJson.dadPos != null)
			{
				dad.x += Stage.stageJson.dadPos[0];
				dad.y += Stage.stageJson.dadPos[1];
			}
		}

		camPos = new FlxPoint(Stage.stageJson.camPos[0], Stage.stageJson.camPos[1]);

		Stage.update(0);

		hscriptRefresh();

		if (loadRep)
		{
			FlxG.watch.addQuick('rep rpesses', repPresses);
			FlxG.watch.addQuick('rep releases', repReleases);
			// FlxG.watch.addQuick('Queued',inputsQueued);

			PlayStateChangeables.useDownscroll = rep.replay.isDownscroll;
			PlayStateChangeables.safeFrames = rep.replay.sf;
			PlayStateChangeables.botPlay = true;
		}

		trace('uh ' + PlayStateChangeables.safeFrames);

		trace("SF CALC: " + Math.floor((PlayStateChangeables.safeFrames / 60) * 1000));

		if (!isStoryMode && songMultiplier == 1)
		{
			var firstNoteTime = Math.POSITIVE_INFINITY;
			var playerTurn = false;
			for (index => section in SONG.notes)
			{
				if (section.sectionNotes.length > 0 && !isSM)
				{
					if (section.startTime > 5000)
					{
						needSkip = true;
						skipTo = section.startTime - 1000;
					}
					break;
				}
				else if (isSM)
				{
					for (note in section.sectionNotes)
					{
						if (note[0] < firstNoteTime)
						{
							firstNoteTime = note[0];
							if (note[1] > 3)
								playerTurn = true;
							else
								playerTurn = false;
						}
					}
					if (index + 1 == SONG.notes.length)
					{
						var timing = (!playerTurn ? firstNoteTime : TimingStruct.getTimeFromBeat(TimingStruct.getBeatFromTime(firstNoteTime)
							- 4));
						if (timing > 5000)
						{
							needSkip = true;
							skipTo = timing - 1000;
						}
					}
				}
			}
		}

		Conductor.songPosition = -5000;
		Conductor.rawPosition = Conductor.songPosition;

		strumLine = new FlxSprite(0, 50).makeGraphic(FlxG.width, 10);
		strumLine.scrollFactor.set();

		if (PlayStateChangeables.useDownscroll)
			strumLine.y = FlxG.height - 165;

		var laneBorder = FlxG.save.data.laneBorder;

		laneunderlayOpponent = new FlxSprite(0, 0).makeGraphic(110 * 4 + (laneBorder * 2), FlxG.height * 2);
		laneunderlayOpponent.alpha = FlxG.save.data.laneTransparency;
		laneunderlayOpponent.color = FlxColor.BLACK;
		laneunderlayOpponent.scrollFactor.set();

		laneunderlay = new FlxSprite(0, 0).makeGraphic(110 * 4 + (laneBorder * 2), FlxG.height * 2);
		laneunderlay.alpha = FlxG.save.data.laneTransparency;
		laneunderlay.color = FlxColor.BLACK;
		laneunderlay.scrollFactor.set();

		if (FlxG.save.data.laneUnderlay)
		{
			if (!PlayStateChangeables.middleScroll || executeModchart)
			{
				add(laneunderlayOpponent);
			}
			add(laneunderlay);
		}

		strumLineNotes = new FlxTypedGroup<StaticArrow>();
		add(strumLineNotes);

		playerStrums = new FlxTypedGroup<StaticArrow>();
		cpuStrums = new FlxTypedGroup<StaticArrow>();

		noteskinSprite = NoteskinHelpers.generateNoteskinSprite(FlxG.save.data.noteskin, SONG.noteStyle);

		generateStaticArrows(0);
		generateStaticArrows(1);

		// Update lane underlay positions AFTER static arrows :)

		laneunderlay.x = playerStrums.members[0].x - laneBorder;
		laneunderlayOpponent.x = cpuStrums.members[0].x - laneBorder;

		laneunderlay.screenCenter(Y);
		laneunderlayOpponent.screenCenter(Y);

		// startCountdown();

		if (SONG.songId == null)
			trace('song is null???');
		else
			trace('song looks gucci');

		generateSong(SONG.songId);

		#if FEATURE_LUAMODCHART
		if (executeModchart)
		{
			luaModchart = ModchartState.createModchartState(isStoryMode);
			luaModchart.executeState('start', [PlayState.SONG.songId]);
		}
		#end

		#if FEATURE_LUAMODCHART
		if (executeModchart)
		{
			new LuaCamera(camGame, "camGame").Register(ModchartState.lua);
			new LuaCamera(camHUD, "camHUD").Register(ModchartState.lua);
			new LuaCamera(camSustains, "camSustains").Register(ModchartState.lua);
			new LuaCamera(camSustains, "camNotes").Register(ModchartState.lua);
			new LuaCharacter(dad, "dad").Register(ModchartState.lua);
			new LuaCharacter(gf, "gf").Register(ModchartState.lua);
			new LuaCharacter(boyfriend, "boyfriend").Register(ModchartState.lua);
		}
		#end

		var index = 0;

		if (startTime != 0)
		{
			var toBeRemoved = [];
			for (i in 0...unspawnNotes.length)
			{
				var dunceNote:Note = unspawnNotes[i];

				if (dunceNote.strumTime <= startTime)
					toBeRemoved.push(dunceNote);
			}

			for (i in toBeRemoved)
				unspawnNotes.remove(i);

			Debug.logTrace("Removed " + toBeRemoved.length + " cuz of start time");
		}

		trace('generated');

		// add(strumLine);

		camFollow = new FlxObject(0, 0, 1, 1);

		camFollow.setPosition(camPos.x, camPos.y);

		if (prevCamFollow != null)
		{
			camFollow = prevCamFollow;
			prevCamFollow = null;
		}

		add(camFollow);

		FlxG.camera.follow(camFollow, LOCKON, 0.04 * (30 / (cast(Lib.current.getChildAt(0), Main)).getFPS()));
		// FlxG.camera.setScrollBounds(0, FlxG.width, 0, FlxG.height);
		FlxG.camera.zoom = Stage.camZoom;
		FlxG.camera.focusOn(camFollow.getPosition());

		FlxG.worldBounds.set(0, 0, FlxG.width, FlxG.height);

		FlxG.fixedTimestep = false;

		healthBarBG = new FlxSprite(0, FlxG.height * 0.9).loadGraphic(Paths.loadImage('healthBar'));
		if (PlayStateChangeables.useDownscroll)
			healthBarBG.y = 50;
		healthBarBG.screenCenter(X);
		healthBarBG.scrollFactor.set();

		healthBar = new FlxBar(healthBarBG.x + 4, healthBarBG.y + 4, RIGHT_TO_LEFT, Std.int(healthBarBG.width - 8), Std.int(healthBarBG.height - 8), this,
			'health', 0, 2);
		healthBar.scrollFactor.set();
		// healthBar

		// Add Kade Engine watermark
		kadeEngineWatermark = new FlxText(4, healthBarBG.y
			+ 50, 0,
			CoolUtil.translate(SONG.songId)
			+ (FlxMath.roundDecimal(songMultiplier, 2) != 1.00 ? " (" + FlxMath.roundDecimal(songMultiplier, 2) + "x)" : "")
			+ " - "
			+ storyDifficulty,
			16);
		kadeEngineWatermark.setFormat(Paths.font("vcr.ttf"), 16, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		kadeEngineWatermark.scrollFactor.set();
		add(kadeEngineWatermark);

		if (PlayStateChangeables.useDownscroll)
			kadeEngineWatermark.y = FlxG.height * 0.9 + 45;

		scoreTxt = new FlxText(FlxG.width / 2 - 235, healthBarBG.y + 50, 0, "", 20);
		scoreTxt.screenCenter(X);
		scoreTxt.scrollFactor.set();
		scoreTxt.setFormat(Paths.font("vcr.ttf"), 16, FlxColor.WHITE, FlxTextAlign.CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		scoreTxt.text = Ratings.CalculateRanking(songScore, songScoreDef, nps, maxNPS, accuracy);
		if (!FlxG.save.data.healthBar)
			scoreTxt.y = healthBarBG.y;

		add(scoreTxt);

		judgementCounter = new FlxText(20, 0, 0, "", 20);
		judgementCounter.setFormat(Paths.font("vcr.ttf"), 20, FlxColor.WHITE, FlxTextAlign.LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		judgementCounter.borderSize = 2;
		judgementCounter.borderQuality = 2;
		judgementCounter.scrollFactor.set();
		judgementCounter.cameras = [camHUD];
		judgementCounter.screenCenter(Y);
		judgementCounter.text = CoolUtil.translate('judgementCounterSicks') + ' ${sicks}\n' + CoolUtil.translate('judgementCounterGoods') + ' ${goods}\n' + CoolUtil.translate('judgementCounterBads') + ' ${bads}\n' + CoolUtil.translate('judgementCounterShits') + ' ${shits}\n' + CoolUtil.translate('judgementCounterMisses') + ' ${misses}\n';
		if (FlxG.save.data.judgementCounter)
		{
			add(judgementCounter);
		}

		replayTxt = new FlxText(healthBarBG.x + healthBarBG.width / 2 - 75, healthBarBG.y + (PlayStateChangeables.useDownscroll ? 100 : -100), 0, "REPLAY",
			20);
		replayTxt.setFormat(Paths.font("vcr.ttf"), 42, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		replayTxt.borderSize = 4;
		replayTxt.borderQuality = 2;
		replayTxt.scrollFactor.set();
		replayTxt.cameras = [camHUD];
		if (loadRep)
		{
			add(replayTxt);
		}
		// Literally copy-paste of the above, fu
		botPlayState = new FlxText(healthBarBG.x + healthBarBG.width / 2 - 75, healthBarBG.y + (PlayStateChangeables.useDownscroll ? 100 : -100), 0,
			CoolUtil.translate("botplayDisplay"), 20);
		botPlayState.setFormat(Paths.font("vcr.ttf"), 42, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		botPlayState.scrollFactor.set();
		botPlayState.borderSize = 4;
		botPlayState.borderQuality = 2;
		botPlayState.cameras = [camHUD];
		if (PlayStateChangeables.botPlay && !loadRep)
			add(botPlayState);

		addedBotplay = PlayStateChangeables.botPlay;

		iconP1 = new HealthIcon(boyfriend.icon.image, boyfriend.icon.frames, true);
		iconP1.y = healthBar.y - (iconP1.height / 2);

		iconP2 = new HealthIcon(dad.icon.image, dad.icon.frames, false);
		iconP2.y = healthBar.y - (iconP2.height / 2);

		if (FlxG.save.data.healthBar)
		{
			add(healthBarBG);
			add(healthBar);
			add(iconP1);
			add(iconP2);

			if (FlxG.save.data.colour)
				healthBar.createFilledBar(dad.barColor, boyfriend.barColor);
			else
				healthBar.createFilledBar(0xFFFF0000, 0xFF66FF33);
		}

		strumLineNotes.cameras = [camHUD];
		notes.cameras = [camHUD];
		healthBar.cameras = [camHUD];
		healthBarBG.cameras = [camHUD];
		iconP1.cameras = [camHUD];
		iconP2.cameras = [camHUD];
		scoreTxt.cameras = [camHUD];
		laneunderlay.cameras = [camRatings]; // Technically inaccurate but it's done this way so the ratings appear on top of the underlay
		laneunderlayOpponent.cameras = [camRatings];

		kadeEngineWatermark.cameras = [camHUD];

		startingSong = true;

		trace('starting');

		dad.dance();
		boyfriend.dance();
		gf.dance();

		if (isStoryMode && !hasPlayedCutscene)
		{
			switch (SONG.songId)
			{
				case "dungeon":
					playCutsceneDungeon();
				case "risking-life":
					playCutsceneRiskingLife();
				case "vengeance":
					playCutsceneVengeance();
				case "revival":
					playCutsceneRevival();
				default:
					new FlxTimer().start(1, function(timer)
					{
						startCountdown();
					});
			}
		}
		else
		{
			new FlxTimer().start(1, function(timer)
			{
				startCountdown();
			});
		}

		if (!loadRep)
			rep = new Replay("na");

		// This allow arrow key to be detected by flixel. See https://github.com/HaxeFlixel/flixel/issues/2190
		FlxG.keys.preventDefaultKeys = [];
		FlxG.stage.addEventListener(KeyboardEvent.KEY_DOWN, handleInput);
		FlxG.stage.addEventListener(KeyboardEvent.KEY_UP, releaseInput);
		super.create();
	}

	public static var hasPlayedCutscene:Bool = false;

	var startTimer:FlxTimer;
	var perfectMode:Bool = false;
	var luaWiggles:Array<WiggleEffect> = [];

	var AntimusBody:FlxSprite;
	var AntimusFace:FlxSprite;
	var AntimusLeftArm:FlxSprite;
	var GirlfriendBody:FlxSprite;
	var GirlfriendFace:FlxSprite;
	var BoyfriendBody:FlxSprite;
	var BoyfriendFace:FlxSprite;
	var speakers:Character;

	var cutsceneStatus:Int = 0;
	var animFrame:Int = 0;
	var animFramePrev:Int = 0;

	private var cutsceneSubtitles:FlxText;
	var cutsceneSkipProgress:Float = 0;
	var cutsceneSkipProgressBar:FlxBar;

	var cutsceneMusic:FlxSound;

	#if FEATURE_LUAMODCHART
	public static var luaModchart:ModchartState = null;
	#end

	var antimusDia:FlxSound;
	function dialogueLine( dialoguePath:String, subtitleText:String ):Void
	{
		if (antimusDia != null)
			antimusDia.stop();

		if (subtitleText == 'subtitleAhFuck')
		{
			cutsceneSubtitles.text = CoolUtil.translate('subtitleAhFuck1');
			new FlxTimer().start(1.2, function(tmr:FlxTimer)
			{
				cutsceneSubtitles.text = CoolUtil.translate('subtitleAhFuck2');
				cutsceneSubtitles.screenCenter(X);
			});
		}
		else
			cutsceneSubtitles.text = CoolUtil.translate(subtitleText);
		cutsceneSubtitles.screenCenter(X);

		antimusDia = new FlxSound().loadEmbedded(Paths.sound(dialoguePath, 'cutscenes'), false, true, function()
		{
			cutsceneSubtitles.text = '';
		});
		antimusDia.play(true);
	}

	function makeCutsceneStuff(directory:String, cutTime:Float, includeSpeakers:Bool, dialogueSounds:Array<String>, bfPos:Array<Int>, gfPos:Array<Int>, anPos:Array<Int>):Void
	{
		camHUD.visible = false;
		camHUD.zoom = 1.5;

		cutsceneSubtitles = new FlxText(FlxG.width / 2, FlxG.height - 115, FlxG.width - 300, "", 20);
		cutsceneSubtitles.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		cutsceneSubtitles.borderSize = 2;
		cutsceneSubtitles.borderQuality = 2;
		if (FlxG.save.data.subtitles)
			add(cutsceneSubtitles);
		cutsceneSubtitles.cameras = [camCutsceneHUD];

		cutsceneSkipProgressBar = new FlxBar(200, FlxG.height - 150, FlxBarFillDirection.LEFT_TO_RIGHT, FlxG.width - 400, 25, this, "cutsceneSkipProgress", 0, 1);
        cutsceneSkipProgressBar.createFilledBar(FlxColor.BLACK, FlxColor.WHITE);
		cutsceneSkipProgressBar.alpha = 0;
		add(cutsceneSkipProgressBar);
		cutsceneSkipProgressBar.cameras = [camCutsceneHUD];

		for (snd in dialogueSounds)
		{
			FlxG.sound.cache(Paths.sound(directory + '/dialogue/' + snd, 'cutscenes'));
		}

		if (includeSpeakers)
		{
			remove(boyfriend);
			speakers = new Character(400, 435, 'speakers');
			speakers.scrollFactor.set(0.95, 0.95);
			add(speakers);
			speakers.playAnim('static');
			add(boyfriend);
		}

		if (directory.indexOf('revival') <= -1)
		{
			dad.alpha = 0;
			AntimusBody = new FlxSprite(anPos[0], anPos[1]);
			AntimusBody.antialiasing = FlxG.save.data.antialiasing;
			AntimusBody.frames = Paths.getSparrowAtlas(directory + '/AntimusBody', 'cutscenes');
			AntimusBody.animation.addByPrefix('anim', 'anim', 24, false);
			add(AntimusBody);

			AntimusFace = new FlxSprite(anPos[2], anPos[3]);
			AntimusFace.antialiasing = FlxG.save.data.antialiasing;
			AntimusFace.frames = Paths.getSparrowAtlas(directory + '/AntimusFace', 'cutscenes');
			AntimusFace.animation.addByPrefix('anim', 'anim', 24, false);
			add(AntimusFace);

			if (directory == 'vengeanceClosingCutscene')
			{
				AntimusLeftArm = new FlxSprite(anPos[4], anPos[5]);
				AntimusLeftArm.antialiasing = FlxG.save.data.antialiasing;
				AntimusLeftArm.frames = Paths.getSparrowAtlas(directory + '/AntimusLeftArm', 'cutscenes');
				AntimusLeftArm.animation.addByPrefix('anim', 'anim', 24, false);
				add(AntimusLeftArm);
			}
		}

		if (includeSpeakers)
			gf.alpha = 0;
		GirlfriendBody = new FlxSprite(gfPos[0], gfPos[1]);
		GirlfriendBody.antialiasing = FlxG.save.data.antialiasing;
		GirlfriendBody.frames = Paths.getSparrowAtlas(directory + '/GirlfriendBody', 'cutscenes');
		GirlfriendBody.animation.addByPrefix('anim', 'anim', 24, false);
		if (directory == 'vengeanceClosingCutscene')
			GirlfriendBody.alpha = 0;
		else if (directory.indexOf('revival') <= -1)
			GirlfriendBody.scrollFactor.set(0.95, 0.95);
		add(GirlfriendBody);

		if (directory == 'vengeanceCutscene')
		{
			GirlfriendOverlay = new FlxSprite(833, 459).loadGraphic(Paths.image(directory + '/GirlfriendOverlay', 'cutscenes'));
			GirlfriendOverlay.antialiasing = FlxG.save.data.antialiasing;
			GirlfriendOverlay.scrollFactor.set(0.95, 0.95);
			add(GirlfriendOverlay);
			GirlfriendOverlay.visible = false;
		}

		GirlfriendFace = new FlxSprite(gfPos[2], gfPos[3]);
		GirlfriendFace.antialiasing = FlxG.save.data.antialiasing;
		GirlfriendFace.frames = Paths.getSparrowAtlas(directory + '/GirlfriendFace', 'cutscenes');
		GirlfriendFace.animation.addByPrefix('anim', 'anim', 24, false);
		if (directory == 'vengeanceClosingCutscene')
			GirlfriendFace.alpha = 0;
		else if (directory.indexOf('revival') <= -1)
			GirlfriendFace.scrollFactor.set(0.95, 0.95);
		add(GirlfriendFace);

		if (directory != 'vengeanceClosingCutscene' && directory != 'revivalCutscene')
		{
			boyfriend.alpha = 0;
			BoyfriendBody = new FlxSprite(bfPos[0], bfPos[1]);
			BoyfriendBody.antialiasing = FlxG.save.data.antialiasing;
			BoyfriendBody.frames = Paths.getSparrowAtlas(directory + '/BoyfriendBody', 'cutscenes');
			BoyfriendBody.animation.addByPrefix('anim', 'anim', 24, false);
			add(BoyfriendBody);

			BoyfriendFace = new FlxSprite(bfPos[2], bfPos[3]);
			BoyfriendFace.antialiasing = FlxG.save.data.antialiasing;
			BoyfriendFace.frames = Paths.getSparrowAtlas(directory + '/BoyfriendFace', 'cutscenes');
			BoyfriendFace.animation.addByPrefix('anim', 'anim', 24, false);
			add(BoyfriendFace);
		}

		if (directory.indexOf('revival') <= -1)
		{
			AntimusBody.animation.play('anim');
			AntimusFace.animation.play('anim');
			if (directory == 'vengeanceClosingCutscene')
				AntimusLeftArm.animation.play('anim');
		}
		GirlfriendBody.animation.play('anim');
		GirlfriendFace.animation.play('anim');
		if (directory != 'vengeanceClosingCutscene' && directory != 'revivalCutscene')
		{
			BoyfriendBody.animation.play('anim');
			BoyfriendFace.animation.play('anim');
		}

		if (directory.indexOf('Closing') > -1)
			cutsceneStatus = 2;
		else
			cutsceneStatus = 1;
		animFrame = 0;
		animFramePrev = 0;

		if (directory.indexOf('Closing') > -1)
		{
			new FlxTimer().start(cutTime, function(tmr:FlxTimer)
			{
				cutsceneStatus = 0;
				transIn = FlxTransitionableState.defaultTransIn;
				transOut = FlxTransitionableState.defaultTransOut;

				FlxTransitionableState.skipNextTransIn = false;
				FlxTransitionableState.skipNextTransOut = false;
				endSongFinished(wantsToSkip, false);
				clean();
			});
		}
		else
		{
			new FlxTimer().start(cutTime, function(tmr:FlxTimer)
			{
				camHUD.visible = true;
				FlxG.camera.follow(camFollow, LOCKON, 0.04 * (30 / (cast(Lib.current.getChildAt(0), Main)).getFPS()));
				FlxTween.tween(FlxG.camera, {zoom: Stage.camZoom}, 1.5, {
					ease: FlxEase.quadInOut,
				});
				FlxTween.tween(camHUD, {zoom: PlayStateChangeables.zoom}, 0.85, {
					ease: FlxEase.quadOut,
				});
				cutsceneStatus = 0;
				cutsceneSkipProgress = 0;
				remove(cutsceneSkipProgressBar);
				remove(cutsceneSubtitles);
				PlayState.hasPlayedCutscene = true;
				startCountdown();
			});
		}
	}

	function playCutsceneDungeon():Void
	{
		makeCutsceneStuff('dungeonCutscene', 35.583, true, ['doWhatYouAlways', 'howCourteous', 'mattersMuch', 'someParty', 'thankYouMiss', 'whiteLies'], [926, 390, 1090, 482], [512, 60, 622, 248], [-110, 131, 50, 195]);

		camFollow.x = 920;
		camFollow.y = 560;
		FlxG.camera.focusOn(camFollow.getPosition());
		FlxG.camera.zoom = 1.15;
		FlxG.camera.follow(camFollow, LOCKON, 1);

		cutsceneMusic = new FlxSound().loadEmbedded(Paths.music('cutsceneLoop', 'cutscenes'), true);
		cutsceneMusic.volume = 0;
		FlxG.sound.list.add(cutsceneMusic);
		cutsceneMusic.fadeIn(1, 0, 0.45);

		FlxG.sound.play(Paths.sound('dungeonCutscene/roomNoise', 'cutscenes'), 0.3);

		new FlxTimer().start(34, function(tmr:FlxTimer)
		{
			cutsceneMusic.fadeOut(2);
		});
	}

	function playCutsceneRiskingLife():Void
	{
		makeCutsceneStuff('riskingLifeCutscene', 28.375, true, ['cheating', 'imJoking', 'letMeKnow', 'notBad', 'twistTheBattles', 'yourGirlfriend'], [867, 416, 1087, 510], [574, 110, 672, 253], [-37, 131, 230, 201]);

		camFollow.x = 730;
		camFollow.y = 500;

		if (FlxG.camera.zoom != 0.9)
		{
			FlxTween.tween(FlxG.camera, {zoom: 0.9}, 0.5, {
				ease: FlxEase.quadOut,
			});
		}

		cutsceneMusic = new FlxSound().loadEmbedded(Paths.music('cutsceneLoop', 'cutscenes'), true);
		cutsceneMusic.volume = 0;
		FlxG.sound.list.add(cutsceneMusic);
		cutsceneMusic.fadeIn(1, 0, 0.45);

		FlxG.sound.play(Paths.sound('riskingLifeCutscene/roomNoise', 'cutscenes'), 0.3);

		new FlxTimer().start(4.0 / 24.0, function(tmr:FlxTimer)
		{
			dialogueLine('riskingLifeCutscene/dialogue/notBad', 'subtitleNotBad');
		});

		new FlxTimer().start(27, function(tmr:FlxTimer)
		{
			cutsceneMusic.fadeOut(2);
		});
	}

	var vengLab:Stage;
	var vengLabCracks:FlxSprite;
	var vengLabTop:FlxSprite;
	var vengLabBottom:FlxSprite;
	var GirlfriendOverlay:FlxSprite;

	var bloodGarglingLoop:FlxSound;

	function playCutsceneVengeance():Void
	{
		vengLab = new Stage('lab');
		for (i in vengLab.toAdd)
		{
			if (vengLab.swagBacks["back"] == i)
			{
				vengLabBottom = new FlxSprite(i.x, i.y).loadGraphic(Paths.image('vengeanceCutscene/labBottom', 'cutscenes'));
				vengLabBottom.antialiasing = FlxG.save.data.antialiasing;
				vengLabBottom.scrollFactor.set(0.8, 0.9);
				add(vengLabBottom);

				vengLabTop = new FlxSprite(i.x, i.y).loadGraphic(Paths.image('vengeanceCutscene/labTop', 'cutscenes'));
				vengLabTop.antialiasing = FlxG.save.data.antialiasing;
				vengLabTop.scrollFactor.set(0.8, 0.9);
				add(vengLabTop);
			}
			add(i);
			if (vengLab.swagBacks["back"] == i)
			{
				vengLabCracks = new FlxSprite(i.x, i.y);
				vengLabCracks.frames = Paths.getSparrowAtlas('vengeanceCutscene/labCrack', 'cutscenes');
				vengLabCracks.animation.addByPrefix('idle', "idle", 24, false);
				vengLabCracks.animation.addByPrefix('crack', "crack", 24, false);
				vengLabCracks.animation.play('idle');
				vengLabCracks.antialiasing = FlxG.save.data.antialiasing;
				vengLabCracks.scrollFactor.set(0.8, 0.9);
				add(vengLabCracks);
			}
		}

		speakers = new Character(400, 435, 'speakers');
		speakers.scrollFactor.set(0.95, 0.95);
		add(speakers);
		speakers.playAnim('static');

		makeCutsceneStuff('vengeanceCutscene', 47, false, ['illogicalNature', 'itsYouIsntIt', 'missHimAlready', 'myTheory', 'nervesOfSteel', 'pushedTooHard', 'theSupernatural'], [951, 428, 1127, 557], [516, 60, 660, 202], [-42, 127, 234, 192]);

		camFollow.x = 730;
		camFollow.y = 500;
		FlxG.camera.focusOn(camFollow.getPosition());
		FlxG.camera.zoom = 0.9;
		FlxG.camera.follow(camFollow, LOCKON, 1);

		bloodGarglingLoop = new FlxSound().loadEmbedded(Paths.sound('vengeanceCutscene/bloodGarglingLoop', 'cutscenes'));
		bloodGarglingLoop.looped = true;
		bloodGarglingLoop.play();
		bloodGarglingLoop.fadeIn(1, 0, 0.2);

		FlxG.sound.play(Paths.music('vengCutscene', 'cutscenes'), 0.3);
	}

	function playCutsceneVengeanceEnd():Void
	{
		inCutscene = true;
	
		makeCutsceneStuff('vengeanceClosingCutscene', 18.75, false, ['ahFuck', 'skillsImpressive', 'suchIntensity', 'yourLungs'], [], [1122, 339, 1224, 487], [-58, 112, 89, 198, -69, -101]);

		camFollow.x = 700;
		camFollow.y = 300;

		FlxG.sound.play(Paths.sound('vengeanceClosingCutscene/roomNoise', 'cutscenes'), 0.15);

		if (FlxG.camera.zoom != 0.5)
		{
			FlxTween.tween(FlxG.camera, {zoom: 0.5}, 0.5, {
				ease: FlxEase.quadOut,
			});
		}

		new FlxTimer().start(10.0 / 24.0, function(tmr:FlxTimer)
		{
			dialogueLine('vengeanceClosingCutscene/dialogue/skillsImpressive', 'subtitleSkillsImpressive');
		});
	}

	function playCutsceneRevival():Void
	{
		makeCutsceneStuff('revivalCutscene', 9.375, false, [], [], [466, 319, 541, 460], []);
		boyfriend.alpha = 0;

		camFollow.x = 475;
		camFollow.y = 440;
		FlxG.camera.focusOn(camFollow.getPosition());
		FlxG.camera.zoom = 1.5;
		FlxG.camera.follow(camFollow, LOCKON, 1);

		Stage.swagBacks['spellbook'].alpha = 0;
	}

	function playCutsceneRevivalEnd():Void
	{
		inCutscene = true;

		makeCutsceneStuff('revivalClosingCutscene', 8.75, false, [], [66, 225, 285, 353], [261, 145, 840, 468], []);
		dad.alpha = 0;

		camFollow.x = 827;
		camFollow.y = 499;

		if (FlxG.camera.zoom != 0.9)
		{
			FlxTween.tween(FlxG.camera, {zoom: 0.9}, 0.5, {
				ease: FlxEase.quadOut,
			});
		}
	}

	function hscriptRefresh()
	{
		for (sc in myScripts.iterator())
			sc.refreshVariables();
	}

	function hscriptExec(func:String, args:Array<Dynamic>)
	{
		for (sc in myScripts.iterator())
			sc.execFunc(func, args);
	}

	function hscriptSet(vari:String, val:Dynamic)
	{
		for (sc in myScripts.iterator())
			sc.setVar(vari, val);
	}

	function startCountdown():Void
	{
		inCutscene = false;
		hscriptExec("startCountdown", []);

		healthGraphInfo = [[0, 1]];
		appearStaticArrows();
		// generateStaticArrows(0);
		// generateStaticArrows(1);

		talking = false;
		startedCountdown = true;
		Conductor.songPosition = 0;
		Conductor.songPosition -= Conductor.crochet * 5;

		if (FlxG.sound.music.playing)
			FlxG.sound.music.stop();
		if (vocals != null)
			vocals.stop();

		var swagCounter:Int = 0;

		startTimer = new FlxTimer().start(Conductor.crochet / 1000, function(tmr:FlxTimer)
		{
			if (cutsceneStatus <= 0)
			{
				// this just based on beatHit stuff but compact
				if (allowedToHeadbang && swagCounter % gfSpeed == 0)
					gf.dance();
				if (swagCounter % idleBeat == 0)
				{
					if (idleToBeat && !boyfriend.animation.curAnim.name.endsWith("miss"))
						boyfriend.dance(forcedToIdle);
					if (idleToBeat)
						dad.dance(forcedToIdle);
				}

				var introAssets:Map<String, Array<String>> = new Map<String, Array<String>>();
				introAssets.set('default', ['ready', "set", "go"]);
				introAssets.set('pixel', ['weeb/pixelUI/ready-pixel', 'weeb/pixelUI/set-pixel', 'weeb/pixelUI/date-pixel']);

				var introAlts:Array<String> = introAssets.get('default');
				var week6Bullshit:String = null;

				switch (swagCounter)

				{
					case 0:
						if (SONG.player1.startsWith('bf'))
							FlxG.sound.play(Paths.sound('intro3' + altSuffix), 0.6);
					case 1:
						var ready:FlxSprite = new FlxSprite().loadGraphic(Paths.loadImage(introAlts[0], week6Bullshit));
						ready.scrollFactor.set();
						ready.updateHitbox();

						ready.screenCenter();
						add(ready);
						FlxTween.tween(ready, {y: ready.y += 100, alpha: 0}, Conductor.crochet / 1000, {
							ease: FlxEase.cubeInOut,
							onComplete: function(twn:FlxTween)
							{
								ready.destroy();
							}
						});
						if (SONG.player1.startsWith('bf'))
							FlxG.sound.play(Paths.sound('intro2' + altSuffix), 0.6);
					case 2:
						var set:FlxSprite = new FlxSprite().loadGraphic(Paths.loadImage(introAlts[1], week6Bullshit));
						set.scrollFactor.set();

						set.screenCenter();
						add(set);
						FlxTween.tween(set, {y: set.y += 100, alpha: 0}, Conductor.crochet / 1000, {
							ease: FlxEase.cubeInOut,
							onComplete: function(twn:FlxTween)
							{
								set.destroy();
							}
						});
						if (SONG.player1.startsWith('bf'))
							FlxG.sound.play(Paths.sound('intro1' + altSuffix), 0.6);
					case 3:
						var go:FlxSprite = new FlxSprite().loadGraphic(Paths.loadImage(introAlts[2], week6Bullshit));
						go.scrollFactor.set();

						go.updateHitbox();

						go.screenCenter();
						add(go);
						FlxTween.tween(go, {y: go.y += 100, alpha: 0}, Conductor.crochet / 1000, {
							ease: FlxEase.cubeInOut,
							onComplete: function(twn:FlxTween)
							{
								go.destroy();
							}
						});
						if (SONG.player1.startsWith('bf'))
							FlxG.sound.play(Paths.sound('introGo' + altSuffix), 0.6);
				}

				swagCounter += 1;
			}
		}, 4);
	}

	var previousFrameTime:Int = 0;
	var lastReportedPlayheadPosition:Int = 0;
	var songTime:Float = 0;

	private function getKey(charCode:Int):String
	{
		for (key => value in FlxKey.fromStringMap)
		{
			if (charCode == value)
				return key;
		}
		return null;
	}

	var keys = [false, false, false, false, false];

	private function releaseInput(evt:KeyboardEvent):Void // handles releases
	{
		@:privateAccess
		var key = FlxKey.toStringMap.get(evt.keyCode);

		var binds:Array<String> = [
			FlxG.save.data.leftBind,
			FlxG.save.data.downBind,
			FlxG.save.data.upBind,
			FlxG.save.data.rightBind
		];

		if (SONG.fiveKey)
			binds = [FlxG.save.data.leftFiveBind, FlxG.save.data.downFiveBind, FlxG.save.data.centerBind, FlxG.save.data.upFiveBind, FlxG.save.data.rightFiveBind];

		var data = -1;

		if (SONG.fiveKey)
		{
			switch (evt.keyCode) // arrow keys + space bar
			{
				case 37:
					data = 0;
				case 40:
					data = 1;
				case 32:
					data = 2;
				case 38:
					data = 3;
				case 39:
					data = 4;
			}
		}
		else
		{
			switch (evt.keyCode) // arrow keys
			{
				case 37:
					data = 0;
				case 40:
					data = 1;
				case 38:
					data = 2;
				case 39:
					data = 3;
			}
		}

		for (i in 0...binds.length) // binds
		{
			if (binds[i].toLowerCase() == key.toLowerCase())
				data = i;
		}

		if (data == -1)
			return;

		keys[data] = false;
	}

	public var closestNotes:Array<Note> = [];

	private function handleInput(evt:KeyboardEvent):Void
	{ // this actually handles press inputs

		if (PlayStateChangeables.botPlay || loadRep || paused)
			return;

		// first convert it from openfl to a flixel key code
		// then use FlxKey to get the key's name based off of the FlxKey dictionary
		// this makes it work for special characters

		@:privateAccess
		var key = FlxKey.toStringMap.get(evt.keyCode);

		var binds:Array<String> = [
			FlxG.save.data.leftBind,
			FlxG.save.data.downBind,
			FlxG.save.data.upBind,
			FlxG.save.data.rightBind
		];

		if (SONG.fiveKey)
			binds = [FlxG.save.data.leftFiveBind, FlxG.save.data.downFiveBind, FlxG.save.data.centerBind, FlxG.save.data.upFiveBind, FlxG.save.data.rightFiveBind];

		var data = -1;

		if (SONG.fiveKey)
		{
			switch (evt.keyCode) // arrow keys + space bar
			{
				case 37:
					data = 0;
				case 40:
					data = 1;
				case 32:
					data = 2;
				case 38:
					data = 3;
				case 39:
					data = 4;
			}
		}
		else
		{
			switch (evt.keyCode) // arrow keys
			{
				case 37:
					data = 0;
				case 40:
					data = 1;
				case 38:
					data = 2;
				case 39:
					data = 3;
			}
		}

		for (i in 0...binds.length) // binds
		{
			if (binds[i].toLowerCase() == key.toLowerCase())
				data = i;
		}
		if (data == -1)
		{
			trace("couldn't find a keybind with the code " + key);
			return;
		}
		if (keys[data])
		{
			trace("ur already holding " + key);
			return;
		}

		keys[data] = true;

		var ana = new Ana(Conductor.songPosition, null, false, "miss", data);

		closestNotes = [];

		notes.forEachAlive(function(daNote:Note)
		{
			if (daNote.canBeHit && daNote.mustPress && !daNote.wasGoodHit)
				closestNotes.push(daNote);
		}); // Collect notes that can be hit

		closestNotes.sort((a, b) -> Std.int(a.strumTime - b.strumTime));

		var dataNotes = [];
		for (i in closestNotes)
			if (i.noteData == data && !i.isSustainNote)
				dataNotes.push(i);

		trace("notes able to hit for " + key.toString() + " " + dataNotes.length);

		if (dataNotes.length != 0)
		{
			var coolNote = null;

			for (i in dataNotes)
			{
				coolNote = i;
				break;
			}

			if (dataNotes.length > 1) // stacked notes or really close ones
			{
				for (i in 0...dataNotes.length)
				{
					if (i == 0) // skip the first note
						continue;

					var note = dataNotes[i];

					if (!note.isSustainNote && ((note.strumTime - coolNote.strumTime) < 2) && note.noteData == data)
					{
						trace('found a stacked/really close note ' + (note.strumTime - coolNote.strumTime));
						// just fuckin remove it since it's a stacked note and shouldn't be there
						note.kill();
						notes.remove(note, true);
						note.destroy();
					}
				}
			}

			boyfriend.holdTimer = 0;
			goodNoteHit(coolNote);
			var noteDiff:Float = -(coolNote.strumTime - Conductor.songPosition);
			ana.hit = true;
			ana.hitJudge = Ratings.judgeNote(noteDiff);
			ana.nearestNote = [coolNote.strumTime, coolNote.noteData, coolNote.sustainLength];
		}
	}

	public var songStarted = false;

	public var doAnything = false;

	public static var songMultiplier = 1.0;

	public var bar:FlxSprite;

	public var previousRate = songMultiplier;

	function startSong():Void
	{
		startingSong = false;
		songStarted = true;
		previousFrameTime = FlxG.game.ticks;
		lastReportedPlayheadPosition = 0;

		FlxG.sound.music.play();
		vocals.play();

		// have them all dance when the song starts
		if (allowedToHeadbang)
			gf.dance();
		if (idleToBeat && !boyfriend.animation.curAnim.name.startsWith("sing"))
			boyfriend.dance(forcedToIdle);
		if (idleToBeat && !dad.animation.curAnim.name.startsWith("sing"))
			dad.dance(forcedToIdle);

		#if FEATURE_LUAMODCHART
		if (executeModchart)
			luaModchart.executeState("songStart", [null]);
		#end

		#if FEATURE_DISCORD
		// Updating Discord Rich Presence (with Time Left)
		DiscordClient.changePresence(detailsText
			+ " "
			+ CoolUtil.translate(SONG.songId)
			+ " ("
			+ storyDifficultyText
			+ ") "
			+ Ratings.GenerateLetterRank(accuracy),
			"\nAcc: "
			+ HelperFunctions.truncateFloat(accuracy, 2)
			+ "% | Score: "
			+ songScore
			+ " | Misses: "
			+ misses, iconRPC);
		#end

		FlxG.sound.music.time = startTime;
		if (vocals != null)
			vocals.time = startTime;
		Conductor.songPosition = startTime;
		startTime = 0;

		/*@:privateAccess
			{
				var aux = AL.createAux();
				var fx = AL.createEffect();
				AL.effectf(fx,AL.PITCH,songMultiplier);
				AL.auxi(aux, AL.EFFECTSLOT_EFFECT, fx);
				var instSource = FlxG.sound.music._channel.__source;

				var backend:lime._internal.backend.native.NativeAudioSource = instSource.__backend;

				AL.source3i(backend.handle, AL.AUXILIARY_SEND_FILTER, aux, 1, AL.FILTER_NULL);
				if (vocals != null)
				{
					var vocalSource = vocals._channel.__source;

					backend = vocalSource.__backend;
					AL.source3i(backend.handle, AL.AUXILIARY_SEND_FILTER, aux, 1, AL.FILTER_NULL);
				}

				trace("pitched to " + songMultiplier);
		}*/

		#if cpp
		@:privateAccess
		{
			lime.media.openal.AL.sourcef(FlxG.sound.music._channel.__source.__backend.handle, lime.media.openal.AL.PITCH, songMultiplier);
			if (vocals.playing)
				lime.media.openal.AL.sourcef(vocals._channel.__source.__backend.handle, lime.media.openal.AL.PITCH, songMultiplier);
		}
		trace("pitched inst and vocals to " + songMultiplier);
		#end

		for (i in 0...unspawnNotes.length)
			if (unspawnNotes[i].strumTime < startTime)
				unspawnNotes.remove(unspawnNotes[i]);

		if (needSkip)
		{
			skipActive = true;
			skipText = new FlxText(healthBarBG.x + 80, (FlxG.height * 0.9) - 110, 500);
			skipText.text = CoolUtil.translate('skipIntro');
			skipText.size = 30;
			skipText.color = FlxColor.WHITE;
			skipText.setBorderStyle(FlxTextBorderStyle.OUTLINE, FlxColor.BLACK, 2, 1);
			skipText.cameras = [camHUD];
			skipText.alpha = 0;
			FlxTween.tween(skipText, {alpha: 1}, 0.2);
			add(skipText);
		}
	}

	var debugNum:Int = 0;

	public function generateSong(dataPath:String):Void
	{
		var songData = SONG;
		Conductor.changeBPM(songData.bpm);

		curSong = songData.songId;

		#if FEATURE_STEPMANIA
		if (SONG.needsVoices && !isSM)
			vocals = new FlxSound().loadEmbedded(Paths.voices(PlayState.SONG.songId, storyDifficulty));
		else
			vocals = new FlxSound();
		#else
		if (SONG.needsVoices)
			vocals = new FlxSound().loadEmbedded(Paths.voices(PlayState.SONG.songId, storyDifficulty));
		else
			vocals = new FlxSound();
		#end

		trace('loaded vocals');

		FlxG.sound.list.add(vocals);

		if (!paused)
		{
			#if FEATURE_STEPMANIA
			if (!isStoryMode && isSM)
			{
				trace("Loading " + pathToSm + "/" + sm.header.MUSIC);
				var bytes = File.getBytes(pathToSm + "/" + sm.header.MUSIC);
				var sound = new Sound();
				sound.loadCompressedDataFromByteArray(bytes.getData(), bytes.length);
				FlxG.sound.playMusic(sound);
			}
			else
				FlxG.sound.playMusic(Paths.inst(PlayState.SONG.songId), 1, false);
			#else
			FlxG.sound.playMusic(Paths.inst(PlayState.SONG.songId), 1, false);
			#end
		}

		FlxG.sound.music.pause();

		if (SONG.needsVoices && !PlayState.isSM)
			FlxG.sound.cache(Paths.voices(PlayState.SONG.songId));
		if (!PlayState.isSM)
			FlxG.sound.cache(Paths.inst(PlayState.SONG.songId));

		// Song duration in a float, useful for the time left feature
		songLength = ((FlxG.sound.music.length / songMultiplier) / 1000);

		Conductor.crochet = ((60 / (SONG.bpm) * 1000));
		Conductor.stepCrochet = Conductor.crochet / 4;

		if (FlxG.save.data.songPosition)
		{
			songPosBG = new FlxSprite(0, 10).loadGraphic(Paths.loadImage('healthBar'));
			if (PlayStateChangeables.useDownscroll)
				songPosBG.y = FlxG.height * 0.9 + 35;
			songPosBG.screenCenter(X);
			songPosBG.scrollFactor.set();

			songPosBar = new FlxBar(640 - (Std.int(songPosBG.width - 100) / 2), songPosBG.y + 4, LEFT_TO_RIGHT, Std.int(songPosBG.width - 100),
				Std.int(songPosBG.height + 6), this, 'songPositionBar', 0, songLength);
			songPosBar.scrollFactor.set();
			songPosBar.createFilledBar(FlxColor.BLACK, FlxColor.fromRGB(0, 255, 128));
			add(songPosBar);

			bar = new FlxSprite(songPosBar.x, songPosBar.y).makeGraphic(Math.floor(songPosBar.width), Math.floor(songPosBar.height), FlxColor.TRANSPARENT);

			add(bar);

			FlxSpriteUtil.drawRect(bar, 0, 0, songPosBar.width, songPosBar.height, FlxColor.TRANSPARENT, {thickness: 4, color: FlxColor.BLACK});

			songPosBG.width = songPosBar.width;

			songName = new FlxText(songPosBG.x + (songPosBG.width / 2) - (CoolUtil.translate(SONG.songId).length * 5), songPosBG.y - 15, 0, CoolUtil.translate(SONG.songId), 16);
			songName.setFormat(Paths.font("vcr.ttf"), 16, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
			songName.scrollFactor.set();

			songName.text = CoolUtil.translate(SONG.songId) + ' (' + FlxStringUtil.formatTime(songLength, false) + ')';
			songName.y = songPosBG.y + (songPosBG.height / 3);

			add(songName);

			songName.screenCenter(X);

			songPosBG.cameras = [camHUD];
			bar.cameras = [camHUD];
			songPosBar.cameras = [camHUD];
			songName.cameras = [camHUD];
		}

		notes = new FlxTypedGroup<Note>();
		add(notes);

		var noteData:Array<SwagSection>;

		// NEW SHIT
		noteData = SONG.notes;

		var playerCounter:Int = 0;

		var daBeats:Int = 0; // Not exactly representative of 'daBeats' lol, just how much it has looped
		var noteCount = ( SONG.fiveKey ? 5 : 4 );

		for (section in noteData)
		{
			var coolSection:Int = Std.int(section.lengthInSteps / 4);

			for (songNotes in section.sectionNotes)
			{
				var daStrumTime:Float = songNotes[0] / songMultiplier;
				if (daStrumTime < 0)
					daStrumTime = 0;
				var daNoteData:Int = Std.int(songNotes[1] % noteCount);

				var gottaHitNote:Bool = true;

				if (songNotes[1] > (noteCount - 1) && section.mustHitSection)
					gottaHitNote = false;
				else if (songNotes[1] < noteCount && !section.mustHitSection)
					gottaHitNote = false;

				var oldNote:Note;
				if (unspawnNotes.length > 0)
					oldNote = unspawnNotes[Std.int(unspawnNotes.length - 1)];
				else
					oldNote = null;

				var shouldDownscroll = PlayStateChangeables.useDownscroll;
				if (songNotes[3])
					shouldDownscroll = !shouldDownscroll;
				var swagNote:Note = new Note(daStrumTime, daNoteData, oldNote, false, false, shouldDownscroll);

				swagNote.sustainLength = TimingStruct.getTimeFromBeat((TimingStruct.getBeatFromTime(songNotes[2] / songMultiplier)));
				swagNote.scrollFactor.set(0, 0);

				var susLength:Float = swagNote.sustainLength;

				susLength = susLength / Conductor.stepCrochet;
				unspawnNotes.push(swagNote);

				swagNote.isAlt = ((section.altAnim || section.CPUAltAnim) && !gottaHitNote)
					|| (section.playerAltAnim && gottaHitNote);

				if (susLength > 0)
					swagNote.isParent = true;

				var type = 0;

				for (susNote in 0...Math.round(susLength))
				{
					oldNote = unspawnNotes[Std.int(unspawnNotes.length - 1)];

					var sustainNote:Note = new Note(daStrumTime + (Conductor.stepCrochet * susNote) + Conductor.stepCrochet, daNoteData, oldNote, true, false, shouldDownscroll);
					sustainNote.scrollFactor.set();
					unspawnNotes.push(sustainNote);
					sustainNote.isAlt = swagNote.isAlt;

					sustainNote.mustPress = gottaHitNote;

					if (sustainNote.mustPress)
					{
						sustainNote.x += FlxG.width / 2; // general offset
					}

					sustainNote.parent = swagNote;
					swagNote.children.push(sustainNote);
					sustainNote.spotInLine = type;
					type++;
				}

				swagNote.mustPress = gottaHitNote;

				if (swagNote.mustPress)
				{
					swagNote.x += FlxG.width / 2; // general offset
				}
			}
			daBeats += 1;
		}

		// trace(unspawnNotes.length);
		// playerCounter += 1;

		unspawnNotes.sort(sortByShit);

		generatedMusic = true;

		Debug.logTrace("whats the fuckin shit");
	}

	function sortByShit(Obj1:Note, Obj2:Note):Int
	{
		return FlxSort.byValues(FlxSort.ASCENDING, Obj1.strumTime, Obj2.strumTime);
	}

	private function generateStaticArrows(player:Int):Void
	{
		var noteCount = ( SONG.fiveKey ? 5 : 4 );
		for (i in 0...noteCount)
		{
			// FlxG.log.add(i);
			var babyArrow:StaticArrow = new StaticArrow(0, strumLine.y);

			babyArrow.frames = noteskinSprite;
			Debug.logTrace(babyArrow.frames);

			var trueDataSuffix = ( SONG.fiveKey ? dataSuffixFiveK : dataSuffix );
			var trueDataColor = ( SONG.fiveKey ? dataColorFiveK : dataColor );
			var noteScale = ( SONG.fiveKey ? 0.8 : 1 );

			babyArrow.generateAnims(trueDataSuffix[i]);

			babyArrow.x += ( Note.swagWidth * noteScale ) * i;

			babyArrow.antialiasing = FlxG.save.data.antialiasing;
			babyArrow.setGraphicSize(Std.int(babyArrow.width * ( 0.7 * noteScale )));

			babyArrow.updateHitbox();
			babyArrow.scrollFactor.set();

			babyArrow.alpha = 0;
			if (!isStoryMode)
			{
				babyArrow.y -= 10;
				// babyArrow.alpha = 0;
				if (!PlayStateChangeables.middleScroll || executeModchart || player == 1)
					FlxTween.tween(babyArrow, {y: babyArrow.y + 10, alpha: 1}, 1, {ease: FlxEase.circOut, startDelay: 0.5 + (0.2 * i)});
			}

			babyArrow.ID = i;

			switch (player)
			{
				case 0:
					babyArrow.x += 20;
					cpuStrums.add(babyArrow);
				case 1:
					playerStrums.add(babyArrow);
			}

			babyArrow.playAnim('static');
			babyArrow.x += 96;
			babyArrow.x += ((FlxG.width / 2) * player);

			if (PlayStateChangeables.middleScroll && !executeModchart)
				babyArrow.x -= FlxG.width / 4;

			cpuStrums.forEach(function(spr:FlxSprite)
			{
				spr.centerOffsets(); // CPU arrows start out slightly off-center
			});

			strumLineNotes.add(babyArrow);
		}
	}

	private function appearStaticArrows():Void
	{
		playerStrums.forEach(function(babyArrow:FlxSprite)
		{
			if (isStoryMode)
				babyArrow.alpha = 1;
		});

		cpuStrums.forEach(function(babyArrow:FlxSprite)
		{
			if (isStoryMode && !PlayStateChangeables.middleScroll || executeModchart)
				babyArrow.alpha = 1;
		});
	}

	function tweenCamIn():Void
	{
		FlxTween.tween(FlxG.camera, {zoom: 1.3}, (Conductor.stepCrochet * 4 / 1000), {ease: FlxEase.elasticInOut});
	}

	override function openSubState(SubState:FlxSubState)
	{
		if (paused)
		{
			if (FlxG.sound.music.playing)
			{
				FlxG.sound.music.pause();
				if (vocals != null)
					if (vocals.playing)
						vocals.pause();
			}

			#if FEATURE_DISCORD
			DiscordClient.changePresence("PAUSED on "
				+ CoolUtil.translate(SONG.songId)
				+ " ("
				+ storyDifficultyText
				+ ") "
				+ Ratings.GenerateLetterRank(accuracy),
				"\nAcc: "
				+ HelperFunctions.truncateFloat(accuracy, 2)
				+ "% | Score: "
				+ songScore
				+ " | Misses: "
				+ misses, iconRPC);
			#end
			if (!startTimer.finished)
				startTimer.active = false;
		}

		super.openSubState(SubState);
	}

	override function closeSubState()
	{
		if (PauseSubState.goToOptions)
		{
			Debug.logTrace("pause thingyt");
			if (PauseSubState.goBack)
			{
				Debug.logTrace("pause thingyt");
				PauseSubState.goToOptions = false;
				PauseSubState.goBack = false;
				openSubState(new PauseSubState());
			}
			else
				openSubState(new OptionsMenu(true));
		}
		else if (paused)
		{
			if (FlxG.sound.music != null && !startingSong)
			{
				resyncVocals();
			}

			if (!startTimer.finished)
				startTimer.active = true;
			paused = false;

			#if FEATURE_DISCORD
			if (startTimer.finished)
			{
				DiscordClient.changePresence(detailsText
					+ " "
					+ CoolUtil.translate(SONG.songId)
					+ " ("
					+ storyDifficultyText
					+ ") "
					+ Ratings.GenerateLetterRank(accuracy),
					"\nAcc: "
					+ HelperFunctions.truncateFloat(accuracy, 2)
					+ "% | Score: "
					+ songScore
					+ " | Misses: "
					+ misses, iconRPC, true,
					songLength
					- Conductor.songPosition);
			}
			else
			{
				DiscordClient.changePresence(detailsText, CoolUtil.translate(SONG.songId) + " (" + storyDifficultyText + ") " + Ratings.GenerateLetterRank(accuracy), iconRPC);
			}
			#end
		}

		super.closeSubState();
	}

	function resyncVocals():Void
	{
		vocals.stop();
		FlxG.sound.music.stop();

		FlxG.sound.music.play();
		vocals.play();
		FlxG.sound.music.time = Conductor.songPosition * songMultiplier;
		vocals.time = FlxG.sound.music.time;

		@:privateAccess
		{
			#if desktop
			// The __backend.handle attribute is only available on native.
			lime.media.openal.AL.sourcef(FlxG.sound.music._channel.__source.__backend.handle, lime.media.openal.AL.PITCH, songMultiplier);
			if (vocals.playing)
				lime.media.openal.AL.sourcef(vocals._channel.__source.__backend.handle, lime.media.openal.AL.PITCH, songMultiplier);
			#end
		}

		#if FEATURE_DISCORD
		DiscordClient.changePresence(detailsText
			+ " "
			+ CoolUtil.translate(SONG.songId)
			+ " ("
			+ storyDifficultyText
			+ ") "
			+ Ratings.GenerateLetterRank(accuracy),
			"\nAcc: "
			+ HelperFunctions.truncateFloat(accuracy, 2)
			+ "% | Score: "
			+ songScore
			+ " | Misses: "
			+ misses, iconRPC);
		#end
	}

	public var paused:Bool = false;

	var startedCountdown:Bool = false;
	var canPause:Bool = true;
	var nps:Int = 0;
	var maxNPS:Int = 0;

	public var stopUpdate = false;

	public var currentBPM = 0;

	public var updateFrame = 0;

	public var pastScrollChanges:Array<Song.Event> = [];

	var currentLuaIndex = 0;

	override public function update(elapsed:Float)
	{
		#if !debug
		perfectMode = false;
		#end
		Stage.update(elapsed);

		hscriptExec('update', [elapsed]);

		if (cutsceneStatus > 0)
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
					var oldCutStat = cutsceneStatus;
					cutsceneStatus = 0;
					if (oldCutStat == 1)
					{
						FlxG.stage.removeEventListener(KeyboardEvent.KEY_DOWN, handleInput);
						FlxG.stage.removeEventListener(KeyboardEvent.KEY_UP, releaseInput);
					}

					transIn = FlxTransitionableState.defaultTransIn;
					transOut = FlxTransitionableState.defaultTransOut;

					FlxTransitionableState.skipNextTransIn = false;
					FlxTransitionableState.skipNextTransOut = false;

					PlayState.hasPlayedCutscene = true;
					FlxG.sound.music.stop();
					if (antimusDia != null)
						antimusDia.stop();
					if (SONG.songId == 'vengeance' && oldCutStat == 1)
					{
						if (bloodGarglingLoop.playing)
							bloodGarglingLoop.stop();
					}

					if (oldCutStat == 2)
						endSongFinished(wantsToSkip, false, true);
					else
						LoadingState.loadAndSwitchState(new PlayState());
					clean();
				}
			}
			else
			{
				cutsceneSkipProgress = 0;
				cutsceneSkipProgressBar.alpha = 0;
			}

			if ((SONG.songId == 'vengeance' && cutsceneStatus == 2) || (SONG.songId == 'revival' && cutsceneStatus == 1))
				animFrame = GirlfriendBody.animation.curAnim.curFrame;
			else if (SONG.songId == 'revival' && cutsceneStatus == 2)
				animFrame = BoyfriendBody.animation.curAnim.curFrame;
			else
				animFrame = AntimusBody.animation.curAnim.curFrame;
			if (animFramePrev != animFrame)
			{
				switch (SONG.songId)
				{
					case "dungeon":
						switch (animFrame)
						{
							case 67:
								dialogueLine('dungeonCutscene/dialogue/someParty', 'subtitleSomeParty');
							case 90:
								FlxTween.tween(camFollow, {x: 500, y: 420}, 0.9, {
									ease: FlxEase.quadInOut,
								});
								FlxTween.tween(FlxG.camera, {zoom: 1.0}, 1.1, {
									ease: FlxEase.quadInOut,
								});
							case 131:
								dialogueLine('dungeonCutscene/dialogue/whiteLies', 'subtitleWhiteLies');
							case 214:
								dialogueLine('dungeonCutscene/dialogue/mattersMuch', 'subtitleMattersMuch');
							case 259:
								FlxG.sound.play(Paths.sound('dungeonCutscene/clothingRustle', 'cutscenes'));
							case 278:
								FlxG.sound.play(Paths.sound('dungeonCutscene/step', 'cutscenes'));
							case 319:
								camFollow.x = 1010;
								camFollow.y = 560;
								FlxG.camera.zoom = 1.15;
							case 362:
								FlxTween.tween(camFollow, {x: 900}, 0.75, {
									ease: FlxEase.quadInOut,
								});
							case 366:
								FlxG.sound.play(Paths.sound('dungeonCutscene/bfSearchPocket', 'cutscenes'));
							case 374:
								FlxG.sound.play(Paths.sound('dungeonCutscene/step', 'cutscenes'));
							case 392:
								FlxG.sound.play(Paths.sound('dungeonCutscene/gfLeap', 'cutscenes'));
								FlxTween.tween(camFollow, {y: 460}, 0.9, {
									ease: FlxEase.quadInOut,
								});
							case 409:
								FlxG.sound.play(Paths.sound('dungeonCutscene/gfLand', 'cutscenes'));
							case 444:
								dialogueLine('dungeonCutscene/dialogue/howCourteous', 'subtitleHowCourteous');
							case 453:
								camFollow.x = 530;
								camFollow.y = 360;
								FlxG.camera.zoom = 1.0;
							case 572:
								FlxG.sound.play(Paths.sound('dungeonCutscene/speakerHit', 'cutscenes'));
							case 658:
								dialogueLine('dungeonCutscene/dialogue/doWhatYouAlways', 'subtitleDoWhatYouAlways');
							case 771:
								FlxG.sound.play(Paths.sound('dungeonCutscene/gfRummage', 'cutscenes'));
							case 825:
								FlxG.sound.play(Paths.sound('dungeonCutscene/micGrab', 'cutscenes'));
							case 829:
								dialogueLine('dungeonCutscene/dialogue/thankYouMiss', 'subtitleThankYouMiss');
						}
					case "risking-life":
						switch (animFrame)
						{
							case 23:
								FlxG.sound.play(Paths.sound('riskingLifeCutscene/micSpin', 'cutscenes'));
							case 38:
								FlxG.sound.play(Paths.sound('riskingLifeCutscene/micGrab', 'cutscenes'));
							case 81:
								dialogueLine('riskingLifeCutscene/dialogue/cheating', 'subtitleCheating');
							case 161:
								dialogueLine('riskingLifeCutscene/dialogue/yourGirlfriend', 'subtitleYourGirlfriend');
							case 203:
								FlxTween.tween(camFollow, {x: 540, y: 350}, 0.6, {
									ease: FlxEase.quadInOut,
								});
								FlxTween.tween(FlxG.camera, {zoom: 1.25}, 0.8, {
									ease: FlxEase.quadInOut,
								});
							case 370:
								camFollow.x = 970;
								camFollow.y = 500;
								FlxG.camera.focusOn(camFollow.getPosition());
							case 413:
								FlxG.sound.play(Paths.sound('riskingLifeCutscene/shrugIn', 'cutscenes'));
							case 421:
								FlxG.sound.play(Paths.sound('riskingLifeCutscene/shrugOut', 'cutscenes'));
							case 426:
								camFollow.x = 600;
								FlxG.camera.focusOn(camFollow.getPosition());
								FlxG.camera.zoom = 0.9;
							case 434:
								dialogueLine('riskingLifeCutscene/dialogue/imJoking', 'subtitleImJoking');
							case 501:
								dialogueLine('riskingLifeCutscene/dialogue/twistTheBattles', 'subtitleTwistTheBattles');
							case 601:
								FlxTween.tween(camFollow, {x: 730}, 0.75, {
									ease: FlxEase.quadInOut,
								});
							case 630:
								dialogueLine('riskingLifeCutscene/dialogue/letMeKnow', 'subtitleLetMeKnow');
						}
					case "vengeance":
						if (cutsceneStatus == 1)
						{
							switch (animFrame)
							{
								case 17:
									dialogueLine('vengeanceCutscene/dialogue/myTheory', 'subtitleMyTheory');
								case 18 | 54 | 90 | 126 | 162 | 198 | 234 | 270 | 306 | 342:
									FlxG.sound.play(Paths.sound('vengeanceCutscene/bloodDrip', 'cutscenes'), 0.3);
								case 117:
									FlxTween.tween(camFollow, {x: 525, y: 355}, 0.9, {
										ease: FlxEase.quadInOut,
									});
									FlxTween.tween(FlxG.camera, {zoom: 1.15}, 1.2, {
										ease: FlxEase.quadInOut,
									});
								case 122:
									dialogueLine('vengeanceCutscene/dialogue/pushedTooHard', 'subtitlePushedTooHard');
								case 180:
									FlxG.sound.play(Paths.sound('vengeanceCutscene/handSlideOver', 'cutscenes'));
								case 268:
									camFollow.x = 985;
									camFollow.y = 465;
								case 289:
									FlxG.sound.play(Paths.sound('vengeanceCutscene/jumpOffSpeakers', 'cutscenes'));
								case 294:
									FlxTween.tween(camFollow, {y: 380}, 0.33, {
										ease: FlxEase.quadInOut,
										onComplete: function(twn:FlxTween)
										{
											FlxTween.tween(camFollow, {y: 585}, 0.5, {
												ease: FlxEase.quadInOut
											});
										}
									});
								case 313:
									FlxG.sound.play(Paths.sound('vengeanceCutscene/landFromJump', 'cutscenes'));
								case 340:
									bloodGarglingLoop.fadeOut(0.5);
								case 348:
									dialogueLine('vengeanceCutscene/dialogue/theSupernatural', 'subtitleTheSupernatural');
								case 351:
									FlxTween.tween(camFollow, {x: 1065}, 2.5, {
										ease: FlxEase.quadInOut,
									});
								case 365 | 381 | 393 | 411:
									FlxG.sound.play(Paths.soundRandom('vengeanceCutscene/step', 1, 5, 'cutscenes'));
								case 430:
									FlxG.sound.play(Paths.sound('vengeanceCutscene/kneesWeak', 'cutscenes'));
								case 504:
									dialogueLine('vengeanceCutscene/dialogue/illogicalNature', 'subtitleIllogicalNature');
								case 639:
									dialogueLine('vengeanceCutscene/dialogue/itsYouIsntIt', 'subtitleItsYouIsntIt');
									camFollow.x = 580;
									camFollow.y = 550;
									FlxG.camera.zoom = 1;
								case 785:
									camFollow.x = 1080;
									camFollow.y = 610;
									FlxG.camera.zoom = 1.2;
								case 830:
									FlxG.sound.play(Paths.sound('vengeanceCutscene/getUp', 'cutscenes'));
								case 842:
									FlxG.sound.play(Paths.sound('vengeanceCutscene/eyeShine', 'cutscenes'));
								case 846:
									GirlfriendOverlay.visible = true;
									GirlfriendOverlay.alpha = 0;
									FlxTween.tween(GirlfriendOverlay, {alpha: 1}, 5);
								case 850:
									dialogueLine('vengeanceCutscene/dialogue/missHimAlready', 'subtitleMissHimAlready');
								case 859:
									FlxTween.tween(camFollow, {x: 730, y: 500}, 1.45, {
										ease: FlxEase.quadInOut,
									});
									FlxTween.tween(FlxG.camera, {zoom: 0.9}, 1.5, {
										ease: FlxEase.quadInOut,
									});
								case 949:
									dialogueLine('vengeanceCutscene/dialogue/nervesOfSteel', 'subtitleNervesOfSteel');
								case 999:
									FlxTween.tween(camFollow, {x: 770, y: 490}, 2.7, {
										ease: FlxEase.quadInOut,
									});
									FlxTween.tween(FlxG.camera, {zoom: 1}, 2.4, {
										ease: FlxEase.quadInOut,
									});
								case 1010:
									FlxG.sound.play(Paths.sound('vengeanceCutscene/wallsCracking', 'cutscenes'));
								case 1015:
									vengLabCracks.animation.play('crack', true);
								case 1018:
									FlxG.camera.shake(0.025, 0.3);
								case 1039:
									remove(GirlfriendOverlay);
								case 1040:
									FlxG.sound.play(Paths.sound('vengeanceCutscene/raiseTheRoof', 'cutscenes'));
									vengLab.swagBacks["back"].visible = false;
									remove(vengLabCracks);
									FlxTween.tween(vengLabTop, {y: vengLabTop.y - 80}, 0.3, {
										ease: FlxEase.quadIn,
										onComplete: function(twn:FlxTween)
										{
											FlxG.camera.shake(0.02, 0.15);
											FlxTween.tween(vengLabTop, {y: vengLabTop.y - 1500}, 0.8, {
												ease: FlxEase.quadIn
											});
										}
									});
								case 1042:
									camCutsceneHUD.fade(FlxColor.WHITE);
									new FlxTimer().start(3, function(tmr:FlxTimer)
									{
										for (i in vengLab.toAdd)
											remove(i);
										remove(vengLabTop);
										remove(vengLabBottom);

										camFollow.x = Stage.stageJson.camPos[0];
										camFollow.y = Stage.stageJson.camPos[1];
										FlxG.camera.zoom = Stage.stageJson.camZoom + 0.2;
										FlxTween.tween(FlxG.camera, {zoom: Stage.stageJson.camZoom}, 2.5, {
											ease: FlxEase.quadOut,
										});

										Stage.swagBacks['DeadBoyfriend'].x -= 200;
										FlxTween.tween(Stage.swagBacks['DeadBoyfriend'], {x: Stage.swagBacks['DeadBoyfriend'].x + 200}, 1, {
											ease: FlxEase.quadOut,
										});

										camCutsceneHUD.fade(FlxColor.WHITE, 3, true);
									});
							}
						}
						else
						{
							switch (animFrame)
							{
								case 40:
									FlxG.camera.focusOn(camFollow.getPosition());
									FlxG.camera.follow(camFollow, LOCKON, 1);
									FlxTween.tween(camFollow, {x: 300, y: 420}, 5.416, {
										ease: FlxEase.quadInOut,
									});
									FlxTween.tween(FlxG.camera, {zoom: 1}, 5.416, {
										ease: FlxEase.quadInOut,
									});
								case 78:
									dialogueLine('vengeanceClosingCutscene/dialogue/suchIntensity', 'subtitleSuchIntensity');
								case 175:
									FlxG.sound.play(Paths.sound('vengeanceClosingCutscene/onGround', 'cutscenes'));
								case 193:
									dialogueLine('vengeanceClosingCutscene/dialogue/yourLungs', 'subtitleYourLungs');
								case 230:
									FlxG.sound.play(Paths.sound('vengeanceClosingCutscene/micThrown', 'cutscenes'));
								case 236:
									FlxG.sound.play(Paths.sound('vengeanceClosingCutscene/micHitsAntimus', 'cutscenes'));
									dialogueLine('vengeanceClosingCutscene/dialogue/ahFuck', 'subtitleAhFuck');
									FlxG.camera.shake(0.01, 0.075);
								case 260:
									FlxG.sound.play(Paths.sound('vengeanceClosingCutscene/micHitsGround', 'cutscenes'));
								case 305:
									remove(boyfriendEyeTrail);
									remove(boyfriend);
									remove(boyfriend.eyeglow);
									Stage.swagBacks['DeadBoyfriend'].alpha = 0;
									GirlfriendBody.alpha = 1;
									GirlfriendFace.alpha = 1;
								case 310:
									camFollow.x = 1340;
									camFollow.y = 560;
								case 350:
									FlxTween.tween(camFollow, {x: 1520}, 1, {
										ease: FlxEase.quadInOut,
									});
								case 385:
									FlxTween.tween(camFollow, {y: 640}, 3, {
										ease: FlxEase.quadInOut,
									});
									FlxTween.tween(FlxG.camera, {zoom: 1.25}, 3, {
										ease: FlxEase.quadInOut,
									});
								case 387:
									FlxG.sound.play(Paths.sound('vengeanceClosingCutscene/leanDownFoley', 'cutscenes'));
									FlxG.sound.play(Paths.sound('vengeanceClosingCutscene/handOnChin', 'cutscenes'));
								case 397:
									FlxG.sound.play(Paths.sound('vengeanceClosingCutscene/leanDownStep', 'cutscenes'));
							}
						}
					case "revival":
						if (cutsceneStatus == 1)
						{
							switch (animFrame)
							{
								case 41:
									FlxG.sound.play(Paths.sound('revivalCutscene/grabSpellbook', 'cutscenes'));
								case 65:
										FlxTween.tween(camFollow, {x: 785}, 2.208, {
											ease: FlxEase.quadInOut,
										});
								case 71 | 87 | 103 | 117:
									FlxG.sound.play(Paths.soundRandom('revivalCutscene/step', 1, 5, 'cutscenes'));
								case 134:
									FlxG.sound.play(Paths.sound('revivalCutscene/lookAtSpellbook', 'cutscenes'));
								case 145:
										FlxTween.tween(camFollow, {x: 905, y: 490}, 1.416, {
											ease: FlxEase.quadInOut,
										});
										FlxTween.tween(FlxG.camera, {zoom: Stage.stageJson.camZoom}, 1.416, {
											ease: FlxEase.quadOut,
										});
								case 191:
									FlxG.sound.play(Paths.sound('revivalCutscene/tossSpellbook', 'cutscenes'));
								case 200:
									FlxG.sound.play(Paths.sound('revivalCutscene/spellbookLand', 'cutscenes'));
									Stage.swagBacks['spellbook'].alpha = 1;
									Stage.swagBacks['spellbook'].animation.play("spin");
							}
						}
						else
						{
							switch (animFrame)
							{
								case 29:
									FlxG.camera.focusOn(camFollow.getPosition());
									FlxG.camera.follow(camFollow, LOCKON, 1);
									FlxTween.tween(camFollow, {x: 695, y: 500}, 2.916, {
										ease: FlxEase.quadInOut,
									});
									FlxTween.tween(FlxG.camera, {zoom: 1.25}, 2.916, {
										ease: FlxEase.quadInOut,
									});
								case 102:
									FlxG.sound.play(Paths.sound('revivalClosingCutscene/jumpToHug', 'cutscenes'));
								case 105:
									FlxTween.tween(camFollow, {x: 575}, 0.33, {
										ease: FlxEase.quadInOut,
									});
								case 171:
									FlxG.sound.play(Paths.sound('revivalClosingCutscene/grabHair', 'cutscenes'));
							}
						}
				}
			}
			animFramePrev = animFrame;

			if (cutsceneStatus == 1)
			{
				if (SONG.songId == "revival")
				{
					if (GirlfriendBody.animation.curAnim.finished)
					{
						remove(GirlfriendBody);
						remove(GirlfriendFace);
						boyfriend.alpha = 1;
					}
				}
				else
				{
					if (AntimusBody.animation.curAnim.finished)
					{
						remove(AntimusBody);
						remove(AntimusFace);
						dad.alpha = 1;
					}

					if (GirlfriendBody.animation.curAnim.finished)
					{
						remove(GirlfriendBody);
						remove(GirlfriendFace);
						remove(speakers);
						gf.alpha = 1;
					}

					if (BoyfriendBody.animation.curAnim.finished)
					{
						remove(BoyfriendBody);
						remove(BoyfriendFace);
						boyfriend.alpha = 1;
					}
				}
			}
			else if (SONG.songId == "revival")
			{
				if (GirlfriendBody.animation.curAnim.finished)
				{
					remove(GirlfriendBody);
					remove(GirlfriendFace);
				}
			}
		}

		if (!addedBotplay && FlxG.save.data.botplay && isBotplayAllowed())
		{
			PlayStateChangeables.botPlay = true;
			addedBotplay = true;
			add(botPlayState);
		}

		if (unspawnNotes[0] != null)
		{
			if (unspawnNotes[0].strumTime - Conductor.songPosition < 14000 * songMultiplier)
			{
				var dunceNote:Note = unspawnNotes[0];
				notes.add(dunceNote);

				#if FEATURE_LUAMODCHART
				if (executeModchart)
				{
					new LuaNote(dunceNote, currentLuaIndex);
					dunceNote.luaID = currentLuaIndex;
				}
				#end

				if (executeModchart)
				{
					#if FEATURE_LUAMODCHART
					if (!dunceNote.isSustainNote)
						dunceNote.cameras = [camNotes];
					else
						dunceNote.cameras = [camSustains];
					#end
				}
				else
				{
					dunceNote.cameras = [camHUD];
				}

				var index:Int = unspawnNotes.indexOf(dunceNote);
				unspawnNotes.splice(index, 1);
				currentLuaIndex++;
			}
		}

		#if cpp
		if (FlxG.sound.music.playing)
			@:privateAccess
		{
			lime.media.openal.AL.sourcef(FlxG.sound.music._channel.__source.__backend.handle, lime.media.openal.AL.PITCH, songMultiplier);
			if (vocals.playing)
				lime.media.openal.AL.sourcef(vocals._channel.__source.__backend.handle, lime.media.openal.AL.PITCH, songMultiplier);
		}
		#end

		if (generatedMusic)
		{
			if (songStarted && !endingSong)
			{
				if (health != healthGraphInfo[healthGraphInfo.length - 1][1])
				{
					healthGraphInfo.push( [Conductor.songPosition, health] );
				}

				// Song ends abruptly on slow rate even with second condition being deleted,
				// and if it's deleted on songs like cocoa then it would end without finishing instrumental fully,
				// so no reason to delete it at all
				if (unspawnNotes.length == 0 && notes.length == 0 && FlxG.sound.music.time > FlxG.sound.music.length - 100)
				{
					Debug.logTrace("we're fuckin ending the song ");

					endingSong = true;
					healthGraphInfo.push( [Conductor.songPosition, health] );
					endSong();
				}
			}
		}

		if (updateFrame == 4)
		{
			TimingStruct.clearTimings();

			var currentIndex = 0;
			for (i in SONG.eventObjects)
			{
				if (i.type == "BPM Change")
				{
					var beat:Float = i.position;

					var endBeat:Float = Math.POSITIVE_INFINITY;

					var bpm = i.value * songMultiplier;

					TimingStruct.addTiming(beat, bpm, endBeat, 0); // offset in this case = start time since we don't have a offset

					if (currentIndex != 0)
					{
						var data = TimingStruct.AllTimings[currentIndex - 1];
						data.endBeat = beat;
						data.length = ((data.endBeat - data.startBeat) / (data.bpm / 60)) / songMultiplier;
						var step = ((60 / data.bpm) * 1000) / 4;
						TimingStruct.AllTimings[currentIndex].startStep = Math.floor((((data.endBeat / (data.bpm / 60)) * 1000) / step) / songMultiplier);
						TimingStruct.AllTimings[currentIndex].startTime = data.startTime + data.length / songMultiplier;
					}

					currentIndex++;
				}
			}

			updateFrame++;
		}
		else if (updateFrame != 5)
			updateFrame++;

		if (FlxG.sound.music.playing)
		{
			var timingSeg = TimingStruct.getTimingAtBeat(curDecimalBeat);

			if (timingSeg != null)
			{
				var timingSegBpm = timingSeg.bpm;

				if (timingSegBpm != Conductor.bpm)
				{
					trace("BPM CHANGE to " + timingSegBpm);
					Conductor.changeBPM(timingSegBpm, false);
					Conductor.crochet = ((60 / (timingSegBpm) * 1000)) / songMultiplier;
					Conductor.stepCrochet = Conductor.crochet / 4;
				}
			}

			var newScroll = 1.0;

			for (i in SONG.eventObjects)
			{
				switch (i.type)
				{
					case "Scroll Speed Change":
						if (i.position <= curDecimalBeat && !pastScrollChanges.contains(i))
						{
							pastScrollChanges.push(i);
							trace("SCROLL SPEED CHANGE to " + i.value);
							newScroll = i.value;
						}
				}
			}

			if (newScroll != 0)
				PlayStateChangeables.scrollSpeed *= newScroll;
		}

		if (PlayStateChangeables.botPlay && FlxG.keys.justPressed.ONE)
			camHUD.visible = !camHUD.visible;

		camRatings.visible = camHUD.visible;
		camRatings.zoom = camHUD.zoom;
		camRatings.x = camHUD.x;
		camRatings.y = camHUD.y;
		camRatings.angle = camHUD.angle;

		#if FEATURE_LUAMODCHART
		if (executeModchart && luaModchart != null && songStarted)
		{
			luaModchart.setVar('songPos', Conductor.songPosition);
			luaModchart.setVar('hudZoom', camHUD.zoom);
			luaModchart.setVar('curBeat', HelperFunctions.truncateFloat(curDecimalBeat, 3));
			luaModchart.setVar('cameraZoom', FlxG.camera.zoom);

			luaModchart.executeState('update', [elapsed]);

			for (key => value in luaModchart.luaWiggles)
			{
				trace('wiggle le gaming');
				value.update(elapsed);
			}

			PlayStateChangeables.useDownscroll = luaModchart.getVar("downscroll", "bool");

			/*for (i in 0...strumLineNotes.length) {
				var member = strumLineNotes.members[i];
				member.x = luaModchart.getVar("strum" + i + "X", "float");
				member.y = luaModchart.getVar("strum" + i + "Y", "float");
				member.angle = luaModchart.getVar("strum" + i + "Angle", "float");
			}*/

			FlxG.camera.angle = luaModchart.getVar('cameraAngle', 'float');
			camHUD.angle = luaModchart.getVar('camHudAngle', 'float');

			if (luaModchart.getVar("showOnlyStrums", 'bool'))
			{
				healthBarBG.visible = false;
				kadeEngineWatermark.visible = false;
				healthBar.visible = false;
				iconP1.visible = false;
				iconP2.visible = false;
				scoreTxt.visible = false;
			}
			else
			{
				healthBarBG.visible = true;
				kadeEngineWatermark.visible = true;
				healthBar.visible = true;
				iconP1.visible = true;
				iconP2.visible = true;
				scoreTxt.visible = true;
			}

			var p1 = luaModchart.getVar("strumLine1Visible", 'bool');
			var p2 = luaModchart.getVar("strumLine2Visible", 'bool');

			for (i in 0...4)
			{
				strumLineNotes.members[i].visible = p1;
				if (i <= playerStrums.length)
					playerStrums.members[i].visible = p2;
			}

			camNotes.zoom = camHUD.zoom;
			camNotes.x = camHUD.x;
			camNotes.y = camHUD.y;
			camNotes.angle = camHUD.angle;
			camSustains.zoom = camHUD.zoom;
			camSustains.x = camHUD.x;
			camSustains.y = camHUD.y;
			camSustains.angle = camHUD.angle;
		}
		#end

		// reverse iterate to remove oldest notes first and not invalidate the iteration
		// stop iteration as soon as a note is not removed
		// all notes should be kept in the correct order and this is optimal, safe to do every frame/update
		{
			var balls = notesHitArray.length - 1;
			while (balls >= 0)
			{
				var cock:Date = notesHitArray[balls];
				if (cock != null && cock.getTime() + 1000 < Date.now().getTime())
					notesHitArray.remove(cock);
				else
					balls = 0;
				balls--;
			}
			nps = notesHitArray.length;
			if (nps > maxNPS)
				maxNPS = nps;
		}

		scoreTxt.screenCenter(X);

		var pauseBind = FlxKey.fromString(FlxG.save.data.pauseBind);
		var gppauseBind = FlxKey.fromString(FlxG.save.data.gppauseBind);

		if ((FlxG.keys.anyJustPressed([pauseBind]) || KeyBinds.gamepad && FlxG.keys.anyJustPressed([gppauseBind]))
			&& startedCountdown
			&& canPause
			&& !cannotDie)
		{
			persistentUpdate = false;
			persistentDraw = true;
			paused = true;

			// 1 / 1000 chance for Gitaroo Man easter egg
			if (FlxG.random.bool(0.1))
			{
				trace('GITAROO MAN EASTER EGG');
				FlxG.switchState(new GitarooPause(SONG.player1));
				clean();
			}
			else
				openSubState(new PauseSubState());
		}

		/*if (FlxG.keys.justPressed.FIVE && songStarted)
		{
			songMultiplier = 1;
			cannotDie = true;

			FlxG.switchState(new WaveformTestState());
			clean();
			PlayState.stageTesting = false;
			FlxG.stage.removeEventListener(KeyboardEvent.KEY_DOWN, handleInput);
			FlxG.stage.removeEventListener(KeyboardEvent.KEY_UP, releaseInput);
			#if FEATURE_LUAMODCHART
			if (luaModchart != null)
			{
				luaModchart.die();
				luaModchart = null;
			}
			#end
		}*/

		var editorBind:FlxKey = FlxKey.fromString(FlxG.save.data.editorBind);
		if (FlxG.keys.anyJustPressed([editorBind]) && songStarted && !isSM && !isStoryMode && (SONG.songId != "claw-marks" || FlxG.save.data.antimusProgress[4] > 1))
		{
			songMultiplier = 1;
			cannotDie = true;

			FlxG.switchState(new ChartingState());
			clean();
			PlayState.stageTesting = false;
			FlxG.stage.removeEventListener(KeyboardEvent.KEY_DOWN, handleInput);
			FlxG.stage.removeEventListener(KeyboardEvent.KEY_UP, releaseInput);
			#if FEATURE_LUAMODCHART
			if (luaModchart != null)
			{
				luaModchart.die();
				luaModchart = null;
			}
			#end
		}

		// FlxG.watch.addQuick('VOL', vocals.amplitudeLeft);
		// FlxG.watch.addQuick('VOLRight', vocals.amplitudeRight);

		iconP1.setGraphicSize(Std.int(FlxMath.lerp(150, iconP1.width, 0.50)));
		iconP2.setGraphicSize(Std.int(FlxMath.lerp(150, iconP2.width, 0.50)));

		iconP1.updateHitbox();
		iconP2.updateHitbox();

		var iconOffset:Int = 26;

		iconP1.x = healthBar.x + (healthBar.width * (FlxMath.remapToRange(healthBar.percent, 0, 100, 100, 0) * 0.01) - iconOffset);
		iconP2.x = healthBar.x + (healthBar.width * (FlxMath.remapToRange(healthBar.percent, 0, 100, 100, 0) * 0.01)) - (iconP2.width - iconOffset);

		if (health > 2)
			health = 2;
		if (healthBar.percent < 20)
			iconP1.animation.curAnim.curFrame = 1;
		else
			iconP1.animation.curAnim.curFrame = 0;

		if (healthBar.percent > 80)
			iconP2.animation.curAnim.curFrame = 1;
		else
			iconP2.animation.curAnim.curFrame = 0;

		/* if (FlxG.keys.justPressed.NINE)
			FlxG.switchState(new Charting()); */

		#if debug
		if (FlxG.keys.justPressed.SIX)
		{
			FlxG.switchState(new AnimationDebug(dad.curCharacter));
			clean();
			PlayState.stageTesting = false;
			FlxG.stage.removeEventListener(KeyboardEvent.KEY_DOWN, handleInput);
			FlxG.stage.removeEventListener(KeyboardEvent.KEY_UP, releaseInput);
			#if FEATURE_LUAMODCHART
			if (luaModchart != null)
			{
				luaModchart.die();
				luaModchart = null;
			}
			#end
		}

		if (FlxG.keys.justPressed.EIGHT && songStarted)
		{
			paused = true;
			new FlxTimer().start(0.3, function(tmr:FlxTimer)
			{
				for (bg in Stage.toAdd)
				{
					remove(bg);
				}
				for (array in Stage.layInFront)
				{
					for (bg in array)
						remove(bg);
				}
				for (group in Stage.swagGroup)
				{
					remove(group);
				}
				remove(boyfriend);
				remove(dad);
				remove(gf);
			});
			FlxG.switchState(new StageDebugState(Stage.curStage, gf.curCharacter, boyfriend.curCharacter, dad.curCharacter));
			clean();
			FlxG.stage.removeEventListener(KeyboardEvent.KEY_DOWN, handleInput);
			FlxG.stage.removeEventListener(KeyboardEvent.KEY_UP, releaseInput);
			#if FEATURE_LUAMODCHART
			if (luaModchart != null)
			{
				luaModchart.die();
				luaModchart = null;
			}
			#end
		}

		if (FlxG.keys.justPressed.ZERO)
		{
			FlxG.switchState(new AnimationDebug(boyfriend.curCharacter));
			clean();
			PlayState.stageTesting = false;
			FlxG.stage.removeEventListener(KeyboardEvent.KEY_DOWN, handleInput);
			FlxG.stage.removeEventListener(KeyboardEvent.KEY_UP, releaseInput);
			#if FEATURE_LUAMODCHART
			if (luaModchart != null)
			{
				luaModchart.die();
				luaModchart = null;
			}
			#end
		}

		if (FlxG.keys.justPressed.TWO && songStarted)
		{ // Go 10 seconds into the future, credit: Shadow Mario#9396
			if (!usedTimeTravel && Conductor.songPosition + 10000 < FlxG.sound.music.length)
			{
				usedTimeTravel = true;
				FlxG.sound.music.pause();
				vocals.pause();
				Conductor.songPosition += 10000;
				notes.forEachAlive(function(daNote:Note)
				{
					if (daNote.strumTime - 500 < Conductor.songPosition)
					{
						daNote.active = false;
						daNote.visible = false;

						daNote.kill();
						notes.remove(daNote, true);
						daNote.destroy();
					}
				});

				FlxG.sound.music.time = Conductor.songPosition;
				FlxG.sound.music.play();

				vocals.time = Conductor.songPosition;
				vocals.play();
				new FlxTimer().start(0.5, function(tmr:FlxTimer)
				{
					usedTimeTravel = false;
				});
			}
		}
		#end

		if (skipActive && Conductor.songPosition >= skipTo)
		{
			remove(skipText);
			skipActive = false;
		}

		if (FlxG.keys.justPressed.SPACE && skipActive)
		{
			FlxG.sound.music.pause();
			vocals.pause();
			Conductor.songPosition = skipTo;
			Conductor.rawPosition = skipTo;

			FlxG.sound.music.time = Conductor.songPosition;
			FlxG.sound.music.play();

			vocals.time = Conductor.songPosition;
			vocals.play();
			FlxTween.tween(skipText, {alpha: 0}, 0.2, {
				onComplete: function(tw)
				{
					remove(skipText);
				}
			});
			skipActive = false;
		}

		if (startingSong)
		{
			if (startedCountdown)
			{
				Conductor.songPosition += FlxG.elapsed * 1000;
				Conductor.rawPosition = Conductor.songPosition;
				if (Conductor.songPosition >= 0)
					startSong();
			}
		}
		else if (!inCutscene)
		{
			// Conductor.songPosition = FlxG.sound.music.time;
			Conductor.songPosition += FlxG.elapsed * 1000;
			Conductor.rawPosition = FlxG.sound.music.time;
			/*@:privateAccess
				{
					FlxG.sound.music._channel.
			}*/
			songPositionBar = (Conductor.songPosition - songLength) / 1000;

			currentSection = getSectionByTime(Conductor.songPosition);

			if (!paused)
			{
				songTime += FlxG.game.ticks - previousFrameTime;
				previousFrameTime = FlxG.game.ticks;

				// Interpolation type beat
				if (Conductor.lastSongPos != Conductor.songPosition)
				{
					songTime = (songTime + Conductor.songPosition) / 2;
					Conductor.lastSongPos = Conductor.songPosition;
					// Conductor.songPosition += FlxG.elapsed * 1000;
					// trace('MISSED FRAME');
				}

				var curTime:Float = FlxG.sound.music.time / songMultiplier;
				if (curTime < 0)
					curTime = 0;

				var secondsTotal:Int = Math.floor(((curTime - songLength) / 1000));
				if (secondsTotal < 0)
					secondsTotal = 0;

				if (FlxG.save.data.songPosition && !endingSong)			// Without the endingSong check, the position bar shows the name of the next song before that song is fully loaded
					songName.text = CoolUtil.translate(SONG.songId) + ' (' + FlxStringUtil.formatTime((songLength - secondsTotal), false) + ')';
			}

			// Conductor.lastSongPos = FlxG.sound.music.time;
		}

		if (generatedMusic && currentSection != null && !inCutscene && !forcedCamPosition)
		{
			#if FEATURE_LUAMODCHART
			if (luaModchart != null)
				luaModchart.setVar("mustHit", currentSection.mustHitSection);
			#end

			if (camFollow.x != dad.getMidpoint().x + 150 && !currentSection.mustHitSection)
			{
				var offsetX = 0;
				var offsetY = 0;
				#if FEATURE_LUAMODCHART
				if (luaModchart != null)
				{
					offsetX = luaModchart.getVar("followXOffset", "float");
					offsetY = luaModchart.getVar("followYOffset", "float");
				}
				#end
				camFollow.setPosition(dad.getMidpoint().x + dad.cameraPosition[0] + offsetX, dad.getMidpoint().y + dad.cameraPosition[1] + offsetY);
				#if FEATURE_LUAMODCHART
				if (luaModchart != null)
					luaModchart.executeState('playerTwoTurn', []);
				#end
			}

			if (currentSection.mustHitSection && camFollow.x != boyfriend.getMidpoint().x - 100)
			{
				var offsetX = 0;
				var offsetY = 0;
				#if FEATURE_LUAMODCHART
				if (luaModchart != null)
				{
					offsetX = luaModchart.getVar("followXOffset", "float");
					offsetY = luaModchart.getVar("followYOffset", "float");
				}
				#end
				camFollow.setPosition(boyfriend.getMidpoint().x - boyfriend.cameraPosition[0] + offsetX, boyfriend.getMidpoint().y + boyfriend.cameraPosition[1] + offsetY);

				#if FEATURE_LUAMODCHART
				if (luaModchart != null)
					luaModchart.executeState('playerOneTurn', []);
				#end
			}
		}

		if (camZooming && Conductor.bpm < 320 && cutsceneStatus <= 0)
		{
			if (Conductor.bpm > 320) // if we don't do this it'll be really annoying
			{
				camZooming = false;
			}

			if (FlxG.save.data.zoom < 0.8)
				FlxG.save.data.zoom = 0.8;

			if (FlxG.save.data.zoom > 1.2)
				FlxG.save.data.zoom = 1.2;

			if (!executeModchart)
			{
				FlxG.camera.zoom = FlxMath.lerp(Stage.camZoom, FlxG.camera.zoom, 0.95);
				camHUD.zoom = FlxMath.lerp(FlxG.save.data.zoom, camHUD.zoom, 0.95);

				camRatings.zoom = camHUD.zoom;
				camNotes.zoom = camHUD.zoom;
				camSustains.zoom = camHUD.zoom;
			}
			else
			{
				FlxG.camera.zoom = FlxMath.lerp(Stage.camZoom, FlxG.camera.zoom, 0.95);
				camHUD.zoom = FlxMath.lerp(1, camHUD.zoom, 0.95);

				camRatings.zoom = camHUD.zoom;
				camNotes.zoom = camHUD.zoom;
				camSustains.zoom = camHUD.zoom;
			}
		}

		FlxG.watch.addQuick("curBPM", Conductor.bpm);
		FlxG.watch.addQuick("beatShit", curBeat);
		FlxG.watch.addQuick("stepShit", curStep);

		if (health <= 0 && !cannotDie)
		{
			if (healthLimiter)
				health = 0.01;
			else if (!usedTimeTravel)
			{
				boyfriend.stunned = true;

				persistentUpdate = false;
				persistentDraw = false;
				paused = true;

				vocals.stop();
				FlxG.sound.music.stop();

				if (FlxG.save.data.InstantRespawn)
				{
					FlxG.switchState(new PlayState());
				}
				else
				{
					openSubState(new GameOverSubstate(boyfriend.getScreenPosition().x, boyfriend.getScreenPosition().y));
				}

				#if FEATURE_DISCORD
				// Game Over doesn't get his own variable because it's only used here
				DiscordClient.changePresence("GAME OVER -- "
					+ CoolUtil.translate(SONG.songId)
					+ " ("
					+ storyDifficultyText
					+ ") "
					+ Ratings.GenerateLetterRank(accuracy),
					"\nAcc: "
					+ HelperFunctions.truncateFloat(accuracy, 2)
					+ "% | Score: "
					+ songScore
					+ " | Misses: "
					+ misses, iconRPC);
				#end
				// God i love futabu!! so fucking much (From: McChomk)
				// FlxG.switchState(new GameOverState(boyfriend.getScreenPosition().x, boyfriend.getScreenPosition().y));
			}
			else
				health = 1;
		}
		if (!inCutscene && FlxG.save.data.resetButton)
		{
			var resetBind = FlxKey.fromString(FlxG.save.data.resetBind);
			var gpresetBind = FlxKey.fromString(FlxG.save.data.gpresetBind);
			if ((FlxG.keys.anyJustPressed([resetBind]) || KeyBinds.gamepad && FlxG.keys.anyJustPressed([gpresetBind])))
			{
				boyfriend.stunned = true;

				persistentUpdate = false;
				persistentDraw = false;
				paused = true;

				vocals.stop();
				FlxG.sound.music.stop();

				if (FlxG.save.data.InstantRespawn)
				{
					FlxG.switchState(new PlayState());
				}
				else
				{
					openSubState(new GameOverSubstate(boyfriend.getScreenPosition().x, boyfriend.getScreenPosition().y));
				}

				#if FEATURE_DISCORD
				// Game Over doesn't get his own variable because it's only used here
				DiscordClient.changePresence("GAME OVER -- "
					+ CoolUtil.translate(SONG.songId)
					+ " ("
					+ storyDifficultyText
					+ ") "
					+ Ratings.GenerateLetterRank(accuracy),
					"\nAcc: "
					+ HelperFunctions.truncateFloat(accuracy, 2)
					+ "% | Score: "
					+ songScore
					+ " | Misses: "
					+ misses, iconRPC);
				#end

				// FlxG.switchState(new GameOverState(boyfriend.getScreenPosition().x, boyfriend.getScreenPosition().y));
			}
		}

		if (generatedMusic)
		{
			var holdArray:Array<Bool> = ( SONG.fiveKey ? [controls.LEFT_FIVE, controls.DOWN_FIVE, controls.CENTER, controls.UP_FIVE, controls.RIGHT_FIVE] : [controls.LEFT, controls.DOWN, controls.UP, controls.RIGHT] );
			var trueDataSuffix = ( SONG.fiveKey ? dataSuffixFiveK : dataSuffix );
			var stepHeight = (0.45 * Conductor.stepCrochet * FlxMath.roundDecimal(PlayState.SONG.speed, 2));

			notes.forEachAlive(function(daNote:Note)
			{
				// instead of doing stupid y > FlxG.height
				// we be men and actually calculate the time :)

				if (!daNote.modifiedByLua)
				{
					if (daNote.downscroll)
					{
						if (daNote.mustPress)
							daNote.y = (playerStrums.members[Math.floor(Math.abs(daNote.noteData))].y
								+
								0.45 * ((Conductor.songPosition - daNote.strumTime) / songMultiplier) * (FlxMath.roundDecimal(PlayStateChangeables.scrollSpeed == 1 ? SONG.speed : PlayStateChangeables.scrollSpeed,
									2)))
								- daNote.noteYOff;
						else
							daNote.y = (strumLineNotes.members[Math.floor(Math.abs(daNote.noteData))].y
								+
								0.45 * ((Conductor.songPosition - daNote.strumTime) / songMultiplier) * (FlxMath.roundDecimal(PlayStateChangeables.scrollSpeed == 1 ? SONG.speed : PlayStateChangeables.scrollSpeed,
									2)))
								- daNote.noteYOff;
						if (daNote.isSustainNote)
						{
							daNote.y -= daNote.height - stepHeight;

							// If not in botplay, only clip sustain notes when properly hit, botplay gets to clip it everytime
							if ((PlayStateChangeables.botPlay
								|| !daNote.mustPress
								|| daNote.wasGoodHit
								|| holdArray[Math.floor(Math.abs(daNote.noteData))])
								&& daNote.y - daNote.offset.y * daNote.scale.y + daNote.height >= (strumLine.y + Note.swagWidth / 2))
							{
								// Clip to strumline
								var swagRect = new FlxRect(0, 0, daNote.frameWidth * 2, daNote.frameHeight * 2);
								swagRect.height = (strumLineNotes.members[Math.floor(Math.abs(daNote.noteData))].y
									+ Note.swagWidth / 2
									- daNote.y) / daNote.scale.y;
								swagRect.y = daNote.frameHeight - swagRect.height;

								daNote.clipRect = swagRect;
							}
						}

						/*if (daNote.isParent)
						{
							for (i in 0...daNote.children.length)
							{
								var slide = daNote.children[i];
								slide.y = daNote.y - slide.height;
							}
						}*/
					}
					else
					{
						if (daNote.mustPress)
							daNote.y = (playerStrums.members[Math.floor(Math.abs(daNote.noteData))].y
								- 0.45 * ((Conductor.songPosition - daNote.strumTime) / songMultiplier) * (FlxMath.roundDecimal(PlayStateChangeables.scrollSpeed == 1 ? SONG.speed : PlayStateChangeables.scrollSpeed,
									2)))
								+ daNote.noteYOff;
						else
							daNote.y = (strumLineNotes.members[Math.floor(Math.abs(daNote.noteData))].y
								- 0.45 * ((Conductor.songPosition - daNote.strumTime) / songMultiplier) * (FlxMath.roundDecimal(PlayStateChangeables.scrollSpeed == 1 ? SONG.speed : PlayStateChangeables.scrollSpeed,
									2)))
								+ daNote.noteYOff;
						if (daNote.isSustainNote)
						{
							if ((PlayStateChangeables.botPlay
								|| !daNote.mustPress
								|| daNote.wasGoodHit
								|| holdArray[Math.floor(Math.abs(daNote.noteData))])
								&& daNote.y + daNote.offset.y * daNote.scale.y <= (strumLine.y + Note.swagWidth / 2))
							{
								// Clip to strumline
								var swagRect = new FlxRect(0, 0, daNote.width / daNote.scale.x, daNote.height / daNote.scale.y);
								swagRect.y = (strumLineNotes.members[Math.floor(Math.abs(daNote.noteData))].y
									+ Note.swagWidth / 2
									- daNote.y) / daNote.scale.y;
								swagRect.height -= swagRect.y;

								daNote.clipRect = swagRect;
							}
						}
					}
				}

				if (!daNote.mustPress && Conductor.songPosition >= daNote.strumTime)
				{
					if (SONG.songId != 'tutorial')
						camZooming = true;

					var altAnim:String = "";

					if (daNote.isAlt)
					{
						altAnim = '-alt';
						trace("YOO WTF THIS IS AN ALT NOTE????");
					}

					// Accessing the animation name directly to play it
					if (!daNote.isParent && daNote.parent != null)
					{
						if (daNote.spotInLine != daNote.parent.children.length - 1)
						{
							var singData:Int = Std.int(Math.abs(daNote.noteData));
							if (!daNote.isSustainNote)
								dad.playAnim('sing' + trueDataSuffix[singData] + altAnim, true);

							cpuStrums.forEach(function(spr:StaticArrow)
							{
								pressArrow(spr, spr.ID, daNote);
							});

							#if FEATURE_LUAMODCHART
							if (luaModchart != null)
								luaModchart.executeState('playerTwoSing', [Math.abs(daNote.noteData), Conductor.songPosition]);
							#end

							dad.holdTimer = 0;

							if (SONG.needsVoices)
								vocals.volume = 1;
						}
					}
					else
					{
						var singData:Int = Std.int(Math.abs(daNote.noteData));
						if (!daNote.isSustainNote)
							dad.playAnim('sing' + trueDataSuffix[singData] + altAnim, true);

						cpuStrums.forEach(function(spr:StaticArrow)
						{
							pressArrow(spr, spr.ID, daNote);
						});

						#if FEATURE_LUAMODCHART
						if (luaModchart != null)
							luaModchart.executeState('playerTwoSing', [Math.abs(daNote.noteData), Conductor.songPosition]);
						#end

						dad.holdTimer = 0;

						if (SONG.needsVoices)
							vocals.volume = 1;
					}
					daNote.active = false;

					daNote.kill();
					notes.remove(daNote, true);
					daNote.destroy();
				}

				if (daNote.mustPress && !daNote.modifiedByLua)
				{
					daNote.visible = playerStrums.members[Math.floor(Math.abs(daNote.noteData))].visible;
					daNote.x = playerStrums.members[Math.floor(Math.abs(daNote.noteData))].x;
					if (!daNote.isSustainNote)
						daNote.modAngle = playerStrums.members[Math.floor(Math.abs(daNote.noteData))].modAngle;
					if (daNote.sustainActive)
					{
						if (executeModchart)
							daNote.alpha = playerStrums.members[Math.floor(Math.abs(daNote.noteData))].alpha;
					}
					daNote.modAngle = playerStrums.members[Math.floor(Math.abs(daNote.noteData))].modAngle;
				}
				else if (!daNote.wasGoodHit && !daNote.modifiedByLua)
				{
					daNote.visible = strumLineNotes.members[Math.floor(Math.abs(daNote.noteData))].visible;
					daNote.x = strumLineNotes.members[Math.floor(Math.abs(daNote.noteData))].x;
					if (!daNote.isSustainNote)
						daNote.modAngle = strumLineNotes.members[Math.floor(Math.abs(daNote.noteData))].modAngle;
					if (daNote.sustainActive)
					{
						if (executeModchart)
							daNote.alpha = strumLineNotes.members[Math.floor(Math.abs(daNote.noteData))].alpha;
					}
					daNote.modAngle = strumLineNotes.members[Math.floor(Math.abs(daNote.noteData))].modAngle;
				}

				if (!daNote.mustPress && PlayStateChangeables.middleScroll && !executeModchart)
					daNote.alpha = 0;

				if (daNote.isSustainNote)
				{
					daNote.x += ( daNote.width / 2 + 20 ) * ( SONG.fiveKey ? 0.8 : 1 );
				}

				// trace(daNote.y);
				// WIP interpolation shit? Need to fix the pause issue
				// daNote.y = (strumLine.y - (songTime - daNote.strumTime) * (0.45 * PlayState.SONG.speed));

				if (daNote.isSustainNote && daNote.wasGoodHit && Conductor.songPosition >= daNote.strumTime)
				{
					daNote.kill();
					notes.remove(daNote, true);
					daNote.destroy();
				}
				else if ((daNote.mustPress && !daNote.downscroll || daNote.mustPress && daNote.downscroll)
					&& daNote.mustPress
					&& daNote.strumTime / songMultiplier - Conductor.songPosition / songMultiplier < -(166 * Conductor.timeScale)
					&& songStarted)
				{
					if (daNote.isSustainNote && daNote.wasGoodHit)
					{
						daNote.kill();
						notes.remove(daNote, true);
					}
					else
					{
						if (loadRep && daNote.isSustainNote)
						{
							// im tired and lazy this sucks I know i'm dumb
							if (findByTime(daNote.strumTime) != null)
								totalNotesHit += 1;
							else
							{
								vocals.volume = 0;
								if (theFunne && !daNote.isSustainNote)
								{
									noteMiss(daNote.noteData, daNote);
								}
								if (daNote.isParent)
								{
									health -= 0.15; // give a health punishment for failing a LN
									trace("hold fell over at the start");
									for (i in daNote.children)
									{
										i.alpha = 0.3;
										i.sustainActive = false;
									}
								}
								else
								{
									if (!daNote.wasGoodHit
										&& daNote.isSustainNote
										&& daNote.sustainActive
										&& daNote.spotInLine != daNote.parent.children.length)
									{
										// health -= 0.05; // give a health punishment for failing a LN
										trace("hold fell over at " + daNote.spotInLine);
										for (i in daNote.parent.children)
										{
											i.alpha = 0.3;
											i.sustainActive = false;
										}
										if (daNote.parent.wasGoodHit)
										{
											misses++;
											totalNotesHit -= 1;
										}
										updateAccuracy();
									}
									else if (!daNote.wasGoodHit && !daNote.isSustainNote)
									{
										health -= 0.15;
									}
								}
							}
						}
						else
						{
							vocals.volume = 0;
							if (theFunne && !daNote.isSustainNote)
							{
								if (PlayStateChangeables.botPlay)
								{
									daNote.rating = "bad";
									goodNoteHit(daNote);
								}
								else
									noteMiss(daNote.noteData, daNote);
							}

							if (daNote.isParent && daNote.visible)
							{
								health -= 0.15; // give a health punishment for failing a LN
								trace("hold fell over at the start");
								for (i in daNote.children)
								{
									i.alpha = 0.3;
									i.sustainActive = false;
								}
							}
							else
							{
								if (!daNote.wasGoodHit
									&& daNote.isSustainNote
									&& daNote.sustainActive
									&& daNote.spotInLine != daNote.parent.children.length)
								{
									// health -= 0.05; // give a health punishment for failing a LN
									trace("hold fell over at " + daNote.spotInLine);
									for (i in daNote.parent.children)
									{
										i.alpha = 0.3;
										i.sustainActive = false;
									}
									if (daNote.parent.wasGoodHit)
									{
										misses++;
										totalNotesHit -= 1;
									}
									updateAccuracy();
								}
								else if (!daNote.wasGoodHit && !daNote.isSustainNote)
								{
									health -= 0.15;
								}
							}
						}
					}

					daNote.visible = false;
					daNote.kill();
					notes.remove(daNote, true);
				}
			});
		}

		cpuStrums.forEach(function(spr:StaticArrow)
		{
			if (spr.animation.finished)
			{
				spr.playAnim('static');
				spr.centerOffsets();
			}
		});

		if (!inCutscene && songStarted)
			keyShit();

		super.update(elapsed);
	}

	public function getSectionByTime(ms:Float):SwagSection
	{
		for (i in SONG.notes)
		{
			var start = TimingStruct.getTimeFromBeat((TimingStruct.getBeatFromTime(i.startTime)));
			var end = TimingStruct.getTimeFromBeat((TimingStruct.getBeatFromTime(i.endTime)));

			if (ms >= start && ms < end)
			{
				return i;
			}
		}

		return null;
	}

	function recalculateAllSectionTimes()
	{
		trace("RECALCULATING SECTION TIMES");

		var currentBeat = 0;

		for (i in 0...SONG.notes.length) // loops through sections
		{
			var section = SONG.notes[i];

			var currentSeg = TimingStruct.getTimingAtBeat(currentBeat);

			if (currentSeg == null)
				return;

			var start:Float = (currentBeat - currentSeg.startBeat) / ((currentSeg.bpm) / 60);

			section.startTime = (currentSeg.startTime + start) * 1000;

			if (i != 0)
				SONG.notes[i - 1].endTime = section.startTime;
			section.endTime = Math.POSITIVE_INFINITY;

			currentBeat += Std.int(section.lengthInSteps / 4);
		}
	}

	function isBotplayAllowed():Bool
	{
		if (isStoryMode)
			return false;

		if (SONG.songId == 'claw-marks' && FlxG.save.data.antimusProgress[4] < 3)
			return false;

		return true;
	}

	var wantsToSkip:Bool = false;
	function endSong( ?isSkipping:Bool = false ):Void
	{
		unspawnNotes = [];

		while (notes.length > 0)
		{
			notes.members[0].active = false;
			notes.members[0].visible = false;

			notes.members[0].kill();
			notes.members[0].destroy();
			notes.remove(notes.members[0], true);
		}

		endingSong = true;
		FlxG.stage.removeEventListener(KeyboardEvent.KEY_DOWN, handleInput);
		FlxG.stage.removeEventListener(KeyboardEvent.KEY_UP, releaseInput);

		if (!loadRep)
			rep.SaveReplay(saveNotes, saveJudge, replayAna);
		else
		{
			PlayStateChangeables.botPlay = false;
			PlayStateChangeables.scrollSpeed = 1 / songMultiplier;
			PlayStateChangeables.useDownscroll = false;
		}

		if (FlxG.save.data.fpsCap > 290)
			(cast(Lib.current.getChildAt(0), Main)).setFPSCap(290);

		#if FEATURE_LUAMODCHART
		if (luaModchart != null)
		{
			luaModchart.die();
			luaModchart = null;
		}
		#end

		canPause = false;
		FlxG.sound.music.volume = 0;
		vocals.volume = 0;
		FlxG.sound.music.stop();
		vocals.stop();

		wantsToSkip = isSkipping;
		if (isStoryMode)
		{
			switch ( SONG.songId )
			{
				case "vengeance":
					playCutsceneVengeanceEnd();
				case "revival":
					playCutsceneRevivalEnd();
				default:
					endSongFinished(isSkipping);
			}
		}
		else
			endSongFinished(isSkipping);
	}

	function endSongFinished( ?isSkipping:Bool = false, ?noTransition:Bool = true, ?skipNextCutscene:Bool = false ):Void
	{
		if (SONG.validScore)
		{
			#if !switch
			Highscore.saveScore(PlayState.SONG.songId, Math.round(songScore), storyDifficulty);
			Highscore.saveCombo(PlayState.SONG.songId, Ratings.GenerateLetterRank(accuracy), storyDifficulty);
			#end
		}

		if (offsetTesting)
		{
			FlxG.sound.playMusic(Paths.music('freakyMenu'));
			offsetTesting = false;
			LoadingState.loadAndSwitchState(new OptionsMenu());
			clean();
			FlxG.save.data.offset = offsetTest;
		}
		else if (stageTesting)
		{
			new FlxTimer().start(0.3, function(tmr:FlxTimer)
			{
				for (bg in Stage.toAdd)
				{
					remove(bg);
				}
				for (array in Stage.layInFront)
				{
					for (bg in array)
						remove(bg);
				}
				remove(boyfriend);
				remove(dad);
				remove(gf);
			});
			FlxG.switchState(new StageDebugState(Stage.curStage));
		}
		else
		{
			if (isStoryMode)
			{
				campaignScore += Math.round(songScore);
				campaignMisses += misses;
				campaignSicks += sicks;
				campaignGoods += goods;
				campaignBads += bads;
				campaignShits += shits;

				var beatenDiff = 3;

				switch ( storyDifficulty )
				{
					case 'Easy':
						beatenDiff = 1;
					case 'Normal':
						beatenDiff = 2;
				}

				if (!isSkipping)
				{
					switch ( SONG.songId )
					{
						case 'dungeon':
							if (FlxG.save.data.antimusProgress[0] < beatenDiff)
								FlxG.save.data.antimusProgress[0] = beatenDiff;
						case 'risking-life':
							if (FlxG.save.data.antimusProgress[1] < beatenDiff)
								FlxG.save.data.antimusProgress[1] = beatenDiff;
						case 'vengeance':
							if (FlxG.save.data.antimusProgress[2] < beatenDiff)
								FlxG.save.data.antimusProgress[2] = beatenDiff;
						case 'revival':
							if (FlxG.save.data.antimusProgress[3] < beatenDiff)
								FlxG.save.data.antimusProgress[3] = beatenDiff;
					}
				}

				storyPlaylist.remove(storyPlaylist[0]);

				if (storyPlaylist.length <= 0)
				{
					transIn = FlxTransitionableState.defaultTransIn;
					transOut = FlxTransitionableState.defaultTransOut;

					paused = true;

					FlxG.sound.music.stop();
					vocals.stop();

					GameplayCustomizeState.freeplayBf = 'bf';
					GameplayCustomizeState.freeplayDad = 'antimus';
					GameplayCustomizeState.freeplayGf = 'gf';
					GameplayCustomizeState.freeplayNoteStyle = 'normal';
					GameplayCustomizeState.freeplayStage = 'lab';
					GameplayCustomizeState.freeplaySong = 'dungeon';
					GameplayCustomizeState.freeplayWeek = 0;

					if (FlxG.save.data.antimusProgress[4] < 1)
						FlxG.switchState(new StoryBeatenState());
					else
					{
						FlxG.sound.playMusic(Paths.music('freakyMenu'));
						Conductor.changeBPM(130);
						FlxG.switchState(new StoryMenuState());
					}
					clean();

					#if FEATURE_LUAMODCHART
					if (luaModchart != null)
					{
						luaModchart.die();
						luaModchart = null;
					}
					#end

					if (SONG.validScore && !PlayState.hasSkipped)
					{
						Highscore.saveWeekScore(storyWeek, campaignScore, storyDifficulty);
					}
				}
				else
				{
					var diff:String = storyDifficulty;

					Debug.logInfo('PlayState: Loading next story song ${PlayState.storyPlaylist[0]}-${diff}');

					if (noTransition)
					{
						FlxTransitionableState.skipNextTransIn = true;
						FlxTransitionableState.skipNextTransOut = true;
						prevCamFollow = camFollow;
					}

					PlayState.SONG = Song.loadFromJson(PlayState.storyPlaylist[0], diff);
					PlayState.hasPlayedCutscene = skipNextCutscene;
					FlxG.sound.music.stop();

					LoadingState.loadAndSwitchState(new PlayState());
					clean();
				}
			}
			else
			{
				trace('WENT BACK TO FREEPLAY??');

				paused = true;

				FlxG.sound.music.stop();
				vocals.stop();

				if (SONG.songId == 'claw-marks' && FlxG.save.data.antimusProgress[4] < 3)
					FlxG.save.data.antimusProgress[4] = 3;

				if (FlxG.save.data.scoreScreen)
				{
					openSubState(new ResultsScreen());
					new FlxTimer().start(1, function(tmr:FlxTimer)
					{
						inResults = true;
					});
				}
				else
				{
					FlxG.switchState(new FreeplayState());
					clean();
				}
			}
		}
	}

	public function canSkipSong():Bool
	{
		if (!isStoryMode)
			return false;

		switch ( SONG.songId )
		{
			case 'dungeon':
				if (FlxG.save.data.antimusProgress[0] > 0)
					return true;
			case 'risking-life':
				if (FlxG.save.data.antimusProgress[1] > 0)
					return true;
			case 'vengeance':
				if (FlxG.save.data.antimusProgress[2] > 0)
					return true;
			case 'revival':
				if (FlxG.save.data.antimusProgress[3] > 0)
					return true;
		}

		return false;
	}

	public function skipSong():Void
	{
		if (canSkipSong())
		{
			hasSkipped = true;
			endSong(true);
		}
	}

	public var endingSong:Bool = false;

	var hits:Array<Float> = [];
	var offsetTest:Float = 0;

	public function getRatesScore(rate:Float, score:Float):Float
	{
		var rateX:Float = 1;
		var lastScore:Float = score;
		var pr = rate - 0.05;
		if (pr < 1.00)
			pr = 1;

		while (rateX <= pr)
		{
			if (rateX > pr)
				break;
			lastScore = score + ((lastScore * rateX) * 0.022);
			rateX += 0.05;
		}

		var actualScore = Math.round(score + (Math.floor((lastScore * pr)) * 0.022));

		return actualScore;
	}

	var timeShown = 0;
	var currentTimingShown:FlxText = null;

	private function popUpScore(daNote:Note):Void
	{
		var noteDiff:Float;
		if (daNote != null)
			noteDiff = -(daNote.strumTime - Conductor.songPosition);
		else
			noteDiff = Conductor.safeZoneOffset; // Assumed SHIT if no note was given
		var wife:Float = EtternaFunctions.wife3(-noteDiff, Conductor.timeScale);
		// boyfriend.playAnim('hey');
		vocals.volume = 1;
		var placement:String = Std.string(combo);

		var coolText:FlxText = new FlxText(0, 0, 0, placement, 32);
		coolText.screenCenter();
		coolText.x = FlxG.width * 0.55;
		coolText.y -= 350;
		coolText.cameras = [camHUD];
		//

		var rating:FlxSprite = new FlxSprite();
		var score:Float = 350;

		if (FlxG.save.data.accuracyMod == 1)
			totalNotesHit += wife;

		var daRating = Ratings.judgeNote(noteDiff);

		switch (daRating)
		{
			case 'shit':
				score = -300;
				combo = 0;
				misses++;
				health -= 0.1;
				ss = false;
				shits++;
				if (FlxG.save.data.accuracyMod == 0)
					totalNotesHit -= 1;
			case 'bad':
				daRating = 'bad';
				score = 0;
				health -= 0.06;
				ss = false;
				bads++;
				if (FlxG.save.data.accuracyMod == 0)
					totalNotesHit += 0.50;
			case 'good':
				daRating = 'good';
				score = 200;
				ss = false;
				goods++;
				if (FlxG.save.data.accuracyMod == 0)
					totalNotesHit += 0.75;
			case 'sick':
				if (health < 2)
					health += 0.04;
				if (FlxG.save.data.accuracyMod == 0)
					totalNotesHit += 1;
				sicks++;
		}

		if (songMultiplier >= 1.05)
			score = getRatesScore(songMultiplier, score);

		// trace('Wife accuracy loss: ' + wife + ' | Rating: ' + daRating + ' | Score: ' + score + ' | Weight: ' + (1 - wife));

		if (daRating != 'shit' || daRating != 'bad')
		{
			songScore += Math.round(score);

			/* if (combo > 60)
					daRating = 'sick';
				else if (combo > 12)
					daRating = 'good'
				else if (combo > 4)
					daRating = 'bad';
			 */

			var pixelShitPart1:String = "";
			var pixelShitPart2:String = '';
			var pixelShitPart3:String = null;

			rating.loadGraphic(Paths.loadImage(pixelShitPart1 + daRating + pixelShitPart2, pixelShitPart3));
			rating.screenCenter();
			rating.y -= 50;
			rating.x = coolText.x - 125;

			if (FlxG.save.data.changedHit)
			{
				rating.x = FlxG.save.data.changedHitX;
				rating.y = FlxG.save.data.changedHitY;
			}
			rating.acceleration.y = 550;
			rating.velocity.y -= FlxG.random.int(140, 175);
			rating.velocity.x -= FlxG.random.int(0, 10);

			var msTiming = HelperFunctions.truncateFloat(noteDiff / songMultiplier, 3);
			if (PlayStateChangeables.botPlay && !loadRep)
				msTiming = 0;

			if (loadRep)
				msTiming = HelperFunctions.truncateFloat(findByTime(daNote.strumTime)[3], 3);

			if (currentTimingShown != null)
				remove(currentTimingShown);

			currentTimingShown = new FlxText(0, 0, 0, "0ms");
			timeShown = 0;
			switch (daRating)
			{
				case 'shit' | 'bad':
					currentTimingShown.color = FlxColor.RED;
				case 'good':
					currentTimingShown.color = FlxColor.GREEN;
				case 'sick':
					currentTimingShown.color = FlxColor.CYAN;
			}
			currentTimingShown.borderStyle = OUTLINE;
			currentTimingShown.borderSize = 1;
			currentTimingShown.borderColor = FlxColor.BLACK;
			currentTimingShown.text = msTiming + "ms";
			currentTimingShown.size = 20;

			if (msTiming >= 0.03 && offsetTesting)
			{
				// Remove Outliers
				hits.shift();
				hits.shift();
				hits.shift();
				hits.pop();
				hits.pop();
				hits.pop();
				hits.push(msTiming);

				var total = 0.0;

				for (i in hits)
					total += i;

				offsetTest = HelperFunctions.truncateFloat(total / hits.length, 2);
			}

			if (currentTimingShown.alpha != 1)
				currentTimingShown.alpha = 1;

			if (!PlayStateChangeables.botPlay || loadRep)
				add(currentTimingShown);

			var comboSpr:FlxSprite = new FlxSprite().loadGraphic(Paths.loadImage(pixelShitPart1 + 'combo' + pixelShitPart2, pixelShitPart3));
			comboSpr.screenCenter();
			comboSpr.x = rating.x;
			comboSpr.y = rating.y + 100;
			comboSpr.acceleration.y = 600;
			comboSpr.velocity.y -= 150;

			currentTimingShown.screenCenter();
			currentTimingShown.x = comboSpr.x + 100;
			currentTimingShown.y = rating.y + 100;
			currentTimingShown.acceleration.y = 600;
			currentTimingShown.velocity.y -= 150;

			comboSpr.velocity.x += FlxG.random.int(1, 10);
			currentTimingShown.velocity.x += comboSpr.velocity.x;
			if (!PlayStateChangeables.botPlay || loadRep)
				add(rating);

			rating.setGraphicSize(Std.int(rating.width * 0.7));
			rating.antialiasing = FlxG.save.data.antialiasing;
			comboSpr.setGraphicSize(Std.int(comboSpr.width * 0.7));
			comboSpr.antialiasing = FlxG.save.data.antialiasing;

			currentTimingShown.updateHitbox();
			comboSpr.updateHitbox();
			rating.updateHitbox();

			currentTimingShown.cameras = [camRatings];
			comboSpr.cameras = [camRatings];
			rating.cameras = [camRatings];

			var seperatedScore:Array<Int> = [];

			var comboSplit:Array<String> = (combo + "").split('');

			if (combo > highestCombo)
				highestCombo = combo;

			// make sure we have 3 digits to display (looks weird otherwise lol)
			if (comboSplit.length == 1)
			{
				seperatedScore.push(0);
				seperatedScore.push(0);
			}
			else if (comboSplit.length == 2)
				seperatedScore.push(0);

			for (i in 0...comboSplit.length)
			{
				var str:String = comboSplit[i];
				seperatedScore.push(Std.parseInt(str));
			}

			var daLoop:Int = 0;
			for (i in seperatedScore)
			{
				var numScore:FlxSprite = new FlxSprite().loadGraphic(Paths.loadImage(pixelShitPart1 + 'num' + Std.int(i) + pixelShitPart2, pixelShitPart3));
				numScore.screenCenter();
				numScore.x = rating.x + (43 * daLoop) - 50;
				numScore.y = rating.y + 100;
				numScore.cameras = [camRatings];

				numScore.antialiasing = FlxG.save.data.antialiasing;
				numScore.setGraphicSize(Std.int(numScore.width * 0.5));
				numScore.updateHitbox();

				numScore.acceleration.y = FlxG.random.int(200, 300);
				numScore.velocity.y -= FlxG.random.int(140, 160);
				numScore.velocity.x = FlxG.random.float(-5, 5);

				add(numScore);

				visibleCombos.push(numScore);

				FlxTween.tween(numScore, {alpha: 0}, 0.2, {
					onComplete: function(tween:FlxTween)
					{
						visibleCombos.remove(numScore);
						numScore.destroy();
					},
					onUpdate: function(tween:FlxTween)
					{
						if (!visibleCombos.contains(numScore))
						{
							tween.cancel();
							numScore.destroy();
						}
					},
					startDelay: Conductor.crochet * 0.002
				});

				if (visibleCombos.length > seperatedScore.length + 20)
				{
					for (i in 0...seperatedScore.length - 1)
					{
						visibleCombos.remove(visibleCombos[visibleCombos.length - 1]);
					}
				}

				daLoop++;
			}
			/* 
				trace(combo);
				trace(seperatedScore);
			 */

			coolText.text = Std.string(seperatedScore);
			// add(coolText);

			FlxTween.tween(rating, {alpha: 0}, 0.2, {
				startDelay: Conductor.crochet * 0.001,
				onUpdate: function(tween:FlxTween)
				{
					if (currentTimingShown != null)
						currentTimingShown.alpha -= 0.02;
					timeShown++;
				}
			});

			FlxTween.tween(comboSpr, {alpha: 0}, 0.2, {
				onComplete: function(tween:FlxTween)
				{
					coolText.destroy();
					comboSpr.destroy();
					if (currentTimingShown != null && timeShown >= 20)
					{
						remove(currentTimingShown);
						currentTimingShown = null;
					}
					rating.destroy();
				},
				startDelay: Conductor.crochet * 0.001
			});

			curSection += 1;
		}
	}

	public function NearlyEquals(value1:Float, value2:Float, unimportantDifference:Float = 10):Bool
	{
		return Math.abs(FlxMath.roundDecimal(value1, 1) - FlxMath.roundDecimal(value2, 1)) < unimportantDifference;
	}

	var upHold:Bool = false;
	var downHold:Bool = false;
	var rightHold:Bool = false;
	var leftHold:Bool = false;

	// THIS FUNCTION JUST FUCKS WIT HELD NOTES AND BOTPLAY/REPLAY (also gamepad shit)

	private function keyShit():Void // I've invested in emma stocks
	{
		// control arrays, order L D R U
		var holdArray:Array<Bool> = ( SONG.fiveKey ? [controls.LEFT_FIVE, controls.DOWN_FIVE, controls.CENTER, controls.UP_FIVE, controls.RIGHT_FIVE] : [controls.LEFT, controls.DOWN, controls.UP, controls.RIGHT] );
		var pressArray:Array<Bool> = ( SONG.fiveKey ? [controls.LEFT_FIVE_P, controls.DOWN_FIVE_P, controls.CENTER_P, controls.UP_FIVE_P, controls.RIGHT_FIVE_R] : [controls.LEFT_P, controls.DOWN_P, controls.UP_P, controls.RIGHT_R] );
		var releaseArray:Array<Bool> = ( SONG.fiveKey ? [controls.LEFT_FIVE_R, controls.DOWN_FIVE_R, controls.CENTER_R, controls.UP_FIVE_R, controls.RIGHT_FIVE_R] : [controls.LEFT_R, controls.DOWN_R, controls.UP_R, controls.RIGHT_R] );
		var keynameArray:Array<String> = ( SONG.fiveKey ? ['left_five', 'down_five', 'center', 'up_five', 'right_five'] : ['left', 'down', 'up', 'right'] );
		#if FEATURE_LUAMODCHART
		if (luaModchart != null)
		{
			for (i in 0...pressArray.length)
			{
				if (pressArray[i] == true)
				{
					luaModchart.executeState('keyPressed', [keynameArray[i]]);
				}
			};

			for (i in 0...releaseArray.length)
			{
				if (releaseArray[i] == true)
				{
					luaModchart.executeState('keyReleased', [keynameArray[i]]);
				}
			};
		};
		#end

		// Prevent player input if botplay is on
		if (PlayStateChangeables.botPlay)
		{
			holdArray = [false, false, false, false, false];
			pressArray = [false, false, false, false, false];
			releaseArray = [false, false, false, false, false];
		}

		var anas:Array<Ana> = [null, null, null, null, null];

		for (i in 0...pressArray.length)
			if (pressArray[i])
				anas[i] = new Ana(Conductor.songPosition, null, false, "miss", i);

		// HOLDS, check for sustain notes
		if (holdArray.contains(true) && /*!boyfriend.stunned && */ generatedMusic)
		{
			notes.forEachAlive(function(daNote:Note)
			{
				if (daNote.isSustainNote && daNote.canBeHit && daNote.mustPress && holdArray[daNote.noteData] && daNote.sustainActive)
				{
					goodNoteHit(daNote);
				}
			});
		}

		if ((KeyBinds.gamepad && !FlxG.keys.justPressed.ANY))
		{
			// PRESSES, check for note hits
			if (pressArray.contains(true) && generatedMusic)
			{
				boyfriend.holdTimer = 0;

				var possibleNotes:Array<Note> = []; // notes that can be hit
				var directionList:Array<Int> = []; // directions that can be hit
				var dumbNotes:Array<Note> = []; // notes to kill later
				var directionsAccounted:Array<Bool> = [false, false, false, false, false]; // we don't want to do judgments for more than one presses

				notes.forEachAlive(function(daNote:Note)
				{
					if (daNote.canBeHit && daNote.mustPress && !daNote.wasGoodHit && !directionsAccounted[daNote.noteData])
					{
						if (directionList.contains(daNote.noteData))
						{
							directionsAccounted[daNote.noteData] = true;
							for (coolNote in possibleNotes)
							{
								if (coolNote.noteData == daNote.noteData && Math.abs(daNote.strumTime - coolNote.strumTime) < 10)
								{ // if it's the same note twice at < 10ms distance, just delete it
									// EXCEPT u cant delete it in this loop cuz it fucks with the collection lol
									dumbNotes.push(daNote);
									break;
								}
								else if (coolNote.noteData == daNote.noteData && daNote.strumTime < coolNote.strumTime)
								{ // if daNote is earlier than existing note (coolNote), replace
									possibleNotes.remove(coolNote);
									possibleNotes.push(daNote);
									break;
								}
							}
						}
						else
						{
							directionsAccounted[daNote.noteData] = true;
							possibleNotes.push(daNote);
							directionList.push(daNote.noteData);
						}
					}
				});

				for (note in dumbNotes)
				{
					FlxG.log.add("killing dumb ass note at " + note.strumTime);
					note.kill();
					notes.remove(note, true);
					note.destroy();
				}

				possibleNotes.sort((a, b) -> Std.int(a.strumTime - b.strumTime));

				var hit = [false, false, false, false];

				if (perfectMode)
					goodNoteHit(possibleNotes[0]);
				else if (possibleNotes.length > 0)
				{
					for (coolNote in possibleNotes)
					{
						if (pressArray[coolNote.noteData] && !hit[coolNote.noteData])
						{
							if (mashViolations != 0)
								mashViolations--;
							hit[coolNote.noteData] = true;
							scoreTxt.color = FlxColor.WHITE;
							var noteDiff:Float = -(coolNote.strumTime - Conductor.songPosition);
							anas[coolNote.noteData].hit = true;
							anas[coolNote.noteData].hitJudge = Ratings.judgeNote(noteDiff);
							anas[coolNote.noteData].nearestNote = [coolNote.strumTime, coolNote.noteData, coolNote.sustainLength];
							goodNoteHit(coolNote);
						}
					}
				};

				if (boyfriend.holdTimer > Conductor.stepCrochet * 4 * 0.001 && (!holdArray.contains(true) || PlayStateChangeables.botPlay))
				{
					if (boyfriend.animation.curAnim.name.startsWith('sing') && !boyfriend.animation.curAnim.name.endsWith('miss'))
						boyfriend.dance();
				}
			}

			if (!loadRep)
				for (i in anas)
					if (i != null)
						replayAna.anaArray.push(i); // put em all there
		}
		if (PlayStateChangeables.botPlay)
			notes.forEachAlive(function(daNote:Note)
			{
				if (daNote.mustPress && Conductor.songPosition >= daNote.strumTime)
				{
					// Force good note hit regardless if it's too late to hit it or not as a fail safe
					if (loadRep)
					{
						// trace('ReplayNote ' + tmpRepNote.strumtime + ' | ' + tmpRepNote.direction);
						var n = findByTime(daNote.strumTime);
						trace(n);
						if (n != null)
						{
							goodNoteHit(daNote);
							boyfriend.holdTimer = 0;
						}
					}
					else
					{
						goodNoteHit(daNote);
						boyfriend.holdTimer = 0;
					}
				}
			});

		if (boyfriend.holdTimer > Conductor.stepCrochet * 4 * 0.001 && (!holdArray.contains(true) || PlayStateChangeables.botPlay))
		{
			if (boyfriend.animation.curAnim.name.startsWith('sing')
				&& !boyfriend.animation.curAnim.name.endsWith('miss'))
				boyfriend.dance();
		}

		playerStrums.forEach(function(spr:StaticArrow)
		{
			if (!PlayStateChangeables.botPlay)
			{
				if (keys[spr.ID]
					&& spr.animation.curAnim.name != 'confirm'
					&& spr.animation.curAnim.name != 'pressed'
					&& !spr.animation.curAnim.name.startsWith('dirCon'))
					spr.playAnim('pressed', false);
				if (!keys[spr.ID])
					spr.playAnim('static', false);
			}
			else
			{
				if (spr.animation.finished)
					spr.playAnim('static');
			}
		});
	}

	public function findByTime(time:Float):Array<Dynamic>
	{
		for (i in rep.replay.songNotes)
		{
			// trace('checking ' + Math.round(i[0]) + ' against ' + Math.round(time));
			if (i[0] == time)
				return i;
		}
		return null;
	}

	public function findByTimeIndex(time:Float):Int
	{
		for (i in 0...rep.replay.songNotes.length)
		{
			// trace('checking ' + Math.round(i[0]) + ' against ' + Math.round(time));
			if (rep.replay.songNotes[i][0] == time)
				return i;
		}
		return -1;
	}

	public var fuckingVolume:Float = 1;

	public var playingDathing = false;

	function noteMiss(direction:Int = 1, daNote:Note):Void
	{
		var trueDataSuffix = ( SONG.fiveKey ? dataSuffixFiveK : dataSuffix );

		if (!boyfriend.stunned)
		{
			// health -= 0.2;
			if (combo > 5 && gf.animOffsets.exists('sad'))
			{
				gf.playAnim('sad');
			}
			if (combo != 0)
			{
				combo = 0;
				popUpScore(null);
			}
			misses++;

			if (daNote != null)
			{
				if (!loadRep)
				{
					saveNotes.push([
						daNote.strumTime,
						0,
						direction,
						-(166 * Math.floor((PlayState.rep.replay.sf / 60) * 1000) / 166)
					]);
					saveJudge.push("miss");
				}
			}
			else if (!loadRep)
			{
				saveNotes.push([
					Conductor.songPosition,
					0,
					direction,
					-(166 * Math.floor((PlayState.rep.replay.sf / 60) * 1000) / 166)
				]);
				saveJudge.push("miss");
			}

			// var noteDiff:Float = Math.abs(daNote.strumTime - Conductor.songPosition);
			// var wife:Float = EtternaFunctions.wife3(noteDiff, FlxG.save.data.etternaMode ? 1 : 1.7);

			totalNotesHit -= 1;

			if (daNote != null)
			{
				if (!daNote.isSustainNote)
					songScore -= 10;
			}
			else
				songScore -= 10;

			if (FlxG.save.data.missSounds)
			{
				FlxG.sound.play(Paths.soundRandom('missnote' + altSuffix, 1, 3), FlxG.random.float(0.1, 0.2));
				// FlxG.sound.play(Paths.sound('missnote1'), 1, false);
				// FlxG.log.add('played imss note');
			}

			// Hole switch statement replaced with a single line :)
			boyfriend.playAnim('sing' + trueDataSuffix[direction] + 'miss', true);

			#if FEATURE_LUAMODCHART
			if (luaModchart != null)
				luaModchart.executeState('playerOneMiss', [direction, Conductor.songPosition]);
			#end

			updateAccuracy();
		}
	}

	function updateAccuracy()
	{
		totalPlayed += 1;
		accuracy = Math.max(0, totalNotesHit / totalPlayed * 100);
		accuracyDefault = Math.max(0, totalNotesHitDefault / totalPlayed * 100);

		scoreTxt.text = Ratings.CalculateRanking(songScore, songScoreDef, nps, maxNPS, accuracy);
		judgementCounter.text = CoolUtil.translate('judgementCounterSicks') + ' ${sicks}\n' + CoolUtil.translate('judgementCounterGoods') + ' ${goods}\n' + CoolUtil.translate('judgementCounterBads') + ' ${bads}\n' + CoolUtil.translate('judgementCounterShits') + ' ${shits}\n' + CoolUtil.translate('judgementCounterMisses') + ' ${misses}\n';
	}

	function getKeyPresses(note:Note):Int
	{
		var possibleNotes:Array<Note> = []; // copypasted but you already know that

		notes.forEachAlive(function(daNote:Note)
		{
			if (daNote.canBeHit && daNote.mustPress)
			{
				possibleNotes.push(daNote);
				possibleNotes.sort((a, b) -> Std.int(a.strumTime - b.strumTime));
			}
		});
		if (possibleNotes.length == 1)
			return possibleNotes.length + 1;
		return possibleNotes.length;
	}

	var mashing:Int = 0;
	var mashViolations:Int = 0;

	var etternaModeScore:Int = 0;

	function noteCheck(controlArray:Array<Bool>, note:Note):Void // sorry lol
	{
		var noteDiff:Float = -(note.strumTime - Conductor.songPosition);

		note.rating = Ratings.judgeNote(noteDiff);

		/* if (loadRep)
			{
				if (controlArray[note.noteData])
					goodNoteHit(note, false);
				else if (rep.replay.keyPresses.length > repPresses && !controlArray[note.noteData])
				{
					if (NearlyEquals(note.strumTime,rep.replay.keyPresses[repPresses].time, 4))
					{
						goodNoteHit(note, false);
					}
				}
		}*/

		if (controlArray[note.noteData])
		{
			goodNoteHit(note, (mashing > getKeyPresses(note)));

			/*if (mashing > getKeyPresses(note) && mashViolations <= 2)
				{
					mashViolations++;

					goodNoteHit(note, (mashing > getKeyPresses(note)));
				}
				else if (mashViolations > 2)
				{
					// this is bad but fuck you
					playerStrums.members[0].animation.play('static');
					playerStrums.members[1].animation.play('static');
					playerStrums.members[2].animation.play('static');
					playerStrums.members[3].animation.play('static');
					health -= 0.4;
					trace('mash ' + mashing);
					if (mashing != 0)
						mashing = 0;
				}
				else
					goodNoteHit(note, false); */
		}
	}

	function goodNoteHit(note:Note, resetMashViolation = true):Void
	{
		if (mashing != 0)
			mashing = 0;

		var noteDiff:Float = -(note.strumTime - Conductor.songPosition);
		var trueDataSuffix = ( SONG.fiveKey ? dataSuffixFiveK : dataSuffix );

		if (loadRep)
		{
			noteDiff = findByTime(note.strumTime)[3];
			note.rating = rep.replay.songJudgements[findByTimeIndex(note.strumTime)];
		}
		else
			note.rating = Ratings.judgeNote(noteDiff);

		if (note.rating == "miss")
			return;

		// add newest note to front of notesHitArray
		// the oldest notes are at the end and are removed first
		if (!note.isSustainNote)
			notesHitArray.unshift(Date.now());

		if (!resetMashViolation && mashViolations >= 1)
			mashViolations--;

		if (mashViolations < 0)
			mashViolations = 0;

		if (!note.wasGoodHit)
		{
			if (!note.isSustainNote)
			{
				combo += 1;
				popUpScore(note);
			}

			var altAnim:String = "";
			if (note.isAlt)
			{
				altAnim = '-alt';
				trace("Alt note on BF");
			}

			if (!note.isSustainNote)
				boyfriend.playAnim('sing' + trueDataSuffix[note.noteData] + altAnim, true);

			#if FEATURE_LUAMODCHART
			if (luaModchart != null)
				luaModchart.executeState('playerOneSing', [note.noteData, Conductor.songPosition]);
			#end

			if (!loadRep && note.mustPress)
			{
				var array = [note.strumTime, note.sustainLength, note.noteData, noteDiff];
				if (note.isSustainNote)
					array[1] = -1;
				saveNotes.push(array);
				saveJudge.push(note.rating);
			}

			playerStrums.forEach(function(spr:StaticArrow)
			{
				pressArrow(spr, spr.ID, note);
			});

			if (!note.isSustainNote)
			{
				note.kill();
				notes.remove(note, true);
				note.destroy();
			}
			else
			{
				note.wasGoodHit = true;
			}
			if (!note.isSustainNote)
				updateAccuracy();
		}
	}

	function pressArrow(spr:StaticArrow, idCheck:Int, daNote:Note)
	{
		if (Math.abs(daNote.noteData) == idCheck)
		{
			if (!FlxG.save.data.stepMania)
			{
				spr.playAnim('confirm', true);
			}
			else
			{
				spr.playAnim('dirCon' + daNote.originColor, true);
				spr.localAngle = daNote.originAngle;
			}
		}
	}

	var danced:Bool = false;

	override function stepHit()
	{
		super.stepHit();
		if (FlxG.sound.music.time > Conductor.songPosition + 20 || FlxG.sound.music.time < Conductor.songPosition - 20)
		{
			resyncVocals();
		}

		#if FEATURE_LUAMODCHART
		if (executeModchart && luaModchart != null)
		{
			luaModchart.setVar('curStep', curStep);
			luaModchart.executeState('stepHit', [curStep]);
		}
		#end

		hscriptSet('curStep', curStep);
		hscriptExec('stepHit', []);
	}

	override function beatHit()
	{
		super.beatHit();

		if (generatedMusic)
		{
			notes.sort(FlxSort.byY, (PlayStateChangeables.useDownscroll ? FlxSort.ASCENDING : FlxSort.DESCENDING));
		}

		#if FEATURE_LUAMODCHART
		if (executeModchart && luaModchart != null)
		{
			luaModchart.executeState('beatHit', [curBeat]);
		}
		#end

		hscriptSet('curBeat', curBeat);
		hscriptExec('beatHit', []);

		for (i in SONG.eventObjects)
		{
			if (Std.int(i.position) == curBeat)
			{
				if (myScripts.exists(i.type))
					myScripts.get(i.type).execFunc('eventTrigger', [i.value, i.name, i.position]);
				hscriptExec('onEventTrigger', [i.type, i.value, i.name, i.position]);
			}
		}

		if (currentSection != null)
		{
			if (curBeat % idleBeat == 0)
			{
				if (idleToBeat && !dad.animation.curAnim.name.startsWith('sing'))
					dad.dance(forcedToIdle, currentSection.CPUAltAnim);
				if (idleToBeat && !boyfriend.animation.curAnim.name.startsWith('sing'))
					boyfriend.dance(forcedToIdle, currentSection.playerAltAnim);
			}
		}
		// FlxG.log.add('change bpm' + SONG.notes[Std.int(curStep / 16)].changeBPM);
		wiggleShit.update(Conductor.crochet);

		if (FlxG.save.data.camzoom && Conductor.bpm < 340 && cutsceneStatus <= 0)
		{
			if (camZooming && FlxG.camera.zoom < 1.35 && curBeat % 4 == 0)
			{
				FlxG.camera.zoom += 0.015 / songMultiplier;
				camHUD.zoom += 0.03 / songMultiplier;
			}
		}
		if (Conductor.bpm < 340)
		{
			iconP1.setGraphicSize(Std.int(iconP1.width + 30));
			iconP2.setGraphicSize(Std.int(iconP2.width + 30));

			iconP1.updateHitbox();
			iconP2.updateHitbox();
		}
		else
		{
			iconP1.setGraphicSize(Std.int(iconP1.width + 4));
			iconP2.setGraphicSize(Std.int(iconP2.width + 4));

			iconP1.updateHitbox();
			iconP2.updateHitbox();
		}

		if (!endingSong && currentSection != null)
		{
			if (allowedToHeadbang)
			{
				gf.dance();
			}
		}
	}

	public var cleanedSong:SongData;

	function poggers(?cleanTheSong = false)
	{
		var notes = [];

		if (cleanTheSong)
		{
			cleanedSong = SONG;

			for (section in cleanedSong.notes)
			{
				var removed = [];

				for (note in section.sectionNotes)
				{
					// commit suicide
					var old = note[0];
					if (note[0] < section.startTime)
					{
						notes.push(note);
						removed.push(note);
					}
					if (note[0] > section.endTime)
					{
						notes.push(note);
						removed.push(note);
					}
				}

				for (i in removed)
				{
					section.sectionNotes.remove(i);
				}
			}

			for (section in cleanedSong.notes)
			{
				var saveRemove = [];

				for (i in notes)
				{
					if (i[0] >= section.startTime && i[0] < section.endTime)
					{
						saveRemove.push(i);
						section.sectionNotes.push(i);
					}
				}

				for (i in saveRemove)
					notes.remove(i);
			}

			trace("FUCK YOU BITCH FUCKER CUCK SUCK BITCH " + cleanedSong.notes.length);

			SONG = cleanedSong;
		}
		else
		{
			for (section in SONG.notes)
			{
				var removed = [];

				for (note in section.sectionNotes)
				{
					// commit suicide
					var old = note[0];
					if (note[0] < section.startTime)
					{
						notes.push(note);
						removed.push(note);
					}
					if (note[0] > section.endTime)
					{
						notes.push(note);
						removed.push(note);
					}
				}

				for (i in removed)
				{
					section.sectionNotes.remove(i);
				}
			}

			for (section in SONG.notes)
			{
				var saveRemove = [];

				for (i in notes)
				{
					if (i[0] >= section.startTime && i[0] < section.endTime)
					{
						saveRemove.push(i);
						section.sectionNotes.push(i);
					}
				}

				for (i in saveRemove)
					notes.remove(i);
			}

			trace("FUCK YOU BITCH FUCKER CUCK SUCK BITCH " + cleanedSong.notes.length);

			SONG = cleanedSong;
		}
	}
}
// u looked :O -ides
