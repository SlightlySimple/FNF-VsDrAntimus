package;

import openfl.utils.Assets as OpenFlAssets;

using StringTools;

class CoolUtil
{
	public static var difficultyArray:Array<String> = ['Easy', "Normal", "Hard"];
	public static var langStrings:Map<String,String> = [];

	public static var daPixelZoom:Float = 6;

	public static function difficultyFromInt(difficulty:Int):String
	{
		return difficultyArray[difficulty];
	}

	public static function coolTextFile(path:String):Array<String>
	{
		var daList:Array<String> = OpenFlAssets.getText(path).trim().split('\n');

		for (i in 0...daList.length)
		{
			daList[i] = daList[i].trim();
		}

		return daList;
	}

	public static function coolStringFile(path:String):Array<String>
	{
		var daList:Array<String> = path.trim().split('\n');

		for (i in 0...daList.length)
		{
			daList[i] = daList[i].trim();
		}

		return daList;
	}

	public static function numberArray(max:Int, ?min = 0):Array<Int>
	{
		var dumbArray:Array<Int> = [];
		for (i in min...max)
		{
			dumbArray.push(i);
		}
		return dumbArray;
	}

	public static function loadLangStrings()
	{
		CoolUtil.langStrings = [];

		var list = CoolUtil.coolTextFile(Paths.txt('data/lang'));
		if (list.length > 0)
		{
			for (i in 0...list.length)
			{
				if (list[i].trim() != "")
				{
					var splitString = list[i].split("|");
					CoolUtil.langStrings.set(splitString[0],splitString[1]);
				}
			}
		}
	}

	public static function translate(key:String, ?vars:Array<Array<String>>):String
	{
		if ( vars == null )
			vars = [];
		if ( CoolUtil.langStrings.get(key) == null )
		{
			if ( CoolUtil.langStrings.get(key.toLowerCase()) == null )
				return key;
			var ret:String = StringTools.replace(CoolUtil.langStrings.get(key.toLowerCase()),'#','\n');
			for (v in vars)
				ret = StringTools.replace(ret,v[0],v[1]);
			return ret;
		}
		var ret:String = StringTools.replace(CoolUtil.langStrings.get(key),'#','\n');
		for (v in vars)
			ret = StringTools.replace(ret,v[0],v[1]);
		return ret;
		return ret;
	}
}
