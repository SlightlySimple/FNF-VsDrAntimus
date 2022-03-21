var strumlinePosition = 0;

function update(elapsed)
{
	if (PlayStateInstance.songStarted)
	{
		var strumHeightDesired = 360 - 45;
		switch (strumlinePosition)
		{
			case 0:
				strumHeightDesired = (PlayStateChangeables.useDownscroll ? FlxG.height - 165 : 50);
			case 2:
				strumHeightDesired = (PlayStateChangeables.useDownscroll ? 50 : FlxG.height - 165);
		}

		var tempY = 0;
		var addY = 0;
		var strumNoteCount = Std.int( PlayState.strumLineNotes.length / 2 );
		if (PlayStateChangeables.middleScroll)
			strumNoteCount = Std.int( PlayState.strumLineNotes.length );

		for (i in 0...strumNoteCount)
		{
			tempY = PlayState.strumLineNotes.members[i].y;
			addY = strumHeightDesired - tempY;
			if (Math.abs(addY) > 5)
			{
				addY *= ( 60 / ( (i + 2) * 3 ) ) * elapsed;
				tempY += addY;
			}
			else
				tempY = strumHeightDesired;
			PlayState.strumLineNotes.members[i].y = tempY;
			if (!PlayStateChangeables.middleScroll)
				PlayState.strumLineNotes.members[i + strumNoteCount].y = tempY;
		}

		PlayStateInstance.strumLine.y = strumHeightDesired;
	}
}

function eventTrigger(value, name, position)
{
	strumlinePosition = Std.int(value);
}