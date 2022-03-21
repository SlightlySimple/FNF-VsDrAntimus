var revivalEvent = false;

function create()
{
	new FlxTimer().start(0.01, function(timer)
	{
		PlayState.instance.iconP2.alpha = 0.0;
	});
}

function eventTrigger(value, name, position)
{
	revivalEvent = (value > 0);
}

function beatHit()
{
	if (revivalEvent && PlayState.instance.iconP2.alpha < 1.0)
		PlayState.instance.iconP2.alpha += 0.05;
}