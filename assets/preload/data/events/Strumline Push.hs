var shouldPushStrumline = false;
var leftMagnet = null;
var rightMagnet = null;

function create()
{
	leftMagnet = new FlxSprite(160, -175);
	leftMagnet.frames = Paths.getSparrowAtlas('magnet');
	leftMagnet.animation.addByPrefix('enter', 'Enter', 24, false);
	leftMagnet.animation.addByPrefix('loop', 'Loop', 24, true);
	leftMagnet.animation.addByPrefix('exit', 'Exit', 24, false);
	leftMagnet.setGraphicSize(Std.int(leftMagnet.width * 0.7));
	leftMagnet.updateHitbox();
	leftMagnet.antialiasing = saveData.antialiasing;
	leftMagnet.cameras = [camHUD];

	add(leftMagnet);

	rightMagnet = new FlxSprite(220 + (FlxG.width / 2), -175);
	rightMagnet.frames = Paths.getSparrowAtlas('magnet');
	rightMagnet.animation.addByPrefix('enter', 'Enter', 24, false);
	rightMagnet.animation.addByPrefix('loop', 'Loop', 24, true);
	rightMagnet.animation.addByPrefix('exit', 'Exit', 24, false);
	rightMagnet.flipX = true;
	rightMagnet.setGraphicSize(Std.int(rightMagnet.width * 0.7));
	rightMagnet.updateHitbox();
	rightMagnet.antialiasing = saveData.antialiasing;
	rightMagnet.cameras = [camHUD];

	add(rightMagnet);

	if (!PlayStateChangeables.useDownscroll)
	{
		leftMagnet.flipY = true;
		rightMagnet.flipY = true;
		leftMagnet.y = FlxG.height - 175;
		rightMagnet.y = FlxG.height - 175;
	}

	if (PlayStateChangeables.middleScroll)
	{
		remove(leftMagnet);
		rightMagnet.x -= FlxG.width / 4;
	}
}

function update(elapsed)
{
	if (!shouldPushStrumline)
	{
		var strumHeightDesired = 50;
		if (PlayStateChangeables.useDownscroll)
			strumHeightDesired = FlxG.height - 165;

		var tempY = PlayStateInstance.strumLine.y;
		tempY += ( ( strumHeightDesired ) - tempY ) * ( 4 * elapsed );
		PlayStateInstance.strumLine.y = tempY;

		if ( Math.abs( strumHeightDesired - tempY ) > 1 )
		{
			PlayState.strumLineNotes.forEach(function(babyArrow)
			{
				babyArrow.y = PlayStateInstance.strumLine.y;
			});
		}
	}
}

function eventTrigger(value, name, position)
{
	shouldPushStrumline = (value == 1);
	if (shouldPushStrumline)
	{
		leftMagnet.animation.play('loop');
		rightMagnet.animation.play('loop');

		if (PlayStateChangeables.useDownscroll)
			PlayStateInstance.strumLine.y -= 4;
		else
			PlayStateInstance.strumLine.y += 4;
		PlayState.strumLineNotes.forEach(function(babyArrow)
		{
			babyArrow.y = PlayStateInstance.strumLine.y;
		});
	}
	else
	{
		leftMagnet.animation.play('exit');
		rightMagnet.animation.play('exit');
	}
}

function beatHit()
{
	for (i in SONG.eventObjects)
	{
		if (Std.int(i.position) == curBeat + 4 && i.type == "Strumline Push" && i.value == 1)
		{
			leftMagnet.animation.play('enter');
			rightMagnet.animation.play('enter');
		}
	}

	if (shouldPushStrumline)
	{
		if (PlayStateChangeables.useDownscroll)
			PlayStateInstance.strumLine.y -= 4;
		else
			PlayStateInstance.strumLine.y += 4;
		PlayState.strumLineNotes.forEach(function(babyArrow)
		{
			babyArrow.y = PlayStateInstance.strumLine.y;
		});
	}
}