import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.text.FlxText;
import flixel.math.FlxMath;
import flixel.FlxCamera;
import flixel.math.FlxPoint;
import flixel.FlxObject;
#if FEATURE_DISCORD
import Discord.DiscordClient;
#end
import flixel.addons.effects.FlxTrail;
import flixel.group.FlxGroup.FlxTypedGroup;
import openfl.ui.Keyboard;
import flixel.FlxSprite;
import flixel.FlxG;

using StringTools;

class GameplayCustomizeState extends MusicBeatState
{
	var defaultX:Float = FlxG.width * 0.55 - 135;
	var defaultY:Float = FlxG.height / 2 - 50;

	var sick:FlxSprite;

	var text:FlxText;
	var blackBorder:FlxSprite;

	var laneunderlay:FlxSprite;
	var laneunderlayOpponent:FlxSprite;

	var strumLine:FlxSprite;
	var strumLineNotes:FlxTypedGroup<FlxSprite>;
	var playerStrums:FlxTypedGroup<FlxSprite>;
	var cpuStrums:FlxTypedGroup<StaticArrow>;

	var camPos:FlxPoint;

	private var camHUD:FlxCamera;
	private var camGame:FlxCamera;
	private var camFollow:FlxObject;
	private var dataSuffix:Array<String> = ['LEFT', 'DOWN', 'UP', 'RIGHT'];
	private var dataColor:Array<String> = ['purple', 'blue', 'green', 'red'];

	public static var dad:Character;
	public static var gf:Character;
	public static var boyfriend:Boyfriend;
	public static var Stage:Stage;
	public static var freeplayBf:String = 'bf';
	public static var freeplayDad:String = 'antimus';
	public static var freeplayGf:String = 'gf';
	public static var freeplayNoteStyle:String = 'normal';
	public static var freeplayStage:String = 'lab';
	public static var freeplaySong:String = 'dungeon';
	public static var freeplayWeek:Int = 0;

	public override function create()
	{
		super.create();

		#if FEATURE_DISCORD
		// Updating Discord Rich Presence
		DiscordClient.changePresence("Customizing Gameplay Modules", null);
		#end

		camGame = new FlxCamera();
		camHUD = new FlxCamera();
		camHUD.bgColor.alpha = 0;

		FlxG.cameras.reset(camGame);
		FlxG.cameras.add(camHUD);

		FlxCamera.defaultCameras = [camGame];

		camHUD.zoom = FlxG.save.data.zoom;

		persistentUpdate = persistentDraw = true;

		gf = new Character(0, 0, freeplayGf);

		if (gf.frames == null)
		{
			#if debug
			FlxG.log.warn(["Couldn't load gf: " + freeplayGf + ". Loading default gf"]);
			#end
			gf = new Character(0, 0, 'gf');
		}

		boyfriend = new Boyfriend(0, 0, freeplayBf);

		if (boyfriend.frames == null)
		{
			#if debug
			FlxG.log.warn(["Couldn't load boyfriend: " + freeplayBf + ". Loading default boyfriend"]);
			#end
			boyfriend = new Boyfriend(0, 0, 'bf');
		}

		dad = new Character(0, 0, freeplayDad);

		if (dad.frames == null)
		{
			#if debug
			FlxG.log.warn(["Couldn't load opponent: " + freeplayDad + ". Loading default opponent"]);
			#end
			dad = new Character(0, 0, 'antimus');
		}

		Stage = new Stage(freeplayStage);

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
					for (bg in array)
						add(bg);
				case 1:
					add(dad);
					for (bg in array)
						add(bg);
				case 2:
					add(boyfriend);
					for (bg in array)
						add(bg);
			}
		}

		camPos = new FlxPoint(Stage.stageJson.camPos[0], Stage.stageJson.camPos[1]);

		camFollow = new FlxObject(0, 0, 1, 1);

		camFollow.setPosition(camPos.x, camPos.y);

		add(camFollow);

		FlxG.camera.follow(camFollow, LOCKON, 0.01);
		FlxG.camera.zoom = Stage.camZoom;
		FlxG.camera.focusOn(camFollow.getPosition());

		FlxG.worldBounds.set(0, 0, FlxG.width, FlxG.height);

		strumLine = new FlxSprite(0, FlxG.save.data.strumline).makeGraphic(FlxG.width, 14);
		strumLine.scrollFactor.set();
		strumLine.alpha = 0.4;

		add(strumLine);

		if (FlxG.save.data.downscroll)
			strumLine.y = FlxG.height - 165;

		var laneBorder = FlxG.save.data.laneBorder;

		laneunderlayOpponent = new FlxSprite(0, 0).makeGraphic(110 * 4 + (laneBorder * 2), FlxG.height * 2);
		laneunderlayOpponent.alpha = 1 - FlxG.save.data.laneTransparency;
		laneunderlayOpponent.color = FlxColor.BLACK;
		laneunderlayOpponent.scrollFactor.set();
		laneunderlayOpponent.cameras = [camHUD];

		laneunderlay = new FlxSprite(0, 0).makeGraphic(110 * 4 + (laneBorder * 2), FlxG.height * 2);
		laneunderlay.alpha = 1 - FlxG.save.data.laneTransparency;
		laneunderlay.color = FlxColor.BLACK;
		laneunderlay.scrollFactor.set();
		laneunderlay.cameras = [camHUD];

		if (FlxG.save.data.laneUnderlay)
		{
			if (!FlxG.save.data.middleScroll)
			{
				add(laneunderlayOpponent);
			}
			add(laneunderlay);
		}

		strumLineNotes = new FlxTypedGroup<FlxSprite>();
		add(strumLineNotes);

		playerStrums = new FlxTypedGroup<FlxSprite>();
		cpuStrums = new FlxTypedGroup<StaticArrow>();

		sick = new FlxSprite().loadGraphic(Paths.loadImage('sick', 'shared'));
		sick.setGraphicSize(Std.int(sick.width * 0.7));
		sick.scrollFactor.set();

		sick.setGraphicSize(Std.int(sick.width * 0.7));
		sick.antialiasing = FlxG.save.data.antialiasing;

		sick.updateHitbox();
		add(sick);

		strumLine.cameras = [camHUD];
		strumLineNotes.cameras = [camHUD];
		sick.cameras = [camHUD];

		generateStaticArrows(0);
		generateStaticArrows(1);

		laneunderlay.x = playerStrums.members[0].x - laneBorder;
		laneunderlayOpponent.x = cpuStrums.members[0].x - laneBorder;

		laneunderlay.screenCenter(Y);
		laneunderlayOpponent.screenCenter(Y);

		text = new FlxText(5, FlxG.height + 40, 0,
			"Click and drag around gameplay elements to customize their positions. Press R to reset. Q/E to change zoom. C to show combo. Escape to exit.",
			12);
		text.scrollFactor.set();
		text.setFormat("VCR OSD Mono", 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);

		blackBorder = new FlxSprite(-30, FlxG.height + 40).makeGraphic((Std.int(text.width + 900)), Std.int(text.height + 600), FlxColor.BLACK);
		blackBorder.alpha = 0.5;

		blackBorder.cameras = [camHUD];
		text.cameras = [camHUD];

		add(blackBorder);
		add(text);

		FlxTween.tween(text, {y: FlxG.height - 18}, 2, {ease: FlxEase.elasticInOut});
		FlxTween.tween(blackBorder, {y: FlxG.height - 18}, 2, {ease: FlxEase.elasticInOut});

		if (!FlxG.save.data.changedHit)
		{
			FlxG.save.data.changedHitX = defaultX;
			FlxG.save.data.changedHitY = defaultY;
		}

		sick.x = FlxG.save.data.changedHitX;
		sick.y = FlxG.save.data.changedHitY;

		FlxG.mouse.visible = true;
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (FlxG.sound.music != null)
			Conductor.songPosition = FlxG.sound.music.time;

		if (FlxG.save.data.zoom < 0.8)
			FlxG.save.data.zoom = 0.8;

		if (FlxG.save.data.zoom > 1.2)
			FlxG.save.data.zoom = 1.2;

		FlxG.camera.zoom = FlxMath.lerp(Stage.camZoom, FlxG.camera.zoom, 0.95);
		camHUD.zoom = FlxMath.lerp(FlxG.save.data.zoom, camHUD.zoom, 0.95);

		if (FlxG.mouse.overlaps(sick) && FlxG.mouse.pressed)
		{
			sick.x = (FlxG.mouse.screenX - (sick.width / 2));
			sick.y = (FlxG.mouse.screenY - (sick.height / 2));
		}

		for (i in playerStrums)
			i.y = strumLine.y;
		for (i in strumLineNotes)
			i.y = strumLine.y;

		if (FlxG.keys.justPressed.Q)
		{
			FlxG.save.data.zoom += 0.02;
			camHUD.zoom = FlxG.save.data.zoom;
		}

		if (FlxG.keys.justPressed.E)
		{
			FlxG.save.data.zoom -= 0.02;
			camHUD.zoom = FlxG.save.data.zoom;
		}

		if (FlxG.mouse.overlaps(sick) && FlxG.mouse.justReleased)
		{
			FlxG.save.data.changedHitX = sick.x;
			FlxG.save.data.changedHitY = sick.y;
			FlxG.save.data.changedHit = true;
		}

		if (FlxG.keys.justPressed.C)
		{
			var visibleCombos:Array<FlxSprite> = [];

			var seperatedScore:Array<Int> = [];

			var comboSplit:Array<String> = (FlxG.random.int(10, 420) + "").split('');

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
				var numScore:FlxSprite = new FlxSprite().loadGraphic(Paths.loadImage('num' + Std.int(i)));
				numScore.screenCenter();
				numScore.x = sick.x + (43 * daLoop) - 50;
				numScore.y = sick.y + 100;
				numScore.cameras = [camHUD];

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
		}

		if (FlxG.keys.justPressed.R)
		{
			sick.x = defaultX;
			sick.y = defaultY;
			FlxG.save.data.zoom = 1;
			camHUD.zoom = FlxG.save.data.zoom;
			FlxG.save.data.changedHitX = sick.x;
			FlxG.save.data.changedHitY = sick.y;
			FlxG.save.data.changedHit = false;
		}

		if (controls.BACK)
		{
			FlxG.mouse.visible = false;
			FlxG.sound.play(Paths.sound('cancelMenu'));
			FlxG.switchState(new OptionsDirect());
		}
	}

	override function beatHit()
	{
		super.beatHit();

		if (curBeat % 2 == 0)
		{
			boyfriend.dance();
			dad.dance();
		}

		gf.dance();

		if (!FlxG.keys.pressed.SPACE)
		{
			FlxG.camera.zoom += 0.015;
			camHUD.zoom += 0.010;
		}

		trace('beat');
	}

	// ripped from playstate cuz lol
	private function generateStaticArrows(player:Int):Void
	{
		for (i in 0...4)
		{
			var babyArrow:StaticArrow = new StaticArrow(0, strumLine.y);

			babyArrow.frames = NoteskinHelpers.generateNoteskinSprite(FlxG.save.data.noteskin, freeplayNoteStyle);

			var lowerDir:String = dataSuffix[i].toLowerCase();

			babyArrow.animation.addByPrefix('static', 'arrow' + dataSuffix[i]);

			babyArrow.x += Note.swagWidth * i;

			babyArrow.antialiasing = FlxG.save.data.antialiasing;
			babyArrow.setGraphicSize(Std.int(babyArrow.width * 0.7));

			babyArrow.updateHitbox();
			babyArrow.scrollFactor.set();

			babyArrow.ID = i;

			switch (player)
			{
				case 0:
					babyArrow.visible = !FlxG.save.data.middleScroll;
					babyArrow.x += 20;
					cpuStrums.add(babyArrow);
				case 1:
					playerStrums.add(babyArrow);
			}

			babyArrow.animation.play('static');
			babyArrow.x += 96;
			babyArrow.x += ((FlxG.width / 2) * player);

			if (FlxG.save.data.middleScroll)
				babyArrow.x -= FlxG.width / 4;

			cpuStrums.forEach(function(spr:FlxSprite)
			{
				spr.centerOffsets(); // CPU arrows start out slightly off-center
			});

			strumLineNotes.add(babyArrow);
		}
	}
}
