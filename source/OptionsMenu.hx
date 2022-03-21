package;

import flixel.FlxCamera;
import flixel.FlxSubState;
import flixel.input.gamepad.FlxGamepad;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import openfl.Lib;
import Options;
import Controls.Control;
import flash.text.TextField;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.display.FlxGridOverlay;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.input.keyboard.FlxKey;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.util.FlxColor;

class OptionText extends FlxText
{
	var hasCheck:Bool = false;
	var myCheck:FlxSprite;

	public function createCheck()
	{
		hasCheck = true;
		myCheck = new FlxSprite(x + width + 20, y + 5).loadGraphic(Paths.image('checkmark'), true, 30, 30);
		myCheck.antialiasing = FlxG.save.data.antialiasing;
		myCheck.animation.add("idle", [0, 1], 0, false);
		myCheck.animation.play("idle");
	}

	public function setIsChecked( isChecked:Bool )
	{
		myCheck.animation.curAnim.curFrame = (isChecked ? 1 : 0);
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);
		if (hasCheck)
		{
			myCheck.x = x + width + 20;
			myCheck.y = y + 5;
			myCheck.alpha = alpha;
		}
	}

	public override function draw()
	{
		super.draw();
		if (hasCheck)
			myCheck.draw();
	}
}

class OptionCata extends FlxSprite
{
	public var title:String;
	public var options:Array<Option>;

	public var optionObjects:FlxTypedGroup<OptionText>;

	public var titleObject:FlxText;

	public var middle:Bool = false;

	public function new(x:Float, y:Float, _title:String, _options:Array<Option>, middleType:Bool = false)
	{
		super(x, y);
		title = CoolUtil.translate(_title);
		middle = middleType;
		if (!middleType)
			makeGraphic(295, 64, FlxColor.BLACK);
		alpha = 0.4;

		options = _options;

		optionObjects = new FlxTypedGroup();

		titleObject = new FlxText((middleType ? 1180 / 2 : x), y + (middleType ? 0 : 16), 0, title);
		titleObject.setFormat(Paths.font("vcr.ttf"), 35, FlxColor.WHITE, FlxTextAlign.LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		titleObject.borderSize = 3;

		if (middleType)
		{
			titleObject.x = 50 + ((1180 / 2) - (titleObject.fieldWidth / 2));
		}
		else
			titleObject.x += (width / 2) - (titleObject.fieldWidth / 2);

		titleObject.scrollFactor.set();

		scrollFactor.set();

		for (i in 0...options.length)
		{
			var opt = options[i];
			var text:OptionText = new OptionText((middleType ? 1180 / 2 : 72), titleObject.y + 54 + (46 * i), 0, opt.getValue());
			if (middleType)
			{
				text.screenCenter(X);
			}
			text.setFormat(Paths.font("vcr.ttf"), 35, FlxColor.WHITE, FlxTextAlign.CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
			text.borderSize = 3;
			text.borderQuality = 1;
			text.scrollFactor.set();
			if (opt.isCheckable())
			{
				text.createCheck();
				text.setIsChecked( opt.isChecked() );
			}
			optionObjects.add(text);
		}
	}

	public function changeColor(color:FlxColor)
	{
		makeGraphic(295, 64, color);
	}
}

class OptionsMenu extends FlxSubState
{
	public static var instance:OptionsMenu;

	public var background:FlxSprite;

	public var selectedCat:OptionCata;

	public var selectedOption:Option;

	public var selectedCatIndex = 0;
	public var selectedOptionIndex = 0;

	public var isInCat:Bool = false;

	public var options:Array<OptionCata>;

	public static var isInPause = false;

	public var shownStuff:FlxTypedGroup<FlxText>;

	public static var visibleRange = [114, 640];

	public function new(pauseMenu:Bool = false)
	{
		super();

		isInPause = pauseMenu;
	}

	public var menu:FlxTypedGroup<FlxSprite>;

	public var descText:FlxText;
	public var descBack:FlxSprite;

	override function create()
	{
		options = [
			new OptionCata(50, 40, "optionsCatGameplay", [
				new ScrollSpeedOption('optionsDescScrollSpeed'),
				new OffsetThing('optionsDescOffsetThing'),
				new AccuracyDOption('optionsDescAccuracyCalc'),
				new OptionTypeCheckmark('optionsDownscroll', 'optionsDescDownscroll', false, 'downscroll'),
				new OptionTypeCheckmark('optionsBotplay', 'optionsDescBotplay', true, 'botplay'),
				#if desktop new FPSCapOption('optionsDescFPSCap'),
				#end
				new OptionTypeCheckmark('optionsResetButton', 'optionsDescResetButton', true, 'resetButton'),
				new OptionTypeCheckmark('optionsInstantRespawn', 'optionsDescInstantRespawn', true, 'InstantRespawn'),
				new OptionTypeCheckmark('optionsCamZoom', 'optionsDescCamZoom', false, 'camzoom'),
				new DFJKOption(),
				new Judgement('optionsDescJudgement'),
				new CustomizeGameplay('optionsDescCustomizeGameplay')
			]),
			new OptionCata(345, 40, "optionsCatAppearance", [
				new NoteskinOption('optionsDescNoteskin'),
				new OptionTypeCheckmark('optionsEditorRes', 'optionsDescEditorRes', true, 'editorBG'),
				new EditorZoomOption('optionsDescEditorZoom'),
				new OptionTypeCheckmark('optionsDistractions', 'optionsDescDistractions', false, 'distractions'),
				new OptionTypeCheckmark('optionsMiddleScroll', 'optionsDescMiddleScroll', false, 'middleScroll'),
				new OptionTypeCheckmark('optionsHealthBar', 'optionsDescHealthBar', false, 'healthBar'),
				new OptionTypeCheckmark('optionsJudgementCounter', 'optionsDescJudgementCounter', false, 'judgementCounter'),
				new LaneUnderlayOption('optionsDescLaneUnderlay'),
				new LaneBorderOption('optionsDescLaneBorder'),
				new OptionTypeCheckmark('optionsStepMania', 'optionsDescStepMania', false, 'stepMania'),
				new StepManiaAdvancedOption('optionsDescStepManiaAdvanced'),
				new OptionTypeCheckmark('optionsAccuracy', 'optionsDescAccuracy', false, 'accuracyDisplay'),
				new OptionTypeCheckmark('optionsSongPosition', 'optionsDescSongPosition', false, 'songPosition'),
				new OptionTypeCheckmark('optionsColour', 'optionsDescColour', false, 'colour'),
				new OptionTypeCheckmark('optionsNPSDisplay', 'optionsDescNPSDisplay', true, 'npsDisplay'),
				new RainbowFPSOption('optionsRainbowFPS', 'optionsDescRainbowFPS', true, 'fpsRain'),
				new OptionTypeCheckmark('optionsColorIcons', 'optionsDescColorIcons', false, 'colorIcons'),
				new OptionTypeCheckmark('optionsSubtitles', 'optionsDescSubtitles', true, 'subtitles'),
			]),
			new OptionCata(640, 40, "optionsCatMisc", [
				new FPSOption('optionsFPS', 'optionsDescFPS', true, 'fps'),
				new OptionTypeCheckmark('optionsFlashingLights', 'optionsDescFlashingLights', false, 'flashing'),
				new WatermarkOption('optionsWatermark', 'optionsDescWatermark', false, 'watermark'),
				new OptionTypeCheckmark('optionsAntialiasing', 'optionsDescAntialiasing', false, 'antialiasing'),
				new OptionTypeCheckmark('optionsMissSounds', 'optionsDescMissSounds', false, 'missSounds'),
				new OptionTypeCheckmark('optionsExtraSongInfo', 'optionsDescExtraSongInfo', true, 'extraSongInfo'),
				new OptionTypeCheckmark('optionsScoreScreen', 'optionsDescScoreScreen', true, 'scoreScreen'),
				new OptionTypeCheckmark('optionsShowInput', 'optionsDescShowInput', true, 'inputShow'),
				new OptionTypeCheckmark('optionsGraphicLoading', 'optionsDescGraphicLoading', true, 'cacheImages'),
			]),
			new OptionCata(935, 40, "optionsCatSaves", [
				new ResetScoreOption('optionsDescResetScore'),
				new ResetSettings('optionsDescResetSettings')
			]),
			new OptionCata(-1, 125, "optionsCatKeybinds", [
				new LeftKeybind('optionsDescKeybindLeft'),
				new DownKeybind('optionsDescKeybindDown'),
				new UpKeybind('optionsDescKeybindUp'),
				new RightKeybind('optionsDescKeybindRight'),
				new LeftFiveKeybind('optionsDescKeybindLeftFive'),
				new DownFiveKeybind('optionsDescKeybindDownFive'),
				new CenterKeybind('optionsDescKeybindCenter'),
				new UpFiveKeybind('optionsDescKeybindUpFive'),
				new RightFiveKeybind('optionsDescKeybindRightFive'),
				new PauseKeybind('optionsDescKeybindPause'),
				new ResetBind('optionsDescKeybindReset'),
				new MuteBind('optionsDescKeybindMute'),
				new VolUpBind('optionsDescKeybindVolUp'),
				new VolDownBind('optionsDescKeybindVolDown'),
				new FullscreenBind('optionsDescKeybindFullscreen'),
				new EditorBind('optionsDescKeybindEditor')], true),
			new OptionCata(-1, 125, "optionsCatJudgements", [
				new SickMSOption('optionsDescMSSick'),
				new GoodMsOption('optionsDescMSGood'),
				new BadMsOption('optionsDescMSBad'),
				new ShitMsOption('optionsDescMSShit')
			], true),
			new OptionCata(-1, 125, "optionsCatStepMania", [
				new RotateNotesOption('optionsDescRotateNotes'),
				new QuantColorOption('optionsDescQuantColor0',0),
				new QuantColorOption('optionsDescQuantColor1',1),
				new QuantColorOption('optionsDescQuantColor2',2),
				new QuantColorOption('optionsDescQuantColor3',3),
				new QuantColorOption('optionsDescQuantColor4',4),
				new QuantColorOption('optionsDescQuantColor5',5)
			], true)
		];

		instance = this;

		menu = new FlxTypedGroup<FlxSprite>();

		shownStuff = new FlxTypedGroup<FlxText>();

		background = new FlxSprite(50, 40).makeGraphic(1180, 640, FlxColor.BLACK);
		background.alpha = 0.5;
		background.scrollFactor.set();
		menu.add(background);

		descBack = new FlxSprite(50, 640).makeGraphic(1180, 38, FlxColor.BLACK);
		descBack.alpha = 0.3;
		descBack.scrollFactor.set();
		menu.add(descBack);

		if (isInPause)
		{
			var bg:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
			bg.alpha = 0;
			bg.scrollFactor.set();
			menu.add(bg);

			background.alpha = 0.5;
			bg.alpha = 0.6;

			cameras = [FlxG.cameras.list[FlxG.cameras.list.length - 1]];
		}

		selectedCat = options[0];

		selectedOption = selectedCat.options[0];

		add(menu);

		add(shownStuff);

		for (i in 0...options.length - 1)
		{
			if (i >= 4)
				continue;
			var cat = options[i];
			add(cat);
			add(cat.titleObject);
		}

		descText = new FlxText(62, 648);
		descText.setFormat(Paths.font("vcr.ttf"), 20, FlxColor.WHITE, FlxTextAlign.LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		descText.borderSize = 2;

		add(descBack);
		add(descText);

		isInCat = true;

		switchCat(selectedCat);

		selectedOption = selectedCat.options[0];

		super.create();
	}

	public function switchCat(cat:OptionCata, checkForOutOfBounds:Bool = true)
	{
		try
		{
			visibleRange = [114, 640];
			if (cat.middle)
				visibleRange = [Std.int(cat.titleObject.y), 640];
			if (selectedOption != null)
			{
				var object = selectedCat.optionObjects.members[selectedOptionIndex];
				object.text = selectedOption.getValue();
			}

			if (selectedCatIndex > options.length - 3 && checkForOutOfBounds)
				selectedCatIndex = 0;

			if (selectedCat.middle)
				remove(selectedCat.titleObject);

			selectedCat.changeColor(FlxColor.BLACK);
			selectedCat.alpha = 0.3;

			for (i in 0...selectedCat.options.length)
			{
				var opt = selectedCat.optionObjects.members[i];
				opt.y = selectedCat.titleObject.y + 54 + (46 * i);
			}

			while (shownStuff.members.length != 0)
			{
				shownStuff.members.remove(shownStuff.members[0]);
			}
			selectedCat = cat;
			selectedCat.alpha = 0.2;
			selectedCat.changeColor(FlxColor.WHITE);

			if (selectedCat.middle)
				add(selectedCat.titleObject);

			for (i in selectedCat.optionObjects)
				shownStuff.add(i);

			selectedOption = selectedCat.options[0];

			if (selectedOptionIndex > options[selectedCatIndex].options.length - 1)
			{
				for (i in 0...selectedCat.options.length)
				{
					var opt = selectedCat.optionObjects.members[i];
					opt.y = selectedCat.titleObject.y + 54 + (46 * i);
				}
			}

			selectedOptionIndex = 0;

			if (!isInCat)
				selectOption(selectedOption);

			for (i in selectedCat.optionObjects.members)
			{
				if (i.y < visibleRange[0] - 24)
					i.alpha = 0;
				else if (i.y > visibleRange[1] - 24)
					i.alpha = 0;
				else
				{
					i.alpha = 0.4;
				}
			}
		}
		catch (e)
		{
			Debug.logError("oops\n" + e);
			selectedCatIndex = 0;
		}

		Debug.logTrace("Changed cat: " + selectedCatIndex);
	}

	public function selectOption(option:Option)
	{
		var object = selectedCat.optionObjects.members[selectedOptionIndex];

		selectedOption = option;

		if (!isInCat)
		{
			object.text = "> " + option.getValue();

			descText.text = option.getDescription();
		}
		Debug.logTrace("Changed opt: " + selectedOptionIndex);

		Debug.logTrace("Bounds: " + visibleRange[0] + "," + visibleRange[1]);
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		var gamepad:FlxGamepad = FlxG.gamepads.lastActive;

		var accept = false;
		var right = false;
		var left = false;
		var up = false;
		var down = false;
		var any = false;
		var escape = false;

		accept = FlxG.keys.justPressed.ENTER || (gamepad != null ? gamepad.justPressed.A : false);
		right = FlxG.keys.justPressed.RIGHT || (gamepad != null ? gamepad.justPressed.DPAD_RIGHT : false);
		left = FlxG.keys.justPressed.LEFT || (gamepad != null ? gamepad.justPressed.DPAD_LEFT : false);
		up = FlxG.keys.justPressed.UP || (gamepad != null ? gamepad.justPressed.DPAD_UP : false);
		down = FlxG.keys.justPressed.DOWN || (gamepad != null ? gamepad.justPressed.DPAD_DOWN : false);

		any = FlxG.keys.justPressed.ANY || (gamepad != null ? gamepad.justPressed.ANY : false);
		escape = FlxG.keys.justPressed.ESCAPE || (gamepad != null ? gamepad.justPressed.B : false);

		if (selectedCat != null && !isInCat)
		{
			for (i in selectedCat.optionObjects.members)
			{
				if (selectedCat.middle)
				{
					i.screenCenter(X);
				}

				// I wanna die!!!
				if (i.y < visibleRange[0] - 24)
					i.alpha = 0;
				else if (i.y > visibleRange[1] - 24)
					i.alpha = 0;
				else
				{
					if (selectedCat.optionObjects.members[selectedOptionIndex].text != i.text)
						i.alpha = 0.4;
					else
						i.alpha = 1;
				}
			}
		}

		try
		{
			if (isInCat)
			{
				descText.text = "Please select a category";
				if (right)
				{
					FlxG.sound.play(Paths.sound('scrollMenu'));
					selectedCat.optionObjects.members[selectedOptionIndex].text = selectedOption.getValue();
					selectedCatIndex++;

					if (selectedCatIndex > options.length - 3)
						selectedCatIndex = 0;
					if (selectedCatIndex < 0)
						selectedCatIndex = options.length - 3;

					switchCat(options[selectedCatIndex]);
				}
				else if (left)
				{
					FlxG.sound.play(Paths.sound('scrollMenu'));
					selectedCat.optionObjects.members[selectedOptionIndex].text = selectedOption.getValue();
					selectedCatIndex--;

					if (selectedCatIndex > options.length - 3)
						selectedCatIndex = 0;
					if (selectedCatIndex < 0)
						selectedCatIndex = options.length - 3;

					switchCat(options[selectedCatIndex]);
				}

				if (accept)
				{
					FlxG.sound.play(Paths.sound('scrollMenu'));
					selectedOptionIndex = 0;
					isInCat = false;
					selectOption(selectedCat.options[0]);
				}

				if (escape)
				{
					if (!isInPause)
						FlxG.switchState(new MainMenuState());
					else
					{
						PauseSubState.goBack = true;
						PlayStateChangeables.scrollSpeed = FlxG.save.data.scrollSpeed * PlayState.songMultiplier;
						close();
					}
				}
			}
			else
			{
				if (selectedOption != null)
					if (selectedOption.acceptType)
					{
						if (escape && selectedOption.waitingType)
						{
							FlxG.sound.play(Paths.sound('scrollMenu'));
							selectedOption.waitingType = false;
							var object = selectedCat.optionObjects.members[selectedOptionIndex];
							object.text = "> " + selectedOption.getValue();
							Debug.logTrace("New text: " + object.text);
							return;
						}
						else if (any)
						{
							var object = selectedCat.optionObjects.members[selectedOptionIndex];
							selectedOption.onType(gamepad == null ? FlxG.keys.getIsDown()[0].ID.toString() : gamepad.firstJustPressedID());
							object.text = "> " + selectedOption.getValue();
							Debug.logTrace("New text: " + object.text);
						}
					}
				if (selectedOption.acceptType || !selectedOption.acceptType)
				{
					if (accept)
					{
						var prev = selectedOptionIndex;
						var object = selectedCat.optionObjects.members[selectedOptionIndex];
						selectedOption.press();
						if (selectedOption.isCheckable())
							object.setIsChecked( selectedOption.isChecked() );

						if (selectedOptionIndex == prev)
						{
							FlxG.save.flush();

							object.text = "> " + selectedOption.getValue();
						}
					}

					if (down)
					{
						if (selectedOption.acceptType)
							selectedOption.waitingType = false;
						FlxG.sound.play(Paths.sound('scrollMenu'));
						selectedCat.optionObjects.members[selectedOptionIndex].text = selectedOption.getValue();
						selectedOptionIndex++;

						// just kinda ignore this math lol

						if (selectedOptionIndex > options[selectedCatIndex].options.length - 1)
						{
							for (i in 0...selectedCat.options.length)
							{
								var opt = selectedCat.optionObjects.members[i];
								opt.y = selectedCat.titleObject.y + 54 + (46 * i);
							}
							selectedOptionIndex = 0;
						}

						if (selectedOptionIndex != 0
							&& selectedOptionIndex != options[selectedCatIndex].options.length - 1
							&& options[selectedCatIndex].options.length > 6)
						{
							if (selectedOptionIndex >= (options[selectedCatIndex].options.length - 1) / 2)
								for (i in selectedCat.optionObjects.members)
								{
									i.y -= 46;
								}
						}

						selectOption(options[selectedCatIndex].options[selectedOptionIndex]);
					}
					else if (up)
					{
						if (selectedOption.acceptType)
							selectedOption.waitingType = false;
						FlxG.sound.play(Paths.sound('scrollMenu'));
						selectedCat.optionObjects.members[selectedOptionIndex].text = selectedOption.getValue();
						selectedOptionIndex--;

						// just kinda ignore this math lol

						if (selectedOptionIndex < 0)
						{
							selectedOptionIndex = options[selectedCatIndex].options.length - 1;

							if (options[selectedCatIndex].options.length > 6)
								for (i in selectedCat.optionObjects.members)
								{
									i.y -= (46 * ((options[selectedCatIndex].options.length - 1) / 2));
								}
						}

						if (selectedOptionIndex != 0 && options[selectedCatIndex].options.length > 6)
						{
							if (selectedOptionIndex >= (options[selectedCatIndex].options.length - 1) / 2)
								for (i in selectedCat.optionObjects.members)
								{
									i.y += 46;
								}
						}

						if (selectedOptionIndex < (options[selectedCatIndex].options.length - 1) / 2)
						{
							for (i in 0...selectedCat.options.length)
							{
								var opt = selectedCat.optionObjects.members[i];
								opt.y = selectedCat.titleObject.y + 54 + (46 * i);
							}
						}

						selectOption(options[selectedCatIndex].options[selectedOptionIndex]);
					}

					if (right)
					{
						FlxG.sound.play(Paths.sound('scrollMenu'));
						var object = selectedCat.optionObjects.members[selectedOptionIndex];
						selectedOption.right();

						FlxG.save.flush();

						object.text = "> " + selectedOption.getValue();
						Debug.logTrace("New text: " + object.text);
					}
					else if (left)
					{
						FlxG.sound.play(Paths.sound('scrollMenu'));
						var object = selectedCat.optionObjects.members[selectedOptionIndex];
						selectedOption.left();

						FlxG.save.flush();

						object.text = "> " + selectedOption.getValue();
						Debug.logTrace("New text: " + object.text);
					}

					if (escape)
					{
						FlxG.sound.play(Paths.sound('scrollMenu'));

						if (selectedCatIndex >= 4)
							selectedCatIndex = 0;

						PlayerSettings.player1.controls.loadKeyBinds();

						Ratings.timingWindows = [
							FlxG.save.data.shitMs,
							FlxG.save.data.badMs,
							FlxG.save.data.goodMs,
							FlxG.save.data.sickMs
						];

						for (i in 0...selectedCat.options.length)
						{
							var opt = selectedCat.optionObjects.members[i];
							opt.y = selectedCat.titleObject.y + 54 + (46 * i);
						}
						selectedCat.optionObjects.members[selectedOptionIndex].text = selectedOption.getValue();
						isInCat = true;
						if (selectedCat.optionObjects != null)
							for (i in selectedCat.optionObjects.members)
							{
								if (i != null)
								{
									if (i.y < visibleRange[0] - 24)
										i.alpha = 0;
									else if (i.y > visibleRange[1] - 24)
										i.alpha = 0;
									else
									{
										i.alpha = 0.4;
									}
								}
							}
						if (selectedCat.middle)
							switchCat(options[0]);
					}
				}
			}
		}
		catch (e)
		{
			Debug.logError("wtf we actually did something wrong, but we dont crash bois.\n" + e);
			selectedCatIndex = 0;
			selectedOptionIndex = 0;
			FlxG.sound.play(Paths.sound('scrollMenu'));
			if (selectedCat != null)
			{
				for (i in 0...selectedCat.options.length)
				{
					var opt = selectedCat.optionObjects.members[i];
					opt.y = selectedCat.titleObject.y + 54 + (46 * i);
				}
				selectedCat.optionObjects.members[selectedOptionIndex].text = selectedOption.getValue();
				isInCat = true;
			}
		}
	}
}
