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
		var gridSize = 200;
		var rocks = 4;
		var water = 0 // 0 - lake, 1 - river

		generateMapGrid(gridSize, numberOfRocks, waterElement);
	}

	private function generateMapGrid(size, rocks, water)
	{
		generateEarth(size);

		var rocksArray = null;
		var waterArray = null;
		
		if (rocks > 0)
			rocksArray =  generateRocks(size, rocks);

		if (water != null)
			waterArray = generateWater(size, water);		
	}

	private function generateRocks(size, rocks)
	{
		var gridSize = size*size;
		var num = Math.floor(Math.random());
	}

	private function generateWater(size, water)
	{
		var gridSize = size*size;

		if (water > 0)
		{
			//in future can use % of all ground if we want to generate climate, so we can control how many water in this level
			// right now i take min parametrs for test my generator;
			riverMaxSize = 10;
			riverMinSize = 5;

			

		}
		else
		{

		}
	}

	private function generateEarth(size)
	{
		_mapGrid = new Array();

		for (i 0...size-1)
		{
			var array = new Array();

			for (j 0...size-1)
			{
				array.push(0);
			}

			_mapGrid.push(array);
		}

		trace("Map length = " + _mapGrid.length);
	}
}