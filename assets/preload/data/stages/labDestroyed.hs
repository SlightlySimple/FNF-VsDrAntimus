function create()
{
	getBack('cityLightning').alpha = 0.0;
	getBack('backLightning').alpha = 0.0;
	getBack('objectsLightning').alpha = 0.0;
	getBack('boardLightning').alpha = 0.0;

	FlxG.sound.cache(Paths.sound('thunder_1'));
	FlxG.sound.cache(Paths.sound('thunder_2'));
}

function update(elapsed)
{
	getBack('cloud1').x += 20 * elapsed;
	getBack('cloud2').x += 20 * elapsed;
	getBack('cloud3').x += 20 * elapsed;
	getBack('cloud4').x -= 30 * elapsed;
	getBack('cloud5').x -= 40 * elapsed;

	if (getBack('cloud1').x >= getBack('sky').x + getBack('sky').width)
	{
		getBack('cloud1').x -= getBack('cloud1').width + getBack('sky').width;
		getBack('cloud1').y = -FlxG.random.int(350, 700);
	}

	if (getBack('cloud2').x >= getBack('sky').x + getBack('sky').width)
	{
		getBack('cloud2').x -= getBack('cloud2').width + getBack('sky').width;
		getBack('cloud2').y = -FlxG.random.int(350, 700);
	}

	if (getBack('cloud3').x >= getBack('sky').x + getBack('sky').width)
	{
		getBack('cloud3').x -= getBack('cloud3').width + getBack('sky').width;
		getBack('cloud3').y = -FlxG.random.int(350, 700);
	}

	if (getBack('cloud4').x <= getBack('sky').x - getBack('cloud4').width)
	{
		getBack('cloud4').x += getBack('cloud4').width + getBack('sky').width;
		getBack('cloud4').y = -FlxG.random.int(350, 700);
	}

	if (getBack('cloud5').x <= getBack('sky').x - getBack('cloud5').width)
	{
		getBack('cloud5').x += getBack('cloud5').width + getBack('sky').width;
		getBack('cloud5').y = -FlxG.random.int(350, 700);
	}
}

var lightningStrikeBeat = 0;
var lightningOffset = 8;

function lightningStrikeShit()
{
	FlxG.sound.play(Paths.soundRandom('thunder_', 1, 2, 'shared'));
	getBack('lightning').x = getBack('city').x + FlxG.random.int(0, Std.int(getBack('city').width) - 700);
	getBack('lightning').y = FlxG.random.int(-300, -100);
	getBack('lightning').animation.play('strike' + FlxG.random.int(1, 6), true);

	getBack('cityLightning').alpha = 1.0;
	getBack('backLightning').alpha = 1.0;
	getBack('objectsLightning').alpha = 1.0;
	getBack('boardLightning').alpha = 1.0;

	getBack('backLightning').animation.play('strike', true);
	getBack('objectsLightning').animation.play('strike', true);
	getBack('boardLightning').animation.play('strike', true);

	FlxTween.tween(getBack('cityLightning'), {alpha: 0}, 0.25);
	FlxTween.tween(getBack('backLightning'), {alpha: 0}, 0.75);
	FlxTween.tween(getBack('objectsLightning'), {alpha: 0}, 0.75);
	FlxTween.tween(getBack('boardLightning'), {alpha: 0}, 0.75);

	lightningStrikeBeat = curBeat;
	lightningOffset = FlxG.random.int(16, 48);
}

function beatHit()
{
	if (PlayStateInstance.songStarted)
	{
		if (FlxG.random.bool(Conductor.bpm > 320 ? 100 : 10) && curBeat > lightningStrikeBeat + lightningOffset)
		{
			if (saveData.distractions)
				lightningStrikeShit();
		}
	}
}