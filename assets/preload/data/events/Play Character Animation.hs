function eventTrigger(value, name, position)
{
	var animData = name.split(';');
	switch (animData[0])
	{
		case "dad":
			dad.playAnim(animData[1], true);
			dad.importantAnimation = true;
		case "bf":
			boyfriend.playAnim(animData[1], true);
			boyfriend.importantAnimation = true;
		case "gf":
			gf.playAnim(animData[1], true);
			gf.importantAnimation = true;
	}
}