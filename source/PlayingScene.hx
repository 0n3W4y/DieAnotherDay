package;

import openfl.display.Bitmap;
import openfl.display.BitmapData;
import openfl.display.Sprite;
import openfl.Assets;
import openfl.Lib;

import Math;

class PlayingScene extends Sprite
{	
	private var _myGame:Game;
	private var _mapGrid:Array<Dynamic>;
	private var _mapGridSize:Array<Int>;
	private var _entity:Array<Tile>;

	private var _maxSceneWidth:Int = 400; // cause 200 map size;
	private var _maxSceneHeight:Int = 400;

	public function new(game)
	{
		super();
		_myGame = game;
		init();
	}

	private function init()
	{
		createLevel();
	}

	private function createLevel()
	{
		createLevelGround();
	}

	private function createLevelGround()
	{
		generateMapGrid(200, true, true);
	}

	private function generateMapGrid(size, rocks, water)
	{
		_mapGridSize = size;
		var rocksArray = null;
		var waterArray = null;
		if (rocks)
			rocksArray =  generateRocks(size);

		if (water)
			waterArray = generateWater(size);


		_mapGrid = new Array();

		// 2 - rocks, 0 - earth; 1 - water

		for (i 0..._mapGridSize-1)
		{
			var array = new Array();
			var lastNum = null;

			for (j 0..._mapGridSize-1)
			{
				var num = Math.floor(Math.random() * 3);

				if (lastNum == null && maxRocks > 0 && maxWater > 0)
				{
					array.push(num);
					lastNum = num;
				}
				else if (maxRocks > 0 && maxWater > 0)
				{
					if (lastNum == num)
					{
						array.push(num);
					}
				}








				if (maxRocks >= 0)
				{
					var num = Math.floor(Math.random() * 3);
				}
				else
				{
					array.push(0);
				}

			}
			_mapGrid.push(array);
		}
	}

	private function generateRocks(size)
	{
		var gridSize = size*size;
		var num = Math.floor(Math.random());
	}

	private function generateWater(size)
	{
		var gridSize = size*size;
	}
}