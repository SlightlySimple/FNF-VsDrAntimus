var healthMax = 2.0;
var fakeBf;

function triggerFakeDeath()
{
	healthMax = 3.0;
	FlxG.sound.play(Paths.sound('fnf_loss_sfx_' + StringTools.replace(StringTools.replace(boyfriend.gameOverCharacter, "-dead", ""), "-", "_")));

	var black = new FlxSprite(-100, -100).makeGraphic(FlxG.width * 2, FlxG.height * 2, 0xFF000000);
	black.scrollFactor.set();
	add(black);

	fakeBf = new Character(boyfriend.x, boyfriend.y, boyfriend.gameOverCharacter, true);
	add(fakeBf);
	fakeBf.playAnim('fakeDeath');

	camHUD.visible = false;

	PlayState.instance.forcedCamPosition = true;
	new FlxTimer().start(0.5, function(timer)
	{
		PlayState.instance.camZooming = false;
		PlayState.instance.camFollow.x = fakeBf.getGraphicMidpoint().x;
		PlayState.instance.camFollow.y = fakeBf.getGraphicMidpoint().y;
		FlxG.camera.followLerp = 0.01;
	});
}

function stepHit()
{
	if (PlayState.instance.healthLimiter)
	{
		if (healthMax == 3.0)
			PlayState.instance.health = 1.0;
		else if ( PlayState.instance.health > healthMax )
		{
			PlayState.instance.health -= 0.15;
			if ( PlayState.instance.health < healthMax )		// This is just a precaution so we don't accidentally kill the player for real
				PlayState.instance.health = healthMax;
		}
	}
}

function eventTrigger(value, name, position)
{
	if (PlayState.isStoryMode)
	{
		switch (value)
		{
			case 1:
				PlayState.instance.healthLimiter = true;
			case 2:
				healthMax = 1.5;
			case 3:
				healthMax = 1.0;
			case 4:
				healthMax = 0.5;
			case 5:
				healthMax = 0.2;
			case 6:
				triggerFakeDeath();
		}
	}
}