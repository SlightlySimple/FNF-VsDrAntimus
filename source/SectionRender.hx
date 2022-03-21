import flixel.FlxG;
import flixel.util.FlxColor;
import flixel.group.FlxGroup.FlxTypedGroup;
import Section.SwagSection;
import flixel.addons.display.FlxGridOverlay;
import flixel.FlxSprite;

class SectionRender extends FlxSprite
{
	public var section:SwagSection;
	public var icon:FlxSprite;
	public var lastUpdated:Bool;
    public var fiveKey:Bool;
	public var gridSize:Int;
	public var gridHeight:Int;

	public function new(x:Float, y:Float, GRID_SIZE:Int, fiveKey:Bool, ?Height:Int = 16)
	{
		super(x, y);
		gridSize = GRID_SIZE;
		gridHeight = Height;
		reRender(fiveKey);
	}

	override function update(elapsed)
	{
	}

	public function reRender(fiveKey:Bool)
	{
		this.fiveKey = fiveKey;

		makeGraphic(gridSize * (fiveKey ? 10 : 8), Std.int(gridSize * gridHeight), 0xffe7e6e6);

		var h = gridSize;
		if (Math.floor(h) != h)
			h = gridSize;

		if (FlxG.save.data.editorBG)
			FlxGridOverlay.overlay(this, gridSize, Std.int(h), gridSize * (fiveKey ? 10 : 8), Std.int(gridSize * gridHeight));
	}
}
