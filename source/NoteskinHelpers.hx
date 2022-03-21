#if FEATURE_FILESYSTEM
import sys.FileSystem;
import sys.io.File;
#end
import openfl.display.BitmapData;
import flixel.FlxSprite;
import flixel.graphics.FlxGraphic;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.FlxG;
import openfl.utils.AssetType;
import openfl.utils.Assets as OpenFlAssets;

using StringTools;

class NoteskinHelpers
{
	public static var noteskinArray = [];
	public static var xmlData = [];

	public static function updateNoteskins()
	{
		noteskinArray = [];
		xmlData = [];
		#if FEATURE_FILESYSTEM
		for (imageAsset in OpenFlAssets.list(AssetType.IMAGE))
		{
			if (imageAsset.replace('\\','/').indexOf('images/noteskins') > -1)
			{
				var noteskinFilename = imageAsset.replace('\\','/').split('/');
				var noteskinName = noteskinFilename[noteskinFilename.length - 2];
				if (!noteskinArray.contains(noteskinName))
					noteskinArray.push(noteskinName);
			}
		}
		#else
		noteskinArray = ["Arrows", "Circles"];
		#end

		return noteskinArray;
	}

	public static function getNoteskins()
	{
		return noteskinArray;
	}

	public static function getNoteskinByID(id:Int)
	{
		return noteskinArray[id];
	}

	static public function generateNoteskinSprite(id:Int, ?type:String = 'normal')
	{
		if (FlxG.save.data.stepMania && OpenFlAssets.exists(Paths.image('noteskins/' + getNoteskinByID(id) + '/' + type + 'Quant')))
			return Paths.getSparrowAtlas('noteskins/' + getNoteskinByID(id) + '/' + type + 'Quant');
		if (OpenFlAssets.exists(Paths.image('noteskins/' + getNoteskinByID(id) + '/' + type)))
			return Paths.getSparrowAtlas('noteskins/' + getNoteskinByID(id) + '/' + type);
		if (FlxG.save.data.stepMania && OpenFlAssets.exists(Paths.image('noteskins/' + getNoteskinByID(id) + '/normalQuant')))
			return Paths.getSparrowAtlas('noteskins/' + getNoteskinByID(id) + '/normalQuant');
		return Paths.getSparrowAtlas('noteskins/' + getNoteskinByID(id) + '/normal');
	}
}
