function eventTrigger(value, name, position)
{
	var animData = name;
	switch (animData)
	{
		case "dad":
			dad.importantAnimation = false;
		case "bf":
			boyfriend.importantAnimation = false;
		case "gf":
			gf.importantAnimation = false;
	}
}