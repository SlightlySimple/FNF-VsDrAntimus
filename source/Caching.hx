#if FEATURE_FILESYSTEM
package;

import lime.app.Application;
#if FEATURE_DISCORD
import Discord.DiscordClient;
#end
import openfl.display.BitmapData;
import openfl.utils.Assets as OpenFlAssets;
import flixel.ui.FlxBar;
import haxe.Exception;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
#if FEATURE_FILESYSTEM
import sys.FileSystem;
import sys.io.File;
#end
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.transition.FlxTransitionSprite.GraphicTransTileDiamond;
import flixel.addons.transition.FlxTransitionableState;
import flixel.addons.transition.TransitionData;
import flixel.graphics.FlxGraphic;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import flixel.text.FlxText;
import flixel.input.keyboard.FlxKey;

using StringTools;

class Caching extends MusicBeatState
{
	var toBeDone = 0;
	var done = 0;

	var loaded = false;

	var bar:FlxBar;
	var text:FlxText;
	var loadingBG:FlxSprite;

	public static var bitmapData:Map<String, FlxGraphic>;

	var images = [];
	var music = [];
	var charts = [];

	override function create()
	{
		FlxG.save.bind('funkin', 'ninjamuffin99');

		PlayerSettings.init();

		KadeEngineData.initSave();

		CoolUtil.loadLangStrings();

		// It doesn't reupdate the list before u restart rn lmao
		NoteskinHelpers.updateNoteskins();

		FlxG.sound.muteKeys = [FlxKey.fromString(FlxG.save.data.muteBind)];
		FlxG.sound.volumeDownKeys = [FlxKey.fromString(FlxG.save.data.volDownBind)];
		FlxG.sound.volumeUpKeys = [FlxKey.fromString(FlxG.save.data.volUpBind)];

		FlxG.mouse.visible = false;

		FlxG.worldBounds.set(0, 0);

		bitmapData = new Map<String, FlxGraphic>();

		text = new FlxText(FlxG.width / 2, 100, 0, CoolUtil.translate('loading'));
		text.font = 'VCR OSD Mono';
		text.size = 34;
		text.alignment = FlxTextAlign.CENTER;

		loadingBG = new FlxSprite(0, 0).loadGraphic(Paths.image('LoadingScreen'));
		text.x -= 170;
		loadingBG.setGraphicSize(Std.int(FlxG.width));
		loadingBG.screenCenter();
		if(FlxG.save.data.antialiasing != null)
			loadingBG.antialiasing = FlxG.save.data.antialiasing;
		else
			loadingBG.antialiasing = true;

		FlxGraphic.defaultPersist = FlxG.save.data.cacheImages;

		#if FEATURE_FILESYSTEM
		if (FlxG.save.data.cacheImages)
		{
			Debug.logTrace("caching images...");

			// TODO: Refactor this to use OpenFlAssets.
			for (i in FileSystem.readDirectory(FileSystem.absolutePath("assets/shared/images/characters")))
			{
				if (!i.endsWith(".png"))
					continue;
				images.push(i);
			}

			for (i in FileSystem.readDirectory(FileSystem.absolutePath("assets/shared/images/noteskins")))
			{
				for (j in FileSystem.readDirectory(FileSystem.absolutePath("assets/shared/images/noteskins/" + i)))
				{
					if (!j.endsWith(".png"))
						continue;
					images.push(i + '/' + j);
				}
			}
		}

		Debug.logTrace("caching music...");

		// TODO: Get the song list from OpenFlAssets.
		music = Paths.listSongsToCache();
		#end

		toBeDone = Lambda.count(images) + Lambda.count(music);

		bar = new FlxBar(200, FlxG.height - 150, FlxBarFillDirection.LEFT_TO_RIGHT, FlxG.width - 400, 25, this, "done", 0, toBeDone);
        bar.createFilledBar(FlxColor.BLACK, FlxColor.WHITE);

		add(loadingBG);
		add(text);
		add(bar);

		trace('starting caching..');

		#if FEATURE_MULTITHREADING
		// update thread

		sys.thread.Thread.create(() ->
		{
			while (!loaded)
			{
				if (toBeDone != 0 && done != toBeDone)
				{
					text.text = CoolUtil.translate('loading') + " (" + done + "/" + toBeDone + ")";
				}
			}
		});

		// cache thread
		sys.thread.Thread.create(() ->
		{
			cache();
		});
		#end

		super.create();
	}

	var calledDone = false;

	override function update(elapsed)
	{
		super.update(elapsed);
	}

	function cache()
	{
		#if FEATURE_FILESYSTEM
		trace("LOADING: " + toBeDone + " OBJECTS.");

		for (i in images)
		{
			var replaced = i.replace(".png", "");

			// var data:BitmapData = BitmapData.fromFile("assets/shared/images/characters/" + i);
			var imagePath = Paths.image('characters/' + replaced, 'shared');
			if (!OpenFlAssets.exists(imagePath))
				imagePath = Paths.image('noteskins/' + replaced, 'shared');
			Debug.logTrace('Caching character graphic $i ($imagePath)...');
			var data = OpenFlAssets.getBitmapData(imagePath);
			var graph = FlxGraphic.fromBitmapData(data);
			graph.persist = true;
			graph.destroyOnNoUse = false;
			bitmapData.set(replaced, graph);
			done++;
		}

		for (i in music)
		{
			var inst = Paths.inst(i);
			if (Paths.doesSoundAssetExist(inst))
			{
				FlxG.sound.cache(inst);
			}

			var voices = Paths.voices(i);
			if (Paths.doesSoundAssetExist(voices))
			{
				FlxG.sound.cache(voices);
			}

			var voicesSolo = Paths.voices(i, "Solo");
			if (Paths.doesSoundAssetExist(voicesSolo))
			{
				FlxG.sound.cache(voicesSolo);
			}

			done++;
		}

		Debug.logTrace("Finished caching...");

		loaded = true;
		text.text = CoolUtil.translate('loadingDone');

		trace(OpenFlAssets.cache.hasBitmapData('GF_assets'));
		#end
		FlxG.camera.fade(FlxColor.BLACK, 1, false, function()
		{
			FlxG.switchState(new TitleState());
		});
	}
}
#end
