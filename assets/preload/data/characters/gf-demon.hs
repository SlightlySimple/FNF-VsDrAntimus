var siner = 0;
var sinemove = FlxG.random.int(40, 65);

function update(elapsed)
{
	siner += 3 * elapsed;
	if ( ( siner + ( Math.PI / 2 ) ) % Math.PI < 3 * elapsed )
	{
		sinemove = FlxG.random.int(40, 65);
	}
	char.y = 200 + Math.cos( siner ) * sinemove;
}